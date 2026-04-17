# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Local development (generates entry point and starts CDS watch with browser)
npm run start-local

# CDS watch only (no entry point generation)
npm run cds-watch

# Watch UI app directly
npm run watch-riskmanagement.risks

# Production start
npm start
```

In development, authentication is bypassed (`dummy` auth). In production, XSUAA is required.

## Architecture

This is a **SAP CAP (Cloud Application Programming Model)** project with a SAPUI5 Fiori Elements frontend, deployed to SAP BTP.

### Data Model (`db/schema.cds`)
Two entities in the `RiskManagement` namespace:
- **Risks** — has `title`, `prioi` (priority), `descr`, `impact`, `criticality`, and associations to one `Mitigation` and one external `BusinessPartner` (supplier)
- **Mitigations** — has `createdAT`, `createdBy`, `description`, `owner`, `timeline`, and a back-association to many Risks

### Service Layer (`srv/`)
- `service.cds` — Exposes `RiskManagementService` at `/service/RiskManagementService`. Both `Risks` and `Mitigations` have OData draft enabled. Authorization: `RiskViewer` can READ, `RiskManager` has full access. Requires `authenticated-user`.
- `service.js` — Custom handlers for external Business Partner (BP) integration:
  - `BusinessPartners` reads are delegated directly to the `API_BUSINESS_PARTNER` external OData v2 service.
  - `Risks` reads call `next()` (local DB), then attach BP data from the external service for each risk with a `supplier_BusinessPartner` value.

### External API Integration
- Uses SAP S/4HANA `API_BUSINESS_PARTNER` (OData v2) configured in `package.json`
- In development, the local CSV fixtures in `db/data/` are used (including mock BP data)
- In production, connects to `https://sandbox.api.sap.com/s4hanacloud/...` with an API key

### Frontend (`app/riskmanagement.risks/`)
- SAPUI5 Fiori Elements application using `sap.fe.templates.ListReport` + `sap.fe.templates.ObjectPage`
- UI annotations (list columns, form fields, value help for Mitigations and BusinessPartners) are defined in `app/riskmanagement.risks/annotations.cds`
- The `app/services.cds` file simply re-exports the annotations

### Authorization / Security
- `xs-security.json` defines two XSUAA roles: `RiskViewer` (read-only) and `RiskManager` (full CRUD)
- Development uses dummy auth — no roles are enforced locally unless explicitly tested
- Production uses XSUAA + HANA (configured via `[production]` profile in `package.json`)
