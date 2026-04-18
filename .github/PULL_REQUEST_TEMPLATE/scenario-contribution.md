---
name: Scenario Contribution
about: Submit a new demo scenario to the project
labels: new-scenario
---

## Scenario Overview

<!-- Provide a brief description of the demo scenario and its target audience -->

**Project folder**: `scenario/{project-name}/`
**Industry**: <!-- e.g., Healthcare, Retail, Finance, Education -->

## Architecture

<!-- List the Azure services used in this scenario -->

| Service | SKU | Purpose |
| ------- | --- | ------- |
|         |     |         |

## Artifact Checklist

### Required

- [ ] `01-requirements.md` — Structured business requirements
- [ ] `02-architecture-assessment.md` — Service recommendations and trade-offs
- [ ] `infra/main.bicep` + modules — Bicep templates
- [ ] `azure.yaml` — Azure Developer CLI project definition (name: `tdd-azd-{project}`)
- [ ] `README.md` — Quick-start guide for scenario users

### Recommended

- [ ] `03-architect-diagram.py` + `.png` — Architecture diagram
- [ ] `03-architect-runtime-diagram.py` + `.png` — Runtime flow diagram
- [ ] `03-architect-adr.md` — Architecture Decision Records
- [ ] `04-implementation-plan.md` — Step-by-step deployment plan
- [ ] `05-implementation-reference.md` — Code patterns and config reference
- [ ] `06-deployment-summary.md` — Post-deployment validation results
- [ ] `07-webapp-summary.md` — Sample webapp details (if applicable)
- [ ] `demoguide/demoguide.md` — Demo runbook with talking points
- [ ] `demoguide/images/*.png` — Screenshots of deployed resources
- [ ] `src/` — Sample web application source code (if applicable)

## Deployment Status

<!-- Choose one -->

- [ ] **Verified** — Successfully deployed and validated via `azd up`
- [ ] **Not deployed** — Templates are ready but not tested in a live subscription

## Sensitive Data Confirmation

- [ ] No `.azure/` deployment state files included
- [ ] No `.env` or secret files included
- [ ] No `bin/`, `obj/`, or `publish/` build outputs included
- [ ] No `applogs/` or `*.zip` archives included

## Reviewer Guidance

1. Verify Bicep templates lint cleanly: `az bicep build -f scenario/{project}/infra/main.bicep`
2. Check `azure.yaml` follows the naming convention: `name: tdd-azd-{project}`
3. Run `azd up` in a test subscription to validate end-to-end deployment
4. Review the demo guide for completeness and accuracy
5. Confirm no sensitive data or deployment state is included
