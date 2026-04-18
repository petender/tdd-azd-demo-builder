// ============================================================================
// Storage Account Module — GPv2 Standard LRS with Table service
// Hosts Azure Table Storage for logistics CRUD entities.
// ============================================================================

@description('Storage account name (max 24 chars, no hyphens)')
param name string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

// ============================================================================
// Storage Account (AVM)
// ============================================================================

module storageAccount 'br/public:avm/res/storage/storage-account:0.14.0' = {
  name: '${name}-deploy'
  params: {
    name: name
    location: location
    tags: tags
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    tableServices: {
      tables: []
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Storage account resource ID')
output resourceId string = storageAccount.outputs.resourceId

@description('Storage account name')
output resourceName string = storageAccount.outputs.name

@description('Storage account table endpoint')
output tableEndpoint string = 'https://${name}.table.${environment().suffixes.storage}'
