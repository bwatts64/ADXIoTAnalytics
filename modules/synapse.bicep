param synapseName string
param adxName string
param location string = resourceGroup().location
param saResourceId string
param saName string


resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
     defaultDataLakeStorage: {
       resourceId: saResourceId
       accountUrl: 'https://${saName}.dfs.core.windows.net'
       filesystem: 'synapse'
     }
     sqlAdministratorLogin: 'sqladmin'
     sqlAdministratorLoginPassword: 'ADXDemo1234'
  }
  resource adxPool 'kustoPools@2021-06-01-preview' = {
    name: adxName
    location: location
    sku: {
      name: 'Compute optimized'
      size: 'Medium'
      capacity: 2 
    }
    properties: {
      enableStreamingIngest: true
      enablePurge: true
      optimizedAutoscale: {
        minimum: 2
        maximum: 6
        version: 1
        isEnabled: true
      }
    }
    resource database 'databases@2021-06-01-preview' = {
      kind: 'ReadWrite'
      name: 'NYCTaxi'
      location: location
      properties: {
        softDeletePeriod: 'P60D'
        hotCachePeriod: 'P365D'
      }
    }
  }
}



