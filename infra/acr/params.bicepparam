using 'main.bicep'

// -- Identité du registre -------------------------------------
// Le nom doit être unique globalement dans Azure.
// Convention recommandée : {projet}acr ou {organisation}acr
param registryName = 'esiadcr'
param location     = 'canadacentral'

// -- SKU ------------------------------------------------------
// Basic  : dev/test, pas de geo-réplication ni rétention
// Standard : prod standard
// Premium : geo-réplication, rétention, endpoints dédiés
param sku = 'Basic'

// -- Accès ----------------------------------------------------
// adminUserEnabled : false recommandé — utiliser les identités managées AKS
// Activer uniquement pour des tests locaux avec docker login
param adminUserEnabled     = false
param anonymousPullEnabled = false
param publicNetworkAccess  = 'Enabled'

// -- Politiques (nécessitent SKU Premium pour retentionPolicy) -
param enableRetentionPolicy  = false
param retentionPolicyDays    = 7
param enableSoftDelete       = false
param softDeleteRetentionDays = 7

// -- Fonctionnalités Premium uniquement -----------------------
param zoneRedundancy    = false   // Premium + région compatible
param dataEndpointEnabled = false // Premium uniquement

// -- Tags ----------------------------------------------------
param tags = {
  environment: 'dev'
  project: 'aks-exercice'
  managedBy: 'bicep'
}
