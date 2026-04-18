// ============================================================================
// API Storage Table CRUD — Main Orchestration Template
// Deploys a .NET 10 Web API on App Service with Azure Storage Table,
// managed identity for keyless access, and unified monitoring.
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// Parameters
// ============================================================================

@description('Azure region for all resources')
param location string = 'eastus2'

@description('Environment name used in resource naming (e.g., demo, dev)')
@minLength(1)
@maxLength(10)
param environment string

@description('Project name for tagging')
param projectName string = 'api-storage-table-crud'

@description('Owner tag value')
param owner string = 'demo-deployer'

@description('Principal ID of the deploying user. Azure Developer CLI populates this automatically.')
param principalId string

// ============================================================================
// Variables
// ============================================================================

var uniqueSuffix = uniqueString(resourceGroup().id)

var tags = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: projectName
  SecurityControl: 'Ignore'
  Owner: owner
}

// Resource naming — CAF conventions
var logAnalyticsName = 'log-api-storage-table-crud-${environment}'
var appInsightsName = 'appi-api-storage-table-crud-${environment}'
var appServicePlanName = 'asp-api-storage-table-crud-${environment}'
var appServiceName = 'app-api-storage-table-crud-${environment}'
var storageAccountName = 'st${take(replace(projectName, '-', ''), 8)}${take(environment, 3)}${take(uniqueSuffix, 6)}'

// RBAC role definition IDs
var storageTableDataContributorRoleId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'

// ============================================================================
// Module Deployments — Phase 1: Foundation (Monitoring)
// ============================================================================

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deploy'
  params: {
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
    location: location
    tags: tags
  }
}

// ============================================================================
// Module Deployments — Phase 2: Data (Storage Account)
// ============================================================================

module storageAccount 'modules/storage-account.bicep' = {
  name: 'storage-account-deploy'
  params: {
    name: storageAccountName
    location: location
    tags: tags
  }
}

// ============================================================================
// Module Deployments — Phase 3: Compute (App Service)
// ============================================================================

// Reference storage account for connection string and role assignments
resource storageAccountRef 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
  dependsOn: [storageAccount]
}

module appService 'modules/app-service.bicep' = {
  name: 'app-service-deploy'
  params: {
    planName: appServicePlanName
    appName: appServiceName
    location: location
    tags: tags
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    storageAccountName: storageAccountName
    storageConnectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountRef.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
  }
}

// ============================================================================
// RBAC Role Assignments — Storage Table Data Contributor
// ============================================================================

// App Service managed identity → Storage Table Data Contributor
resource appServiceStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, appServiceName, storageAccountName, storageTableDataContributorRoleId)
  scope: storageAccountRef
  dependsOn: [storageAccount]
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      storageTableDataContributorRoleId
    )
    principalId: appService.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// Deployer → Storage Table Data Contributor
resource deployerStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  name: guid(storageAccountRef.id, principalId, storageTableDataContributorRoleId)
  scope: storageAccountRef
  dependsOn: [storageAccount]
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      storageTableDataContributorRoleId
    )
    principalId: principalId
    principalType: 'User'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('App Service default URL')
output appServiceUrl string = 'https://${appService.outputs.defaultHostname}'

@description('Swagger UI URL')
output swaggerUrl string = 'https://${appService.outputs.defaultHostname}/swagger'

@description('Storage account name')
output storageAccountName string = storageAccount.outputs.resourceName

@description('Log Analytics workspace name')
output logAnalyticsWorkspaceName string = monitoring.outputs.logAnalyticsName

@description('Application Insights name')
output appInsightsName string = monitoring.outputs.appInsightsName

@description('App Service name')
output appServiceName string = appService.outputs.resourceName
