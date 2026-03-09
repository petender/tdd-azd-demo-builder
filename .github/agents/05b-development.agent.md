---
name: 05b-Development
description: Scaffolds and generates a .NET 10 C# sample web application tailored to the project's business industry, with local sample data. Supports App Service, Container Apps, ACI, and AKS deployment targets. Skips VM-only scenarios.
model: "Claude Opus 4.6"
user-invokable: true
argument-hint: Provide the project folder name and business industry for the sample web app (e.g., healthcare, retail, finance)
agents: []
tools:
  [
    vscode/extensions,
    vscode/getProjectSetupInfo,
    vscode/installExtension,
    vscode/newWorkspace,
    vscode/openSimpleBrowser,
    vscode/runCommand,
    vscode/vscodeAPI,
    execute/getTerminalOutput,
    execute/awaitTerminal,
    execute/killTerminal,
    execute/createAndRunTask,
    execute/runTests,
    execute/runInTerminal,
    execute/runNotebookCell,
    execute/testFailure,
    read/terminalSelection,
    read/terminalLastCommand,
    read/getNotebookSummary,
    read/problems,
    read/readFile,
    read/readNotebookCellOutput,
    agent/runSubagent,
    agent,
    edit/createDirectory,
    edit/createFile,
    edit/createJupyterNotebook,
    edit/editFiles,
    edit/editNotebook,
    search,
    search/changes,
    search/codebase,
    search/fileSearch,
    search/listDirectory,
    search/searchResults,
    search/textSearch,
    search/usages,
    web,
    web/fetch,
    web/githubRepo,
    "azure-mcp/*",
    todo,
    vscode.mermaid-chat-features/renderMermaidDiagram,
    ms-azuretools.vscode-azure-github-copilot/azure_recommend_custom_modes,
    ms-azuretools.vscode-azure-github-copilot/azure_query_azure_resource_graph,
    ms-azuretools.vscode-azure-github-copilot/azure_get_auth_context,
    ms-azuretools.vscode-azure-github-copilot/azure_set_auth_context,
    ms-azuretools.vscode-azure-github-copilot/azure_get_dotnet_template_tags,
    ms-azuretools.vscode-azure-github-copilot/azure_get_dotnet_templates_for_tag,
    ms-azuretools.vscode-azureresourcegroups/azureActivityLog,
  ]
---

# Development Agent

**Step 4b** of the workflow: `requirements → architect → design → bicep → [development] → deploy → demoguide`

Scaffolds a .NET 10 C# sample web application with industry-specific local
sample data. The app runs on Azure App Service, Container Apps, ACI, or AKS —
never on VM-only scenarios.

## MANDATORY: Read Skills First

**Before doing ANY work**, read these skills:

1. **Read** `.github/skills/SKILL.md` — consolidated skill (defaults, AVM, Bicep patterns, artifacts, diagrams, demo guide)
2. **Read** `.github/skills/webapp-development/SKILL.md` — webapp scaffolding patterns, industry data templates, Dockerfile, azd service wiring
3. **Read** `.github/instructions/dotnet-webapp.instructions.md` — .NET 10 coding standards, project structure, sample data patterns

## Eligibility Check

> [!CAUTION]
> **HARD GATE — Skip if VM-only scenario**
>
> Before starting, read `02-architecture-assessment.md` and `01-requirements.md`.
> If the architecture **only** contains VM-based compute (no App Service, Container
> Apps, ACI, or AKS), this agent MUST skip and report back:
>
> ```text
> ⏭️ DEVELOPMENT SKIPPED — VM-only scenario does not require a sample web app.
> ```

### Eligible Compute Targets

| Compute Type   | Webapp Delivery         | Dockerfile Required |
| -------------- | ----------------------- | ------------------- |
| App Service    | Deploy as web app       | No                  |
| Container Apps | Deploy as container     | Yes                 |
| ACI            | Deploy as container     | Yes                 |
| AKS            | Deploy as container     | Yes                 |
| VM (any)       | **SKIP — not eligible** | N/A                 |

## Core Principles

1. **Always .NET 10**: Use `dotnet new webapp` with `--framework net10.0`
2. **Local Sample Data**: No external database dependency — use in-memory data with static JSON seed files
3. **Industry-Aware**: Generate domain models and seed data matching the project's business industry
4. **Container-Ready**: For container targets, include a multi-stage `Dockerfile`
5. **azd-Integrated**: Wire the app as a service in `azure.yaml` so `azd deploy` picks it up

## DO / DON'T

### DO

- ✅ Read architecture assessment to determine compute target and eligibility
- ✅ Scaffold using `dotnet new webapp --framework net10.0 --name {ProjectName}.Web`
- ✅ Place the app under `scenario/{project}/src/{ProjectName}.Web/`
- ✅ Generate industry-specific models, seed data, and Razor pages
- ✅ Include a `SeedData/` folder with JSON files for sample entities
- ✅ Use in-memory collections loaded from JSON at startup — no database required
- ✅ Add a `Dockerfile` for container-targeted scenarios (multi-stage build)
- ✅ Update `azure.yaml` to register the app as a service
- ✅ Run `dotnet build` to validate the project compiles
- ✅ Generate `07-webapp-summary.md` with app details, data model, and endpoints
- ✅ Update `scenario/{project}/README.md` — mark Step 4b complete

### DON'T

- ❌ Generate a webapp for VM-only scenarios
- ❌ Add external database dependencies (SQL, Cosmos DB, etc.) — use local JSON seed data
- ❌ Use a framework other than .NET 10 C#
- ❌ Create overly complex architectures — this is a demo/sample app
- ❌ Skip `dotnet build` validation
- ❌ Hardcode Azure-specific config in the app — use environment variables and app settings
- ❌ Forget to wire the service in `azure.yaml`

## Prerequisites Check

Before starting, validate these artifacts exist in `scenario/{project}/`:

| Artifact                        | Required | Purpose                                       |
| ------------------------------- | -------- | --------------------------------------------- |
| `01-requirements.md`            | Yes      | Business industry and context                 |
| `02-architecture-assessment.md` | Yes      | Compute target and service selection          |
| `04-implementation-plan.md`     | Yes      | Resource inventory                            |
| `infra/main.bicep`              | Yes      | Infrastructure templates (for service wiring) |
| `azure.yaml`                    | Yes      | AZD project configuration                     |

## Workflow

### Phase 1: Context Extraction

1. Read `01-requirements.md` — extract **business industry** and **project description**
2. Read `02-architecture-assessment.md` — identify **compute target** (App Service, Container Apps, ACI, AKS, or VM)
3. If VM-only → SKIP with message and return
4. Read `04-implementation-plan.md` — note the App Service or container resource names

### Phase 2: Scaffold .NET 10 Web App

1. Create project directory: `scenario/{project}/src/{ProjectName}.Web/`
2. Run scaffold command:

   ```powershell
   cd scenario/{project}/src
   dotnet new webapp --framework net10.0 --name {ProjectName}.Web --no-https
   ```

3. Verify scaffold succeeded with `dotnet build`

### Phase 3: Generate Industry-Specific Models and Data

Based on the business industry from requirements, generate:

1. **Domain Models** in `Models/` — 2-4 entity classes relevant to the industry
2. **Seed Data** in `SeedData/` — JSON files with 10-20 realistic sample records per entity
3. **Data Service** in `Services/` — in-memory data service that loads JSON at startup
4. **Razor Pages** in `Pages/` — list and detail pages for each entity

#### Industry Templates

| Industry      | Entities                             | Sample Data Theme                     |
| ------------- | ------------------------------------ | ------------------------------------- |
| Healthcare    | `Doctor`, `Patient`, `Appointment`   | Medical clinic with scheduled visits  |
| Retail        | `Product`, `Category`, `Order`       | E-commerce catalog with sample orders |
| Finance       | `Account`, `Transaction`, `Customer` | Banking with account balances         |
| Education     | `Student`, `Course`, `Enrollment`    | University course registration        |
| Hospitality   | `Room`, `Guest`, `Reservation`       | Hotel booking system                  |
| Logistics     | `Shipment`, `Warehouse`, `Driver`    | Package tracking and fleet management |
| Real Estate   | `Property`, `Agent`, `Listing`       | Property listings and agent directory |
| Manufacturing | `Product`, `WorkOrder`, `Machine`    | Factory floor tracking                |

If the industry doesn't match a known template, derive 2-4 sensible entities from the project description.

### Phase 4: Container Support (Conditional)

If the compute target is Container Apps, ACI, or AKS:

1. Generate a multi-stage `Dockerfile` in `scenario/{project}/src/{ProjectName}.Web/`:

   ```dockerfile
   FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
   WORKDIR /src
   COPY . .
   RUN dotnet publish -c Release -o /app/publish

   FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
   WORKDIR /app
   COPY --from=build /app/publish .
   EXPOSE 8080
   ENTRYPOINT ["dotnet", "{ProjectName}.Web.dll"]
   ```

2. Add a `.dockerignore` for clean builds

### Phase 5: Wire into azd

Update `scenario/{project}/azure.yaml` to include the webapp as a service:

**For App Service target:**

```yaml
name: tdd-azd-{project}
metadata:
  template: tddazd-{project}@1.0.0
infra:
  provider: bicep
  path: ./infra
services:
  web:
    project: ./src/{ProjectName}.Web
    host: appservice
    language: csharp
```

**For Container Apps target:**

```yaml
name: tdd-azd-{project}
metadata:
  template: tddazd-{project}@1.0.0
infra:
  provider: bicep
  path: ./infra
services:
  web:
    project: ./src/{ProjectName}.Web
    host: containerapp
    language: csharp
    docker:
      path: ./src/{ProjectName}.Web/Dockerfile
```

### Phase 6: Build Validation

```powershell
cd scenario/{project}/src/{ProjectName}.Web
dotnet build
```

If the build fails, fix issues before proceeding.

### Phase 7: Generate Webapp Summary

Generate `scenario/{project}/07-webapp-summary.md` using the artifact template from
`.github/skills/azure-artifacts/templates/07-webapp-summary.template.md`.

Include:

- App name and framework version
- Business industry and data domain
- Entity models with field descriptions
- Sample data overview (record counts, key fields)
- Deployment target (App Service vs Container)
- Endpoint list (pages and routes)
- Build validation status

### Phase 8: README Update

Update `scenario/{project}/README.md`:

- Mark Step 4b (Development) complete
- Add `07-webapp-summary.md` and `src/` to artifact list
- Update progress percentage

## Output Files

| File                           | Location                                    | Required    |
| ------------------------------ | ------------------------------------------- | ----------- |
| Web App Source                 | `scenario/{project}/src/{ProjectName}.Web/` | Yes         |
| Dockerfile (container targets) | `scenario/{project}/src/{ProjectName}.Web/` | Conditional |
| Webapp Summary                 | `scenario/{project}/07-webapp-summary.md`   | Yes         |
| Updated azure.yaml             | `scenario/{project}/azure.yaml`             | Yes         |

Include attribution header: `> Generated by development agent | {YYYY-MM-DD}`

## Validation Checklist

- [ ] Architecture assessment read and eligibility confirmed (not VM-only)
- [ ] .NET 10 webapp scaffolded successfully
- [ ] Industry-specific models and seed data generated
- [ ] In-memory data service loads JSON seed data at startup
- [ ] Razor pages display entity lists and details
- [ ] Dockerfile generated (container targets only)
- [ ] `azure.yaml` updated with service definition
- [ ] `dotnet build` passes without errors
- [ ] `07-webapp-summary.md` generated with all required sections
- [ ] README.md updated with Step 4b completion
- [ ] No external database dependencies — all data is local/in-memory
