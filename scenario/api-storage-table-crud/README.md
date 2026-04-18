<!-- markdownlint-disable MD033 MD041 -->

# 🏗️ API Storage Table CRUD

**A Web API demo solution hosted on Azure App Service (.NET 10, Linux) that performs full CRUD operations against Azure Storage Table for logistics data (shipments, packages, tracking). Includes Swagger UI for interactive API testing, managed identity for keyless storage access, and Application Insights + Log Analytics for monitoring.**

💪 This template scenario is part of the larger [Microsoft Trainer Demo Deploy Catalog](https://aka.ms/trainer-demo-deploy).

---

## ⬇️ Installation

[Azure Developer CLI - AZD](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
When installing AZD, the following tools will be installed on your machine as well, if not already installed:

- [GitHub CLI](https://cli.github.com/)
- [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

You need Owner or Contributor access permissions to an Azure Subscription to deploy the scenario.

## 🚀 Deploying the scenario in 4 steps

1. Create a new folder on your machine.

```shell
mkdir api-storage-table-crud
```

2. Next, navigate to the new folder.

```shell
cd api-storage-table-crud
```

3. Next, run azd init to initialize the deployment.

```shell
azd init -t <your-repo-link>
```

4. Last, run azd up to trigger an actual deployment.

```shell
azd up
```

⏩ Note: you can delete the deployed scenario from the Azure Portal, or by running `azd down` from within the initiated folder.

## What is the demo scenario about?

A .NET 10 Web API application hosted on Azure App Service that demonstrates full CRUD operations (Create, Read, Update, Delete) against Azure Storage Table. The dataset models logistics-industry entities — shipments, packages, and tracking events. The API includes Swagger UI and OpenAPI specification for interactive testing. Managed identity provides keyless, secure access from App Service to Storage Table. Application Insights and Log Analytics deliver end-to-end monitoring and diagnostics.

## 📋 Project Summary

| Property         | Value      |
| ---------------- | ---------- |
| **Created**      | 2026-03-08 |
| **Last Updated** | 2026-03-08 |
| **Region**       | `eastus2`  |
| **Environment**  | Demo       |

## 📊 Progress

| Step | Artifact                        | Status      |
| ---- | ------------------------------- | ----------- |
| 1    | 01-requirements.md              | ✅ Complete |
| 2    | 02-architecture-assessment.md   | ✅ Complete |
| 3    | 03-architect-diagram.py         | ✅ Complete |
| 3    | 03-architect-runtime-diagram.py | ✅ Complete |
| 4    | 04-implementation-plan.md       | ✅ Complete |
| 4    | 04-dependency-diagram.py/.png   | ✅ Complete |
| 4    | 04-runtime-diagram.py/.png      | ✅ Complete |
| 4    | infra/ (Bicep templates)        | ✅ Complete |
| 4    | 05-implementation-reference.md  | ✅ Complete |
| 4    | azure.yaml                      | ✅ Complete |
| 4b   | Sample .NET 10 Web API          | ⏳ Pending  |
| 5    | 06-deployment-summary.md        | ⏳ Pending  |
| 6    | 08-demo-guide.md                | ⏳ Pending  |

## 🏛️ Architecture

<div align="center">

![Architecture Diagram](./03-architect-diagram.png)

_Source: `03-architect-diagram.py`_

</div>

<div align="center">

![Runtime Flow Diagram](./03-architect-runtime-diagram.png)

_Source: `03-architect-runtime-diagram.py`_

</div>

---

## Feedback and Contributing

If you have feedback or would like to contribute, please open an issue or pull request in the repository.

---
