---
description: ".NET 10 C# coding standards, project structure, and sample data patterns for demo web applications"
applyTo: "**/*.cs,**/*.csproj,**/Dockerfile"
---

# .NET 10 Web Application Instructions

## Framework Requirements

- **Target framework**: `net10.0` — always use the latest .NET 10
- **Project type**: ASP.NET Core Razor Pages (`dotnet new webapp`)
- **No external database**: All data is loaded from local JSON seed files via in-memory services

## Project Structure

```text
{ProjectName}.Web/
├── {ProjectName}.Web.csproj
├── Program.cs
├── appsettings.json
├── Models/           → Domain entity classes
├── Services/         → SampleDataService (in-memory JSON loader)
├── SeedData/         → JSON files with sample records
├── Pages/            → Razor Pages (Index + per-entity CRUD)
└── wwwroot/          → Static assets (CSS, JS)
```

## Coding Standards

### General

- Use file-scoped namespaces
- Use primary constructors where appropriate
- Prefer `string.Empty` over `""`
- Initialize collection properties with `new()` or `[]`
- Use `required` or `= string.Empty` for non-nullable string properties

### Models

- Every model has an `int Id` property
- Use C# records for immutable data if appropriate
- Keep models flat — no deep object graphs
- Include 2-4 entities per industry domain

### Services

- Register `SampleDataService` as singleton in DI
- Use `System.Text.Json` for deserialization (not Newtonsoft)
- Load seed data lazily on first access
- Handle missing files gracefully (return empty list)

### Razor Pages

- One page model per `.cshtml.cs` file
- Use constructor injection for `SampleDataService`
- Keep page models thin — delegate to service
- Use tag helpers for forms and links

### Seed Data

- JSON files with 10-20 realistic but fictional records
- Use PascalCase property names in JSON (match C# models)
- Include varied data (different statuses, dates, amounts)
- No real personal information — use fictional names and addresses

## .csproj Template

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <Content Include="SeedData\**\*.json" CopyToOutputDirectory="PreserveNewest" />
  </ItemGroup>
</Project>
```

> [!IMPORTANT]
> The `<Content Include="SeedData\...">` entry ensures JSON seed files are
> included in the published output. Without this, `azd deploy` will fail
> to include the data files.

## Dockerfile Requirements (Container Targets)

- Use multi-stage build: SDK image for build, ASP.NET image for runtime
- Base images: `mcr.microsoft.com/dotnet/sdk:10.0` and `mcr.microsoft.com/dotnet/aspnet:10.0`
- Expose port 8080 (ASP.NET Core default in containers)
- Set `ASPNETCORE_URLS=http://+:8080`
- Use `/p:UseAppHost=false` in publish for smaller images

## appsettings.json Template

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

## Anti-Patterns to Avoid

- ❌ Do not use Entity Framework or any ORM
- ❌ Do not add authentication/authorization middleware
- ❌ Do not use `HttpClient` to fetch external data
- ❌ Do not add Swagger/OpenAPI (this is a Razor Pages app, not an API)
- ❌ Do not use `IConfiguration` for seed data paths — use `IWebHostEnvironment.ContentRootPath`
- ❌ Do not add health check endpoints (keep the app minimal)
