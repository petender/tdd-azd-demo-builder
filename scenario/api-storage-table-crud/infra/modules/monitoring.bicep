// ============================================================================
// Monitoring Module — Log Analytics Workspace + Application Insights
// Centralized logging and APM for the API Storage Table CRUD demo.
// ============================================================================

@description('Name of the Log Analytics workspace')
param logAnalyticsName string

@description('Name of the Application Insights instance')
param appInsightsName string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

// ============================================================================
// Log Analytics Workspace (AVM)
// ============================================================================

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.9.0' = {
  name: '${logAnalyticsName}-deploy'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
    skuName: 'PerGB2018'
    dataRetention: 31
    dailyQuotaGb: 1
  }
}

// ============================================================================
// Application Insights (AVM)
// ============================================================================

module appInsights 'br/public:avm/res/insights/component:0.4.0' = {
  name: '${appInsightsName}-deploy'
  params: {
    name: appInsightsName
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
    kind: 'web'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Log Analytics workspace resource ID')
output logAnalyticsResourceId string = logAnalytics.outputs.resourceId

@description('Log Analytics workspace name')
output logAnalyticsName string = logAnalytics.outputs.name

@description('Application Insights resource ID')
output appInsightsResourceId string = appInsights.outputs.resourceId

@description('Application Insights name')
output appInsightsName string = appInsights.outputs.name

@description('Application Insights connection string')
output appInsightsConnectionString string = appInsights.outputs.connectionString
