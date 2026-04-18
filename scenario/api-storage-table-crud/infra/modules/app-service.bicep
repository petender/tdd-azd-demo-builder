// ============================================================================
// App Service Module — App Service Plan + Web App for .NET 10 Web API
// Hosts the logistics CRUD API with Swagger UI, managed identity, and HTTPS.
// ============================================================================

@description('Name of the App Service Plan')
param planName string

@description('Name of the App Service (Web App)')
param appName string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

@description('Application Insights connection string for APM')
param appInsightsConnectionString string

@description('Storage account name for Table Storage access')
param storageAccountName string

@secure()
@description('Storage account connection string')
param storageConnectionString string

// ============================================================================
// App Service Plan (AVM)
// ============================================================================

module appServicePlan 'br/public:avm/res/web/serverfarm:0.4.0' = {
  name: '${planName}-deploy'
  params: {
    name: planName
    location: location
    tags: tags
    skuName: 'B1'
    skuCapacity: 1
    kind: 'linux'
    reserved: true
  }
}

// ============================================================================
// Web App — .NET 10 Web API (AVM)
// ============================================================================

module webApp 'br/public:avm/res/web/site:0.12.0' = {
  name: '${appName}-deploy'
  params: {
    name: appName
    location: location
    tags: union(tags, { 'azd-service-name': 'web' })
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|10.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
    }
    appSettingsKeyValuePairs: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
      StorageAccountName: storageAccountName
      StorageConnectionString: storageConnectionString
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('App Service resource ID')
output resourceId string = webApp.outputs.resourceId

@description('App Service name')
output resourceName string = webApp.outputs.name

@description('System-assigned managed identity principal ID')
output principalId string = webApp.outputs.systemAssignedMIPrincipalId

@description('App Service default hostname')
output defaultHostname string = webApp.outputs.defaultHostname
