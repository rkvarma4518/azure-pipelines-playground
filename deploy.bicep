// Parameters
// param containerGroupName string = 'myContainerGroup'
// param containerName string = 'my-container'
param containerGroupName string
param containerName string
param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param cpuCores int = 1
param memoryGb int = 2 // Use int for memory size
param location string = resourceGroup().location
param acrRegistryName string = 'devdoc' // Your ACR registry name

output containerGroupName string = containerGroupName
output containerName string = containerName

// ACR Resource reference
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrRegistryName
  scope: resourceGroup('learning')
}

// ACI: Azure Container Instance resource
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2022-04-01-preview' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageName // Full path to the image in ACR
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGb: memoryGb
            }
          }
          ports: [
            {
              protocol: 'TCP'
              port: 80 // The port the container will listen on
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      dnsNameLabel: uniqueString(resourceGroup().id)
    }
    imageRegistryCredentials: [
      {
        server: acr.properties.loginServer
        username: acr.listCredentials().username
        password: acr.listCredentials().passwords[0].value
      }
    ]
  }
}
