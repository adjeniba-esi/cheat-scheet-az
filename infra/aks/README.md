# Bicep — Template de cluster AKS

Template réutilisable pour déployer un cluster Azure Kubernetes Service à partir du fichier exporté par le portail Azure.

## Fichiers

```
aks-cluster/
├── main.bicep          # Template principal — toutes les ressources
└── params.bicepparam   # Valeurs à personnaliser
```

## Utilisation

### 1. Remplir `params.bicepparam`

Trois valeurs obligatoires à obtenir avant le déploiement :

| Paramètre | Comment l'obtenir |
|---|---|
| `clusterName` | Nom de votre choix |
| `resourceGroupName` | RG cible existant |
| `kubeletIdentityResourceId` | `az identity show --resource-group <rg> --name <cluster>-agentpool --query id` |
| `kubeletIdentityClientId` | `az identity show ... --query clientId` |
| `kubeletIdentityObjectId` | `az identity show ... --query principalId` |

> **Premier déploiement** : si l'identité n'existe pas encore, laissez les champs `kubelet*` vides et créez d'abord le cluster via le portail. Récupérez ensuite les valeurs et redéployez.

### 2. Déployer

```bash
# Connexion
az login
az account set --subscription <subscription-id>

# Créer le Resource Group si nécessaire
az group create --name <rg> --location northcentralus

# Prévisualiser
az deployment group what-if \
  --resource-group <rg> \
  --template-file main.bicep \
  --parameters @params.bicepparam

# Déployer
az deployment group create \
  --resource-group <rg> \
  --template-file main.bicep \
  --parameters @params.bicepparam
```

### 3. Se connecter au cluster

```bash
az aks get-credentials --resource-group <rg> --name <clusterName>
kubectl get nodes
```

## Paramètres disponibles

| Paramètre | Défaut | Description |
|---|---|---|
| `clusterName` | — | Nom du cluster (obligatoire) |
| `resourceGroupName` | — | RG cible (obligatoire) |
| `location` | `northcentralus` | Région Azure |
| `kubernetesVersion` | `1.34.7` | Version Kubernetes |
| `vmSize` | `Standard_D2s_v6` | Taille des nœuds |
| `nodeCount` | `2` | Nombre initial de nœuds |
| `minNodeCount` | `2` | Min autoscaling |
| `maxNodeCount` | `5` | Max autoscaling |
| `enableWorkloadIdentity` | `true` | OIDC + Workload Identity |
| `enableKeyVaultSecretsProvider` | `false` | Addon Key Vault |
| `enableAzurePolicy` | `false` | Addon Azure Policy |
| `upgradeChannel` | `patch` | Canal de mise à jour auto |
| `maintenanceDayOfWeek` | `Sunday` | Jour de maintenance |
| `tags` | `{environment: dev, ...}` | Tags Azure |
