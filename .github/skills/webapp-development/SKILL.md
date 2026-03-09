---
name: webapp-development
description: ".NET 10 C# sample web application scaffolding patterns, industry-specific seed data templates, Dockerfile generation, and azd service wiring for demo workload scenarios."
compatibility: Works with Claude Code, GitHub Copilot, VS Code, and any Agent Skills compatible tool.
license: MIT
metadata:
  author: petender
  version: "1.0"
  category: webapp-development
---

# Webapp Development Skill

Patterns and templates for scaffolding .NET 10 C# sample web applications
with industry-specific local data for Azure demo scenarios. Covers project
structure, seed data generation, container support, and azd integration.

---

## 1. Project Structure

Every sample webapp follows this layout:

```text
scenario/{project}/src/{ProjectName}.Web/
├── {ProjectName}.Web.csproj
├── Program.cs
├── appsettings.json
├── appsettings.Development.json
├── Dockerfile                    # Container targets only
├── .dockerignore                 # Container targets only
├── Models/
│   ├── {Entity1}.cs
│   ├── {Entity2}.cs
│   └── {Entity3}.cs
├── Services/
│   └── SampleDataService.cs
├── SeedData/
│   ├── {entity1}s.json
│   ├── {entity2}s.json
│   └── {entity3}s.json
├── Pages/
│   ├── Index.cshtml
│   ├── Index.cshtml.cs
│   ├── {Entity1}/
│   │   ├── Index.cshtml
│   │   ├── Index.cshtml.cs
│   │   ├── Details.cshtml
│   │   └── Details.cshtml.cs
│   ├── {Entity2}/
│   │   └── ... (same pattern)
│   └── Shared/
│       ├── _Layout.cshtml
│       └── _ViewImports.cshtml
└── wwwroot/
    ├── css/
    │   └── site.css
    └── lib/
```

### Naming Conventions

| Element        | Convention                  | Example              |
| -------------- | --------------------------- | -------------------- |
| Project folder | `{PascalCase}.Web`          | `HealthcareDemo.Web` |
| Model classes  | PascalCase singular         | `Patient`, `Doctor`  |
| Seed files     | camelCase plural `.json`    | `patients.json`      |
| Pages folders  | PascalCase plural of entity | `Pages/Patients/`    |
| Service class  | `SampleDataService`         | Always this name     |

---

## 2. Industry Data Templates

### Healthcare

**Models:**

```csharp
public class Doctor
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Specialty { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
}

public class Patient
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public string BloodType { get; set; } = string.Empty;
    public int DoctorId { get; set; }
}

public class Appointment
{
    public int Id { get; set; }
    public int PatientId { get; set; }
    public int DoctorId { get; set; }
    public DateTime ScheduledAt { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Status { get; set; } = "Scheduled";
}
```

**Seed data** (`doctors.json` excerpt):

```json
[
  {
    "Id": 1,
    "Name": "Dr. Sarah Chen",
    "Specialty": "Cardiology",
    "Email": "s.chen@clinic.local",
    "Phone": "555-0101"
  },
  {
    "Id": 2,
    "Name": "Dr. James Wilson",
    "Specialty": "Neurology",
    "Email": "j.wilson@clinic.local",
    "Phone": "555-0102"
  }
]
```

### Retail

**Models:** `Product`, `Category`, `Order`

```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public int StockQuantity { get; set; }
}

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}

public class Order
{
    public int Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = "Pending";
    public List<int> ProductIds { get; set; } = new();
}
```

### Finance

**Models:** `Account`, `Transaction`, `Customer`

```csharp
public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime MemberSince { get; set; }
}

public class Account
{
    public int Id { get; set; }
    public int CustomerId { get; set; }
    public string AccountType { get; set; } = "Checking";
    public decimal Balance { get; set; }
    public string Currency { get; set; } = "USD";
}

public class Transaction
{
    public int Id { get; set; }
    public int AccountId { get; set; }
    public DateTime Date { get; set; }
    public decimal Amount { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}
```

### Education

**Models:** `Student`, `Course`, `Enrollment`

### Hospitality

**Models:** `Room`, `Guest`, `Reservation`

### Logistics

**Models:** `Shipment`, `Warehouse`, `Driver`

### Real Estate

**Models:** `Property`, `Agent`, `Listing`

### Manufacturing

**Models:** `Product`, `WorkOrder`, `Machine`

> For industries not listed: derive 2-4 entities from the project description,
> following the same patterns (Id, Name, descriptive fields, status fields).

---

## 3. Data Service Pattern

The `SampleDataService` loads JSON seed data at startup and serves it in-memory.

```csharp
using System.Text.Json;

public class SampleDataService
{
    private readonly IWebHostEnvironment _env;

    public SampleDataService(IWebHostEnvironment env)
    {
        _env = env;
    }

    public List<T> Load<T>(string fileName)
    {
        var path = Path.Combine(_env.ContentRootPath, "SeedData", fileName);
        if (!File.Exists(path))
            return new List<T>();

        var json = File.ReadAllText(path);
        return JsonSerializer.Deserialize<List<T>>(json, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        }) ?? new List<T>();
    }
}
```

**Registration in `Program.cs`:**

```csharp
builder.Services.AddSingleton<SampleDataService>();
```

---

## 4. Program.cs Template

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages();
builder.Services.AddSingleton<SampleDataService>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}

app.UseStaticFiles();
app.UseRouting();
app.MapRazorPages();

app.Run();
```

---

## 5. Dockerfile Pattern (Container Targets)

Multi-stage build for minimal image size:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "{ProjectName}.Web.dll"]
```

`.dockerignore`:

```text
**/.git
**/.vs
**/bin
**/obj
**/node_modules
**/.idea
Dockerfile
.dockerignore
```

---

## 6. azd Service Wiring

### App Service Target

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

### Container Apps Target

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

### AKS Target

```yaml
services:
  web:
    project: ./src/{ProjectName}.Web
    host: aks
    language: csharp
    docker:
      path: ./src/{ProjectName}.Web/Dockerfile
```

### ACI Target

```yaml
services:
  web:
    project: ./src/{ProjectName}.Web
    host: aci
    language: csharp
    docker:
      path: ./src/{ProjectName}.Web/Dockerfile
```

> [!IMPORTANT]
> The `host` field determines how `azd deploy` packages and deploys the app.
> For `appservice`, azd uses `dotnet publish` + zip deploy.
> For container hosts, azd builds the Docker image and pushes to ACR.

---

## 7. Razor Page Patterns

### Entity List Page

```csharp
// Pages/{Entity}/Index.cshtml.cs
public class IndexModel : PageModel
{
    private readonly SampleDataService _dataService;

    public IndexModel(SampleDataService dataService)
    {
        _dataService = dataService;
    }

    public List<{Entity}> Items { get; set; } = new();

    public void OnGet()
    {
        Items = _dataService.Load<{Entity}>("{entity}s.json");
    }
}
```

### Entity Details Page

```csharp
// Pages/{Entity}/Details.cshtml.cs
public class DetailsModel : PageModel
{
    private readonly SampleDataService _dataService;

    public DetailsModel(SampleDataService dataService)
    {
        _dataService = dataService;
    }

    public {Entity}? Item { get; set; }

    public IActionResult OnGet(int id)
    {
        var items = _dataService.Load<{Entity}>("{entity}s.json");
        Item = items.FirstOrDefault(x => x.Id == id);
        if (Item == null)
            return NotFound();
        return Page();
    }
}
```

---

## 8. Homepage Dashboard

The `Pages/Index.cshtml` should show a dashboard with:

- Project name and industry context
- Navigation cards for each entity type
- Quick stats (total counts per entity)
- A brief description of the demo scenario

---

## 9. Guardrails

- **DO**: Always use .NET 10 (`net10.0`)
- **DO**: Keep seed data realistic but fictional (no real PII)
- **DO**: Use 10-20 records per entity for meaningful demo data
- **DO**: Include `SeedData/` folder in published output (copy to output)
- **DO**: Validate with `dotnet build` before proceeding
- **DON'T**: Add authentication to the sample app (keep it simple for demos)
- **DON'T**: Use Entity Framework or external databases
- **DON'T**: Add unnecessary NuGet packages
- **DON'T**: Include real personal data in seed files
- **DON'T**: Generate more than 4 entity types (keep demos focused)
