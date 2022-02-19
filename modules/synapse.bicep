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
     managedResourceGroupName: '${synapseName}rg'
     managedVirtualNetwork: 'default'
  }
  resource firewall 'firewallRules@2021-06-01' = {
    name: 'allowAll'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '255.255.255.255'
    }
  }
  resource managedIdentitySQLControl 'managedIdentitySqlControlSettings@2021-06-01' = {
    name: 'default'
    properties: {
      grantSqlControlToManagedIdentity: {
        desiredState: 'Enabled'
      }
    }
  }
  resource sqlPool 'sqlPools' = {
    name: 'demoSqlPool'
    location: location
    sku: {
       name: 'DW200c'
       capacity: 0
    }
  }
  resource spartk 'bigDataPools@2021-06-01' = {
    name: 'demoSpark'
    location: location
    properties: {
      sparkVersion: '3.1'
      nodeCount: 10
      nodeSize: 'Small'
      nodeSizeFamily: 'MemoryOptimized'
      autoScale: {
        enabled: true
        minNodeCount: 3
        maxNodeCount: 10
      }
      autoPause: {
        enabled: true
        delayInMinutes: 15
      }
      isComputeIsolationEnabled: false
      sessionLevelPackagesEnabled: false
      cacheSize: 0
      dynamicExecutorAllocation: {
        enabled: false
      }
    }
  }
  resource adxPool 'kustoPools@2021-06-01-preview' = {
    name: adxName
    location: location
    sku: {
      name: 'Storage optimized'
      size: 'Medium'
      capacity: 2 
    }
    properties: {
      enableStreamingIngest: false
      enablePurge: false
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

output synapseSystemId string = synapseWorkspace.identity.principalId



