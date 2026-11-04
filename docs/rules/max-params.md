---
title: "Limit Method Parameter Count and Keep One Parameter per Line"
description: "Enforce Clean ABAP method parameter limits and multi-line formatting to ensure maintainable signatures, cleaner Git diffs, and testable interfaces."
keywords: "max-params, Clean ABAP, method parameters, SAP ATC, parameter object"
category: "metrics"
ruleId: "max-params"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1409"
---

# Limit Method Parameter Count and Keep One Parameter per Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_PARAMS_COUNT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1409" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Method parameter limits (count and lines).

> **ATC Finding Messages:**
> - `Method signature has too many parameters; consider grouping into structures`
> - `Keep max one method parameter definition per line`

## Rationale

Methods with extensive parameter signatures violate Clean ABAP design principles by obscuring method intent and inflating coupling between callers and providers. In ABAP Cloud and SAP S/4HANA programming (Contract C1), wide parameter lists containing more than 3 to 5 elementary parameters make unit test mocking tedious and increase invocation error rates. Furthermore, declaring multiple parameters on the same line hampers Git line-by-line blame and code review diffs. Grouping related parameters into coherent flat structures or parameter objects streamlines signatures and makes future interface extensions backward compatible without altering method signatures.

### Non-Compliant

```abap
CLASS zcl_billing_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process_invoice
      IMPORTING iv_customer_id TYPE string iv_document_type TYPE string iv_posting_date TYPE d.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_billing_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS process_invoice
      IMPORTING
        is_invoice_request TYPE ty_invoice_request
      RETURNING
        VALUE(rv_invoice_id) TYPE string.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_PARAMETERS` | `Integer` | <code>8</code> | Maximum allowable total method parameters across IMPORTING, EXPORTING, CHANGING, and RETURNING clauses before reporting (default: 8). |
| `CHECK_PARAM_LINE` | `Boolean` | <code>true</code> | Enforce at most one parameter declaration per line in method signatures to ensure readable Git diffs (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_PARAMS_COUNT

" SAP CI_ prefix format:
... "#EC CI_MAX_PARAMS_COUNT
```

## Detection Details

This check inspects method definitions within `CLASS ... DEFINITION` sections (`procedure_kinds-class_definition`) for both instance and static methods (`METHODS` and `CLASS-METHODS`).

| Finding Code | Severity | Description | Suppression |
|---|---|---|---|
| `MAX_PARAMS` | Warning | Total parameter count exceeds `MAX_PARAMETERS` (default 8) | `##MAX_PARAMS_COUNT` or `"#EC MAX_PARAMS_COUNT` |
| `MAX_PARM_L` | Warning | Two or more parameters are declared on the same source code line | `##MAX_PARAMS_LINE` or `"#EC MAX_PARAMS_LINE` |

### Clean ABAP Best Practice
Prefer between 0 and 3 parameters per method. When a business process requires more attributes, encapsulate them into a dedicated parameter structure (e.g., `ty_invoice_request`) or a state object. This ensures backward compatibility when adding new fields in Cloud Contract C1 environments without breaking existing callers.


## Related Rules

* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Omit or Require Parameter Names in Method Calls](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Limit Number of Return Statements per Procedure](/rules/max-returns) — <code>#EC MAX_RETURNS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_PARAMS`
* **ABAP Implementation:** [/skyl/cl_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_params.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1409)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1409)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_PARAMS&title=%5BBug%5D%3A%20Issue%20in%20max-params)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-params)**
