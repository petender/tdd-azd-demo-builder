---
name: azure-deploy
description: "Deployment patterns, azd usage, rollback procedures, and post-deployment validation for Azure infrastructure projects."
compatibility: Works with Claude Code, GitHub Copilot, VS Code, and any Agent Skills compatible tool.
license: MIT
metadata:
  author: petender
  version: "1.0"
  category: azure-deployment
---

# Azure Deploy Skill

Deployment patterns and procedures for Azure infrastructure provisioned
via Bicep templates and the Azure Developer CLI (azd). Covers the full
deployment lifecycle: pre-flight checks, execution strategies, post-deployment
validation, rollback, and cleanup.

---

## 1. Deployment Strategy Selection

Choose the deployment method based on available project artifacts:

| Method                   | When to Use                                  | Prerequisites                                       |
| ------------------------ | -------------------------------------------- | --------------------------------------------------- |
| **`azd up`** (preferred) | `azure.yaml` exists in `scenario/{project}/` | Azure Developer CLI installed, `az login` completed |

### Decision Tree

```text
azure.yaml exists?
├── YES → Use azd up
└── NO → Generate azure.yaml first, then use azd up
```

---

## 2. Azure Developer CLI (azd) Patterns

### First-Time Setup

```powershell
# Verify azd is installed
azd version

# Initialize environment (first time only)
cd scenario/{project}
azd init

# Set environment name
azd env new {project}-{env}
azd env set AZURE_LOCATION eastus2
```

### azd up — Full Deployment

`azd up` provisions infrastructure AND deploys application code in one step:

```powershell
cd scenario/{project}

# Interactive mode (prompts for subscription, location)
azd up

# Non-interactive mode (CI/CD or automated runs)
azd up --no-prompt
```

### azd provision — Infrastructure Only

When you only need to deploy Bicep templates without application code:

```powershell
# Preview changes before provisioning
azd provision --preview

# Provision infrastructure
azd provision
```

### azd deploy — Application Only

When infrastructure exists and you need to push application code:

```powershell
azd deploy
```

### azure.yaml Structure

The `azure.yaml` file must be in `scenario/{project}/` root:

```yaml
name: tdd-azd-{project}
metadata:
  template: tddazd-{project}@1.0.0
infra:
  provider: bicep
  path: ./infra
```

> [!IMPORTANT]
> The `infra.path` must point to the directory containing `main.bicep`.
> For this project, that's `./infra` (relative to `scenario/{project}/`).

### azd Environment Variables

| Variable                | Purpose               | Example             |
| ----------------------- | --------------------- | ------------------- |
| `AZURE_LOCATION`        | Default Azure region  | `eastus2`           |
| `AZURE_SUBSCRIPTION_ID` | Target subscription   | `xxxxxxxx-xxxx-...` |
| `AZURE_ENV_NAME`        | Environment name      | `dev`               |
| `AZURE_RESOURCE_GROUP`  | Target resource group | `rg-funcsbweb-dev`  |

Set via:

```powershell
azd env set AZURE_LOCATION eastus2
azd env set AZURE_ENV_NAME dev
```

---

## 3. What-If Analysis

### Interpreting What-If Results

| Change Type   | Symbol       | Meaning                               | Action                        |
| ------------- | ------------ | ------------------------------------- | ----------------------------- |
| **Create**    | `+` (green)  | New resource will be created          | Review for expected resources |
| **Delete**    | `-` (red)    | Resource will be removed              | Verify this is intentional    |
| **Modify**    | `~` (purple) | Existing resource will be updated     | Check which properties change |
| **No Change** | `=` (gray)   | Resource exists, no updates needed    | Expected for idempotent runs  |
| **Deploy**    | `!` (yellow) | Resource type doesn't support what-if | Manual verification needed    |

### What-If Best Practices

- Always run what-if before the first deployment to a new environment
- Compare resource counts against the implementation plan
- Flag any unexpected DELETE operations — these may indicate naming changes
- Resources showing `Deploy` (unsupported) need manual validation post-deployment

---

## 4. Post-Deployment Validation

### Resource Existence Check

```powershell
# List all resources in the group
az resource list --resource-group {rg-name} --output table

# Count resources (compare against implementation plan)
az resource list --resource-group {rg-name} --query "length(@)"
```

### Provisioning State Check

```powershell
az resource list `
  --resource-group {rg-name} `
  --query "[].{Name:name, Type:type, State:provisioningState}" `
  --output table
```

All resources should show `Succeeded`. Any `Failed` or `Creating` states require investigation.

### Service-Specific Health Checks

| Service       | Command                                                                                                                 | Expected    |
| ------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------- |
| App Service   | `az webapp show --name {n} --resource-group {rg} --query "state" -o tsv`                                                | `Running`   |
| Function App  | `az functionapp show --name {n} --resource-group {rg} --query "state" -o tsv`                                           | `Running`   |
| Service Bus   | `az servicebus namespace show --name {n} --resource-group {rg} --query "provisioningState" -o tsv`                      | `Succeeded` |
| Key Vault     | `az keyvault show --name {n} --query "properties.provisioningState" -o tsv`                                             | `Succeeded` |
| Storage       | `az storage account show --name {n} --resource-group {rg} --query "provisioningState" -o tsv`                           | `Succeeded` |
| SQL Server    | `az sql server show --name {n} --resource-group {rg} --query "state" -o tsv`                                            | `Ready`     |
| Cosmos DB     | `az cosmosdb show --name {n} --resource-group {rg} --query "provisioningState" -o tsv`                                  | `Succeeded` |
| Container App | `az containerapp show --name {n} --resource-group {rg} --query "properties.provisioningState" -o tsv`                   | `Succeeded` |
| Container Env | `az containerapp env show --name {n} --resource-group {rg} --query "properties.provisioningState" -o tsv`               | `Succeeded` |
| Log Analytics | `az monitor log-analytics workspace show --workspace-name {n} --resource-group {rg} --query "provisioningState" -o tsv` | `Succeeded` |

### Deployment Outputs

```powershell
az deployment group show `
  --resource-group {rg-name} `
  --name {deployment-name} `
  --query "properties.outputs" -o json
```

---

## 5. Rollback Procedures

### Full Rollback (Delete Everything)

```powershell
# Using azd
azd down --force --purge

# Using Azure CLI
az group delete --name {rg-name} --yes --no-wait

# Purge Key Vault soft-deleted vaults (if purge protection is off)
az keyvault purge --name {kv-name} --location {location}
```

### Partial Rollback (Specific Resources)

```powershell
# Delete a specific resource
az resource delete --ids {resource-id}

# Redeploy only failed resources (phased approach)
azd provision
```

### Rollback Decision Tree

```text
Deployment failed?
├── All resources failed
│   └── az group delete (full cleanup)
├── Some resources failed
│   ├── Fix template → redeploy
│   └── Delete failed resources → redeploy
└── Deployment succeeded but misconfigured
    ├── Fix parameters → redeploy (idempotent)
    └── az group delete → redeploy from scratch
```

> [!WARNING]
> Key Vault with purge protection enabled cannot be purged for 7-90 days
> (depending on `softDeleteRetentionInDays`). Plan Key Vault names carefully
> to avoid naming collisions during re-deployments.

---

## 6. Common Deployment Errors

| Error                             | Cause                                      | Fix                                                      |
| --------------------------------- | ------------------------------------------ | -------------------------------------------------------- |
| `AuthorizationFailed`             | Insufficient RBAC permissions              | Assign `Contributor` role on the resource group          |
| `InvalidTemplateDeployment`       | Bicep template has errors                  | Run `bicep build` to find the specific error             |
| `QuotaExceeded`                   | SKU or region quota limit reached          | Use a different SKU or region, or request quota increase |
| `ResourceGroupNotFound`           | RG doesn't exist for RG-scoped deploy      | Create with `az group create` first                      |
| `DeploymentFailed` (nested)       | A module within the template failed        | Check `az deployment operation group list` for details   |
| `NameNotAvailable`                | Globally unique name already taken         | Verify `uniqueSuffix` is applied correctly               |
| `ResourceProviderNotRegistered`   | Service not enabled in subscription        | `az provider register --namespace {ns}`                  |
| `MissingSubscriptionRegistration` | Same as above                              | `az provider register --namespace {ns}`                  |
| `LinkedAuthorizationFailed`       | Cross-scope role assignment failed         | Verify managed identity exists before assigning roles    |
| `Conflict`                        | Resource state doesn't allow the operation | Wait and retry, or delete and recreate                   |

### Detailed Error Investigation

```powershell
# List all deployment operations (shows individual resource failures)
az deployment operation group list `
  --resource-group {rg-name} `
  --name {deployment-name} `
  --query "[?properties.provisioningState=='Failed'].{Resource:properties.targetResource.resourceName, Error:properties.statusMessage.error.message}" `
  --output table
```

---

## 7. Cleanup Patterns

### Demo Teardown

```powershell
# Preferred: azd handles all cleanup including purge-protected resources
azd down --force --purge

# Alternative: delete resource group
az group delete --name {rg-name} --yes --no-wait
```

### Selective Cleanup

```powershell
# Remove specific resources while keeping others
az resource delete --resource-group {rg-name} --name {resource-name} --resource-type {type}
```

> [!TIP]
> Always use `azd down` when possible — it handles soft-deleted resources
> (Key Vault, API Management, Cognitive Services) that `az group delete` doesn't purge.
