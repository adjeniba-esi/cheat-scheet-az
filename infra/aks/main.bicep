// ============================================================
//  Cluster AKS — Template réutilisable
//  Exercice : configuration d'un premier cluster AKS
//  Usage : az deployment group create \
//            --resource-group <rg> \
//            --template-file main.bicep \
//            --parameters @params.bicepparam
// ============================================================

// ── Paramètres ──────────────────────────────────────────────

@description('Nom du cluster AKS')
@minLength(3)
@maxLength(63)
param clusterName string

@description('Nom du Resource Group cible (pour le node resource group généré)')
param resourceGroupName string

@description('Région Azure')
@allowed([
  'canadaeast'
  'canadacentral'
  'eastus'
  'eastus2'
  'northcentralus'
  'westus2'
  'westeurope'
  'northeurope'
])
param location string = 'northcentralus'

@description('Version de Kubernetes')
param kubernetesVersion string = '1.34.7'

@description('Taille des VMs du node pool')
param vmSize string = 'Standard_D2s_v6'

@description('Nombre de nœuds initial')
@minValue(1)
@maxValue(10)
param nodeCount int = 2

@description('Nombre minimum de nœuds (autoscaling)')
@minValue(1)
param minNodeCount int = 2

@description('Nombre maximum de nœuds (autoscaling)')
@maxValue(20)
param maxNodeCount int = 5

@description('Taille disque OS en GB')
param osDiskSizeGB int = 128

@description('Nombre maximum de pods par nœud')
param maxPodsPerNode int = 110

@description('Resource ID de l\'identité managée kubelet (userAssignedIdentity agentpool)')
param kubeletIdentityResourceId string

@description('Client ID de l\'identité managée kubelet')
param kubeletIdentityClientId string

@description('Object ID de l\'identité managée kubelet')
param kubeletIdentityObjectId string

@description('Activer Azure Key Vault Secrets Provider')
param enableKeyVaultSecretsProvider bool = false

@description('Activer Azure Policy')
param enableAzurePolicy bool = false

@description('Activer Workload Identity (OIDC)')
param enableWorkloadIdentity bool = true

@description('Activer Image Cleaner (nettoyage images inutilisées)')
param enableImageCleaner bool = true

@description('Intervalle de nettoyage des images en heures')
param imageCleanerIntervalHours int = 168

@description('Canal de mise à jour automatique du cluster')
@allowed(['none', 'patch', 'stable', 'rapid', 'node-image'])
param upgradeChannel string = 'patch'

@description('Jour de la semaine pour la maintenance planifiée')
@allowed(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
param maintenanceDayOfWeek string = 'Sunday'

@description('Tags à appliquer à toutes les ressources')
param tags object = {
  environment: 'dev'
  managedBy: 'bicep'
}

// ── Variables ────────────────────────────────────────────────

var dnsPrefix = '${clusterName}-dns'
var nodeResourceGroup = 'MC_${resourceGroupName}_${clusterName}_${location}'

// ── Cluster AKS ─────────────────────────────────────────────

resource aksCluster 'Microsoft.ContainerService/managedClusters@2026-01-02-preview' = {
  name: clusterName
  location: location
  tags: tags
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  kind: 'Base'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: vmSize
        osDiskSizeGB: osDiskSizeGB
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        maxPods: maxPodsPerNode
        type: 'VirtualMachineScaleSets'
        maxCount: maxNodeCount
        minCount: minNodeCount
        enableAutoScaling: true
        scaleDownMode: 'Delete'
        powerState: {
          code: 'Running'
        }
        orchestratorVersion: kubernetesVersion
        enableNodePublicIP: false
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        upgradeStrategy: 'Rolling'
        upgradeSettings: {
          maxSurge: '10%'
          maxUnavailable: '0'
        }
        enableFIPS: false
        securityProfile: {
          sshAccess: 'LocalUser'
          enableVTPM: false
          enableSecureBoot: false
        }
      }
    ]
    windowsProfile: {
      adminUsername: 'azureuser'
      enableCSIProxy: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: enableKeyVaultSecretsProvider
      }
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      extensionManager: {
        enabled: true
      }
    }
    nodeResourceGroup: nodeResourceGroup
    enableRBAC: true
    supportPlan: 'KubernetesOfficial'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'none'
      networkDataplane: 'azure'
      loadBalancerSku: 'standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 1
        }
        backendPoolType: 'nodeIPConfiguration'
      }
      podCidr: '10.244.0.0/16'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      outboundType: 'loadBalancer'
      podCidrs: [ '10.244.0.0/16' ]
      serviceCidrs: [ '10.0.0.0/16' ]
      ipFamilies: [ 'IPv4' ]
      advancedNetworking: {
        enabled: false
        observability: { enabled: false }
        security: {
          enabled: false
          advancedNetworkPolicies: 'None'
        }
        performance: { accelerationMode: 'None' }
      }
      podLinkLocalAccess: 'IMDS'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    identityProfile: {
      kubeletidentity: {
        resourceId: kubeletIdentityResourceId
        clientId: kubeletIdentityClientId
        objectId: kubeletIdentityObjectId
      }
    }
    autoScalerProfile: {
      'balance-similar-node-groups': 'false'
      'daemonset-eviction-for-empty-nodes': false
      'daemonset-eviction-for-occupied-nodes': true
      expander: 'random'
      'ignore-daemonsets-utilization': false
      'max-empty-bulk-delete': '10'
      'max-graceful-termination-sec': '600'
      'max-node-provision-time': '15m'
      'max-total-unready-percentage': '45'
      'new-pod-scale-up-delay': '0s'
      'ok-total-unready-count': '3'
      'scale-down-delay-after-add': '10m'
      'scale-down-delay-after-delete': '10s'
      'scale-down-delay-after-failure': '3m'
      'scale-down-unneeded-time': '10m'
      'scale-down-unready-time': '20m'
      'scale-down-utilization-threshold': '0.5'
      'scan-interval': '10s'
      'skip-nodes-with-local-storage': 'false'
      'skip-nodes-with-system-pods': 'true'
    }
    autoUpgradeProfile: {
      upgradeChannel: upgradeChannel
      nodeOSUpgradeChannel: 'NodeImage'
    }
    disableLocalAccounts: false
    securityProfile: {
      imageCleaner: {
        enabled: enableImageCleaner
        intervalHours: imageCleanerIntervalHours
      }
      workloadIdentity: {
        enabled: enableWorkloadIdentity
      }
    }
    storageProfile: {
      diskCSIDriver: { enabled: true }
      fileCSIDriver: { enabled: true }
      snapshotController: { enabled: true }
      blobCSIDriver: { enabled: true }
    }
    oidcIssuerProfile: {
      enabled: enableWorkloadIdentity
    }
    workloadAutoScalerProfile: {}
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {}
      }
    }
    metricsProfile: {
      costAnalysis: { enabled: false }
    }
    nodeProvisioningProfile: {
      mode: 'Manual'
      defaultNodePools: 'Auto'
    }
    bootstrapProfile: {
      artifactSource: 'Direct'
    }
    healthMonitorProfile: {
      enableContinuousControlPlaneAndAddonMonitor: false
      enableOnDemandMonitor: false
    }
  }
}

// ── Node Pool (déclaration explicite) ────────────────────────

resource agentPool 'Microsoft.ContainerService/managedClusters/agentPools@2026-01-02-preview' = {
  parent: aksCluster
  name: 'agentpool'
  properties: {
    count: nodeCount
    vmSize: vmSize
    osDiskSizeGB: osDiskSizeGB
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    maxPods: maxPodsPerNode
    type: 'VirtualMachineScaleSets'
    maxCount: maxNodeCount
    minCount: minNodeCount
    enableAutoScaling: true
    scaleDownMode: 'Delete'
    powerState: { code: 'Running' }
    orchestratorVersion: kubernetesVersion
    enableNodePublicIP: false
    mode: 'System'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    upgradeStrategy: 'Rolling'
    upgradeSettings: {
      maxSurge: '10%'
      maxUnavailable: '0'
    }
    enableFIPS: false
    securityProfile: {
      sshAccess: 'LocalUser'
      enableVTPM: false
      enableSecureBoot: false
    }
  }
}

// ── Fenêtres de maintenance ──────────────────────────────────

resource maintenanceAutoUpgrade 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2026-01-02-preview' = {
  parent: aksCluster
  name: 'aksManagedAutoUpgradeSchedule'
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: maintenanceDayOfWeek
        }
      }
      durationHours: 8
      utcOffset: '+00:00'
      startDate: '2026-05-27'
      startTime: '00:00'
    }
  }
}

resource maintenanceNodeOSUpgrade 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2026-01-02-preview' = {
  parent: aksCluster
  name: 'aksManagedNodeOSUpgradeSchedule'
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: maintenanceDayOfWeek
        }
      }
      durationHours: 8
      utcOffset: '+00:00'
      startDate: '2026-05-27'
      startTime: '00:00'
    }
  }
}

// ── Outputs ──────────────────────────────────────────────────

output clusterName string = aksCluster.name
output clusterFqdn string = aksCluster.properties.fqdn
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
output nodeResourceGroup string = aksCluster.properties.nodeResourceGroup
output kubeletIdentityObjectId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
