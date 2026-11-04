---
title: "Limit Number of CATCH Clauses per TRY Block"
description: "Limit CATCH clauses per ABAP TRY block to prevent bloated error handling and enforce clean exception hierarchy design in SAP ATC."
keywords: "max-catch-clauses, TRY CATCH limit ABAP, Clean ABAP exceptions, error handling coupling, SAP ATC metrics"
category: "metrics"
ruleId: "max-catch-clauses"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5586"
---

# Limit Number of CATCH Clauses per TRY Block

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_CATCH_CLAUSES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5586" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit CATCH clauses per TRY block.

> **ATC Finding Message:** `TRY block has too many CATCH clauses; handling too many errors indicates coupling`

## Rationale

A TRY block that catches four or more distinct exception classes is a clear symptom of high error-handling coupling and indicates that the enclosed code performs too many heterogeneous operations. In clean object-oriented architecture, exceptions should be organized into meaningful package or component hierarchies sharing common abstract superclasses (e.g., cx_static_check or custom zcx_application_error). Catching too many individual leaf exceptions clutters the procedure with redundant error-handling blocks. Catching at the appropriate level of abstraction produces cleaner, more resilient error handling in ABAP Cloud.

### Non-Compliant

```abap
TRY.
    execute_financial_posting( ls_posting_payload ).
  CATCH zcx_currency_conversion_error.
    handle_currency_error( ).
  CATCH zcx_account_determination_err.
    handle_account_error( ).
  CATCH zcx_posting_period_closed.
    handle_period_error( ).
  CATCH zcx_fiscal_year_variant_err.
    handle_fiscal_error( ).
ENDTRY.
```

### Compliant

```abap
TRY.
    execute_financial_posting( ls_posting_payload ).
  CATCH zcx_financial_posting_error INTO DATA(lx_posting_error).
    log_posting_failure( lx_posting_error ).
ENDTRY.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_CATCH_CLAUSES` | `Integer` | <code>3</code> | Maximum number of CATCH clauses allowed for a single TRY block before recommending exception hierarchy consolidation (default: 3). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_CATCH_CLAUSES

" SAP CI_ prefix format:
... "#EC CI_MAX_CATCH_CLAUSES
```

## Analysis Mechanics

- **Clause Counting**: Counts each statement with keyword `CATCH`. Note that multiple exception types grouped in a single statement (e.g., `CATCH cx_one cx_two INTO lx_ex.`) count as one `CATCH` clause.
- **Nesting Support**: An internal stack tracks nested `TRY ... ENDTRY` blocks independently.
- **Reporting**: When `ENDTRY` is encountered and the number of `CATCH` statements exceeds `MAX_CATCH_CLAUSES` (default `3`), finding code `MAX_CATCH` is reported on the opening `TRY` statement.

## Suppression

Suppress the check with the pseudo-comment `"#EC MAX_CATCH_CLAUSES` placed on the opening `TRY` statement.


## Related Rules

* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_CATCH_CLAUSES`
* **ABAP Implementation:** [/skyl/cl_max_catch_clauses.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_catch_clauses.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5586)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5586)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_CATCH_CLAUSES&title=%5BBug%5D%3A%20Issue%20in%20max-catch-clauses)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-catch-clauses)**
