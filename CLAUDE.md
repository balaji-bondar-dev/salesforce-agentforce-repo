# Project Context: Salesforce DX Application

## Core Commands
- Build / Validate: `sf project deploy start --dry-run`
- Deploy to Default Org: `sf project deploy start`
- Run All Local Tests: `sf apex run test --result-format human`
- Run Specific Test: `sf apex run test --class-names <ClassName> --result-format human`
- Retrieve Metadata: `sf project retrieve start`
- View Org Status: `sf org display`

## Salesforce Architecture & Guardrails
- **Metadata Root**: Always look in and write to `force-app/main/default/`.
- **Bulkification**: All Apex code MUST be fully bulkified. Never handle singular SObjects when lists or triggers can act in batches.
- **Governor Limits**: Never execute SOQL queries, DML operations, or Async requests inside loops.
- **Hardcoded IDs**: NEVER use hardcoded Salesforce Record IDs (e.g., '001...'). Utilize Custom Metadata, Developer Names, or Schema describes.
- **Null Safety**: Always check for empty lists and null fields before performing operations or indexing collections.

## Apex Style & Standards
- **Naming Conventions**: 
  - Classes: PascalCase (e.g., `AccountTriggerHandler`)
  - Variables/Methods: camelCase (e.g., `updateOpportunityStage`)
  - Constants: UPPER_CASE (e.g., `MAX_RETRY_ATTEMPTS`)
- **Trigger Pattern**: Enforce a one-trigger-per-object design. Route all logic through a modern Trigger Handler Framework; no logic directly in the trigger file.
- **SOQL Formatting**: Bind variables strictly with a colon (`:var`). Capitalize keywords (`SELECT`, `FROM`, `WHERE`, `AND`).
- **Error Handling**: Wrap business logic and DML in try-catch blocks. Log exceptions natively or route via an internal logging framework.

## Testing Guardrails
- **Coverage Target**: Aim for 100% code coverage; minimum required is 85% with all critical business path assertions handled.
- **Test Data Isolation**: Do NOT use `@isTest(SeeAllData=true)`. Build or utilize a test data factory class to generate mock records.
- **Assertions**: Always use the modern `Assert` class (e.g., `Assert.areEqual()`, `Assert.isTrue()`) instead of the legacy `System.assert()`.
- **Integrations**: Mock all HTTP callouts using the `HttpCalloutMock` interface.

## LWC Guidelines
- **Framework**: Use modern ES modules and strict JavaScript/TypeScript guidelines.
- **Styling**: Adhere strictly to the Salesforce Lightning Design System (SLDS). Do not override with hardcoded hex colors or pixels.
- **Wire Service**: Prefer `@wire` adapters for reading data. Explicitly import schema object/field references instead of writing string paths.
