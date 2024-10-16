// Parameters
param containerGroupName string = 'myContainerGroup'
param containerName string = 'myContainer'
param imageName string = 'depdocker/hello-world:latest' // Your ACR image
param cpuCores int = 1
param memoryGb float = 1.5
param location string = resourceGroup().location
param acrRegistryName string = 'depdocker' // Your ACR registry name

// ACR Resource reference
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01' existing = {
  name: acrRegistryName
}

// ACI: Azure Container Instance resource
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: '${acr.properties.loginServer}/${imageName}' // Full path to the image in ACR
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
    osType: 'Linux' // or 'Windows' depending on your container image
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      dnsNameLabel: uniqueString(resourceGroup().id) // Creates a DNS name for the ACI
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
