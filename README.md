# Kit de survie DevOps Azure

> **Exercice pratique** — Configuration de mon premier cluster AKS et déploiement d'applications conteneurisées sur Azure Kubernetes Service.

---

## Objectif

Ce projet est un exercice d'apprentissage dont le but est de se familiariser avec les outils et concepts fondamentaux du DevOps Azure, en passant par la création et l'opération d'un cluster AKS réel.

Il regroupe trois antisèches interactives (HTML) couvrant les commandes et fichiers de configuration essentiels pour opérer un cluster Kubernetes sur Azure et déployer de l'infrastructure as code.

---

## Contenu du projet

```
.
├── index.html                   # Page d'accueil — navigation entre les antisèches
├── aks-kubectl-cheatsheet.html  # Antisèche kubectl / AKS
├── iac-bicep-terraform.html     # Antisèche Bicep & Terraform
└── README.md                    # Ce fichier
```

### `aks-kubectl-cheatsheet.html`
Commandes `kubectl` et `az aks` organisées par catégorie :
- Connexion et gestion du contexte kubeconfig
- Inspection des ressources (pods, deployments, services, nodes)
- Diagnostic et dépannage (logs, exec, events)
- Cycle de vie des pods (restart, scale, rollback, force delete)
- Déploiement de services et containers
- **Registry & mise à jour d'image** — flux complet ACR → AKS
- Réseau, Ingress, HPA, PVC
- Glossaire des termes Kubernetes (31 termes)

### `iac-bicep-terraform.html`
Commandes et fichiers de configuration pour l'infrastructure as code :
- **Bicep** : compilation, déploiement, what-if, modules, paramétrage avancé
- **Terraform** : init, plan, apply, gestion du state, workspaces, modules
- 5 scénarios Bicep avec fichiers commentés (`main.bicep`, `.bicepparam`, modules)
- 5 scénarios Terraform avec fichiers commentés (`main.tf`, `variables.tf`, `backend.tf`, `.tfvars`)
- Glossaire IaC (24 termes)

---

## Ce que cet exercice couvre

### Kubernetes / AKS
- Création et connexion à un cluster AKS (`az aks create`, `az aks get-credentials`)
- Déploiement d'applications via manifestes YAML
- Gestion du cycle de vie des pods et des déploiements (rolling update, rollback)
- Exposition de services via LoadBalancer Azure
- Débogage d'erreurs courantes : `CrashLoopBackOff`, `ImagePullBackOff`, permissions nginx, rolling update bloqué
- Intégration avec Azure Container Registry (ACR) pour le push et le redéploiement d'images

### Infrastructure as Code
- Rédaction de templates Bicep avec paramètres typés et decorators de validation
- Configuration d'un backend Terraform sur Azure Blob Storage
- Organisation multi-environnements (dev / staging / prod) via fichiers de variables
- Extraction de ressources en modules réutilisables

---

## Problèmes rencontrés et résolus

| Problème | Cause | Solution |
|---|---|---|
| Rolling update bloqué (`pending termination`) | Nouveau pod `0/1` — readiness probe échoue | Identifier la cause avec `kubectl describe` + `logs --previous` |
| `Permission denied` sur `index.html` (nginx) | Fichier appartenant à root, container non-root | `chmod 755` + `chown nginx:nginx` dans le Dockerfile |
| `CrashLoopBackOff` sur `exam-prep` | Erreur au démarrage de l'application | `kubectl logs --previous` pour voir les logs du container crashé |

---

## Prérequis

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.5
- [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) (`az bicep install`)
- Un abonnement Azure actif

---

## Références

- [Documentation AKS](https://learn.microsoft.com/azure/aks/)
- [Documentation Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Documentation Terraform AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [kubectl Cheat Sheet officiel](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
