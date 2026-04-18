using './main.bicep'

param environment = readEnvironmentVariable('AZURE_ENV_NAME', 'demo')
param location = readEnvironmentVariable('AZURE_LOCATION', 'eastus2')
param projectName = 'api-storage-table-crud'
param owner = 'demo-deployer'
param principalId = readEnvironmentVariable('AZURE_PRINCIPAL_ID', '')
