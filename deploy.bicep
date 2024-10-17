// Parameters
param webAppName string = 'myApiContainer' // Name for your Azure Container App
param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param acrRegistryName string = 'depdocker' // Your ACR registry name
param location string = resourceGroup().location
param appServicePlanName string = '${webAppName}-plan'
param environmentName string = 'myContainerAppEnv' // Name for the Container App Environment

// ACR Resource reference
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrRegistryName
  scope: resourceGroup() // Ensure this is referencing the correct resource group
}

// Container App Environment
resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: environmentName
  location: location
  properties: {
    // Define any properties required for the managed environment
  }
}

// Azure Container App resource
resource apiContainer 'Microsoft.App/containerApps@2024-03-01' = {
  name: webAppName
  location: location
  properties: {
    environmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000 // The port your app listens on
      }
      revisionCount: 10 // Set the number of revisions to retain
    }
    template: {
      containers: [
        {
          name: webAppName
          image: imageName // Specify the Docker image
          resources: {
            cpu: 0.5 // Set CPU allocation
            memory: '1Gi' // Set memory allocation
          }
        }
      ]
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
