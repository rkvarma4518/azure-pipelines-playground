// Parameters
param webAppName string = 'myAppContainer' // Name for your Azure Container App
param imageName string = 'depdocker.azurecr.io/hello-world:latest' // Your ACR image
param acrRegistryName string = 'depdocker' // Your ACR registry name
param location string = resourceGroup().location
param appServicePlanName string = '${webAppName}-plan'
param environmentName string = 'myContainerAppEnv' // Name for the Container App Environment

// ACR Resource reference
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrRegistryName
  scope: resourceGroup('deploy') // Ensure this is referencing the correct resource group
}

// Define the environment for Container Apps
resource environment 'Microsoft.App/containerAppsEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    // Define any necessary properties for the container apps environment
    appLogsConfiguration: {
      logLevel: 'Debug' // Set your log level as needed
    }
  }
}

// Define the Container App
resource appContainer 'Microsoft.App/containerApps@2023-05-01' = {
  name: webAppName
  location: location
  properties: {
    environmentId: environment.id
    configuration: {
      ingress: {
        external: true // Set to true to expose the app to the internet
        targetPort: 80 // The port your app will listen on
      }
    }
    template: {
      containers: [
        {
          name: webAppName
          image: imageName // Reference the image from ACR
          resources: {
            cpu: 0.5 // Specify CPU requirements
            memory: '1Gi' // Specify memory requirements
          }
        }
      ]
    }
  }
}

// Output the Container App URL
output appUrl string = 'https://${appContainer.name}.${environment.properties.ingress.fqdn}'
