param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param acrRegistryName string = 'depdocker' // Your ACR registry name
param location string = resourceGroup().location // Location of the resource group

// Reference to existing ACR in the 'deploy' resource group
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrRegistryName
  scope: resourceGroup('deploy') // Specify the correct resource group name
}

// Create a Container App Environment
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: 'myContainerAppEnvironment' // Change to your desired environment name
  location: location
  properties: {
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]

  }
}

// Deploy the Container App
resource apiContainer 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'hello-world-container'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          name: 'hello-world'
          image: imageName
          resources: {
            cpu: 1
            memory: '2Gi'
          }
        }
      ]
    }
    // Move imageRegistryCredentials here
    imageRegistryCredentials: [
      {
        server: acr.properties.loginServer
        username: acr.listCredentials().username
        password: acr.listCredentials().passwords[0].value
      }
    ]
  }
}

