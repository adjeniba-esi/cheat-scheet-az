# Bicep — Template Azure Container Registry

Template réutilisable pour déployer un Azure Container Registry (ACR) avec ses scope maps de permissions.

## Fichiers

```
acr/
├── main.bicep          # Template principal
└── params.bicepparam   # Valeurs à personnaliser
```

## Utilisation

```bash
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

# Connecter AKS au registre après déploiement
az aks update \
  --resource-group <rg> \
  --name <cluster> \
  --attach-acr <registryName>
```

## Paramètres

| Paramètre | Défaut | Description |
|---|---|---|
| `registryName` | — | Nom unique global, minuscules (obligatoire) |
| `location` | `canadacentral` | Région Azure |
| `sku` | `Basic` | `Basic` / `Standard` / `Premium` |
| `adminUserEnabled` | `false` | Compte admin — désactivé recommandé |
| `anonymousPullEnabled` | `false` | Pull public sans auth |
| `publicNetworkAccess` | `Enabled` | Accès réseau public |
| `enableRetentionPolicy` | `false` | Nettoyage images non-taguées *(Premium)* |
| `retentionPolicyDays` | `7` | Durée rétention en jours |
| `enableSoftDelete` | `false` | Corbeille pour les images supprimées |
| `zoneRedundancy` | `false` | Redondance de zone *(Premium)* |
| `dataEndpointEnabled` | `false` | Endpoint dédié par région *(Premium)* |

## Scope Maps incluses

| Nom | Permissions |
|---|---|
| `_repositories_admin` | Lecture + écriture + suppression |
| `_repositories_pull` | Pull uniquement |
| `_repositories_pull_metadata_read` | Pull + lecture métadonnées |
| `_repositories_push` | Push + pull |
| `_repositories_push_metadata_write` | Push + pull + écriture métadonnées |

## Connexion AKS → ACR

La méthode recommandée est via l'identité managée (sans secrets) :

```bash
az aks update --resource-group <rg> --name <cluster> --attach-acr <registryName>
```

Cela assigne automatiquement le rôle `AcrPull` à l'identité kubelet du cluster.
