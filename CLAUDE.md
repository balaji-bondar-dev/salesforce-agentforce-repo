# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project Context: Salesforce DX Application

## Project Snapshot
- **Org alias**: `balajibondar@gmail.com.agentforce` (production-shape org, not a scratch org).
- **API version**: `66.0` (Spring '26). Set in `sfdx-project.json` (`sourceApiVersion`).
- **Track**: Agentforce / MCP — note the `MCP*` Apex classes and the `agentforce` token in the project name. This is a *persona* / agent surface, not a generic data-model project.
- **Default package dir**: `force-app/main/default/`. The repo is a single-package, source-tracked project (no `packageDirectories` array beyond `force-app`).

## Core Commands
- Build / Validate: `sf project deploy start --dry-run`
- Deploy to Default Org: `sf project deploy start`
- Run All Local Tests: `sf apex run test --result-format human`
- Run Specific Test: `sf apex run test --class-names <ClassName> --result-format human`
- Run Specific Test (code coverage): `sf apex run test --class-names <ClassName> --result-format human --code-coverage`
- Retrieve Metadata: `sf project retrieve start`
- View Org Status: `sf org display`
- Open Org: `sf org open`

**Tip:** `sf project deploy start --dry-run` is the canonical feedback loop — run it after every non-trivial change before considering work "done." A `Status: Succeeded` line at the bottom is the success signal; the spinner lines above it can be ignored.

## Deploy Ordering Gotcha
Custom fields referenced by a flow's assignment must be **deployed before the flow** in separate `sf project deploy start` calls. The metadata API validates field references at deploy time, not in `--dry-run`, and packaging them together fails with `missing the associated {1} field`. Deploy fields as their own package, then the flow, when adding a new field that a flow references.

## Codebase Map — What's Project-Specific vs. Boilerplate

The repo ships with the **Salesforce Experience Cloud (Communities) site template** plus a small set of business Apex. Most files under `force-app/main/default/` are *unmodified* template scaffolding and should usually not be edited:

- **Template scaffolding — do not edit unless asked:**
  - `aura/` — `forgotPassword`, `loginForm`, `selfRegister`, `setExpId`, `setStartUrl` Aura components
  - `pages/` — Communities Visualforce pages (`Communities*`, `SiteLogin`, `SiteRegister*`, `ForgotPassword*`, `Exception*`, `ChangePassword`, `MyProfilePage`, `MicrobatchSelfReg`, `IdeasHome`, `AnswersHome`, `UnderConstruction`, `BandwidthExceeded`, `FileNotFound`, `InMaintenance`, `Unauthorized`, `StdExceptionTemplate`, `SiteTemplate`, `ESWMIAWChannel...`)
  - `components/` — `SiteFooter`, `SiteHeader`, `SiteLogin`, `SitePoweredBy`
  - `staticresources/SiteSamples` — site styling
  - Classes: `*Controller` / `*ControllerTest` pairs for the template pages (`SiteLoginController`, `SiteRegisterController`, `LightningLoginFormController`, `LightningSelfRegisterController`, `LightningForgotPasswordController`, `CommunitiesLandingController`, `CommunitiesLoginController`, `CommunitiesSelfRegController`, `CommunitiesSelfRegConfirmController`, `MicrobatchSelfRegController`, `ChangePasswordController`, `ForgotPasswordController`, `MyProfilePageController`, `AnonymousApexExecution`)
- **Project-specific business code — likely targets for change requests:**
  - `AccountOperations` + `AccountOperationsTest` — `@AuraEnabled` Account lookup
  - `MCPAccountOperations` — MCP-facing variant of the same Account lookup (note: still uses lowercase `string` for the return type — a known lint nit)
  - `MCPCreateCaseController` — `@RestResource` at `/mcp/createCase` for creating Cases (used by MCP/Agentforce)
  - `CaseService` — `@InvocableMethod` returning Case status by CaseNumber (consumed by Agentforce actions)
  - `LeadStatusUpdateBatch` + `LeadStatusUpdateBatchTest` — `Database.Batchable` + `Stateful` job promoting `Open - Not Contacted` → `Working - Contacted`; uses `WITH USER_MODE` and `AccessLevel.USER_MODE` (the project's adopted security mode)
  - `TestDataFactory` — centralized `@isTest` factory (Lead/Account/Contact/Opportunity/User). Use it from every new test class; do not use `SeeAllData=true`.
  - `ExpenseLineItemOperations`, `LoanApplicationOperations`, `WeatherAPICalloutOperations` — domain-specific service classes
- **Flows + custom fields:**
  - `force-app/main/default/flows/Account_Description_Auto_Populate.flow-meta.xml` — record-triggered flow, fires `RecordBeforeSave` on Account insert, populates the `Auto_Populated_Description__c` custom field. **Active** in the org.
  - `force-app/main/default/objects/Account/fields/Auto_Populated_Description__c.field-meta.xml` — Text(255) custom field the flow writes to.
  - **Flow shape note:** the metadata API on this org does NOT accept `<recordTriggerFlow>` as a child of `<Flow>`. Record-triggered flows must be expressed as `processType=AutoLaunchedFlow` with the trigger configuration on `<start>` (`<object>`, `<recordTriggerType>`, `<triggerType>`). Don't introduce `<recordTriggerFlow>` blocks; copy the existing file as a template.

## Salesforce Architecture & Guardrails
- **Metadata Root**: Always look in and write to `force-app/main/default/`.
- **Manifest root**: `manifest/package.xml`. The current manifest uses `<members>*</members>` wildcards against types: `ApexClass`, `CustomField`, `ApexComponent`, `ApexPage`, `ApexTestSuite`, `ApexTrigger`, `Flow`, `AuraDefinitionBundle`, `LightningComponentBundle`, `StaticResource`. When adding a new metadata type, append a new `<types>` block here too (a `Flow` or `ApexTrigger` source file alone is not enough to ship — both the file AND the manifest type entry are required for `--dry-run` / `retrieve` to pick it up).
- **Bulkification**: All Apex code MUST be fully bulkified. Never handle singular SObjects when lists or triggers can act in batches.
- **Governor Limits**: Never execute SOQL queries, DML operations, or Async requests inside loops.
- **Hardcoded IDs**: NEVER use hardcoded Salesforce Record IDs (e.g., '001...'). Utilize Custom Metadata, Developer Names, or Schema describes.
- **Null Safety**: Always check for empty lists and null fields before performing operations or indexing collections.
- **Security mode**: prefer `WITH USER_MODE` in SOQL and `AccessLevel.USER_MODE` on DML (see `LeadStatusUpdateBatch` for the established pattern).
- **LongTextArea fields cannot be flow assignment targets** — the metadata API rejects `assignToReference` pointing at a LongTextArea field (e.g. `Account.Description`). Use a separate Text/TextArea custom field if a flow needs to write a derived value.

## Apex Style & Standards
- **Naming Conventions**:
  - Classes: PascalCase (e.g., `AccountTriggerHandler`)
  - Variables/Methods: camelCase (e.g., `updateOpportunityStage`)
  - Constants: UPPER_CASE (e.g., `MAX_RETRY_ATTEMPTS`)
- **Trigger Pattern**: Enforce a one-trigger-per-object design. Route all logic through a modern Trigger Handler Framework; no logic directly in the trigger file.
- **Record-triggered flows are the preferred automation** for `before insert` / `after insert` style business rules — see `Account_Description_Auto_Populate.flow-meta.xml` for the canonical shape. Default to a new flow over a new Apex trigger for straightforward field derivation.
- **SOQL Formatting**: Bind variables strictly with a colon (`:var`). Capitalize keywords (`SELECT`, `FROM`, `WHERE`, `AND`).
- **Error Handling**: Wrap business logic and DML in try-catch blocks. Log exceptions natively or route via an internal logging framework.
- **`@AuraEnabled` and `@InvocableMethod` methods** should throw `AuraHandledException` (for LWC) or return wrapper collections (for invocable). See `AccountOperations` and `CaseService` for the established patterns.

## Testing Guardrails
- **Coverage Target**: Aim for 100% code coverage; minimum required is 85% with all critical business path assertions handled.
- **Test Data Isolation**: Do NOT use `@isTest(SeeAllData=true)`. Build or utilize the existing `TestDataFactory` class (`force-app/main/default/classes/TestDataFactory.cls`) to generate mock records. Factory methods take a `Boolean doInsert` flag — pass `false` if the test needs to set additional fields before insert.
- **Assertions**: Always use the modern `Assert` class (e.g., `Assert.areEqual()`, `Assert.isTrue()`) instead of the legacy `System.assert()`.
- **Integrations**: Mock all HTTP callouts using the `HttpCalloutMock` interface.
- **Batch tests** should call the `run()` static helper (`LeadStatusUpdateBatch.run()`) and `Test.startTest()` / `Test.stopTest()` around it to scope governor limits.

## LWC Guidelines
- **Framework**: Use modern ES modules and strict JavaScript/TypeScript guidelines.
- **Styling**: Adhere strictly to the Salesforce Lightning Design System (SLDS). Do not override with hardcoded hex colors or pixels.
- **Wire Service**: Prefer `@wire` adapters for reading data. Explicitly import schema object/field references instead of writing string paths.
- The repo has **no LWC bundles yet** (`force-app/main/default/lwc/` does not exist) — `<name>LightningComponentBundle</name>` is in the manifest preemptively. When adding the first LWC, use `sf lightning generate component -n myComponent` or hand-author the directory under `force-app/main/default/lwc/myComponent/` with the standard `myComponent.html / .js / .js-meta.xml` files.
