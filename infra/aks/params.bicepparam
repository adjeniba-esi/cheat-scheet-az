using 'main.bicep'

// -- Identité du cluster --------------------------------------
// Remplacez ces valeurs par celles de votre identité managée agentpool.
// Pour les obtenir après création du cluster :
//   az aks show --resource-group <rg> --name <cluster> \
//     --query "identityProfile.kubeletidentity" -o json

param clusterName = 'mon-cluster-aks'
param resourceGroupName = 'mon-resource-group'
param location = 'northcentralus'

// -- Identité managée kubelet ---------------------------------
// Récupérer via : az identity show --resource-group <rg> --name <cluster>-agentpool
param kubeletIdentityResourceId = '/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<cluster>-agentpool'
param kubeletIdentityClientId   = '<kubelet-client-id>'
param kubeletIdentityObjectId   = '<kubelet-object-id>'

// -- Dimensionnement ------------------------------------------
param kubernetesVersion = '1.34.7'
param vmSize            = 'Standard_D2s_v6'
param nodeCount         = 2
param minNodeCount      = 2
param maxNodeCount      = 5
param osDiskSizeGB      = 128
param maxPodsPerNode    = 110

// -- Sécurité & fonctionnalités -------------------------------
param enableWorkloadIdentity         = true
param enableImageCleaner             = true
param imageCleanerIntervalHours      = 168
param enableKeyVaultSecretsProvider  = false
param enableAzurePolicy              = false

// -- Maintenance ----------------------------------------------
param upgradeChannel        = 'patch'
param maintenanceDayOfWeek  = 'Sunday'

// -- Tags ----------------------------------------------------
param tags = {
  environment: 'dev'
  project: 'aks-exercice'
  managedBy: 'bicep'
}
