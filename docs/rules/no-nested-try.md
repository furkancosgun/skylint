---
title: "Extract Nested TRY Blocks into Dedicated Helper Methods"
description: "Prevent nested TRY CATCH blocks in ABAP Cloud by refactoring inner error handlers into modular helper methods."
keywords: "no-nested-try, Clean ABAP, ABAP Cloud, TRY CATCH, refactoring, SAP ATC"
category: "anti-patterns"
ruleId: "no-nested-try"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2393"
---

# Extract Nested TRY Blocks into Dedicated Helper Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_NESTED_TRY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2393" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid nested TRY blocks; extract to helper methods.

> **ATC Finding Message:** `Avoid nested TRY blocks; extract to dedicated method`

## Rationale

Nesting a TRY ... CATCH construct inside another TRY block obscures exception ownership, dramatically increases cognitive complexity, and often leads to duplicated error handling or swallowed exceptions. Clean ABAP recommends keeping methods focused on a single level of abstraction where one TRY block manages the errors relevant to that scope. Any inner operations requiring localized exception handling should be extracted into a well-named private method. The ATC rule flags nested TRY statements with NO_NESTTRY.

### Non-Compliant

```abap
TRY.
    validate_customer_account( iv_customer_id = lv_customer_id ).
    TRY.
        charge_customer_card( iv_amount = lv_invoice_amount ).
      CATCH cx_payment_declined INTO DATA(lx_payment).
        log_payment_failure( lx_payment ).
    ENDTRY.
  CATCH cx_account_locked INTO DATA(lx_account).
    handle_account_locked( lx_account ).
ENDTRY.
```

### Compliant

```abap
TRY.
    validate_customer_account( iv_customer_id = lv_customer_id ).
    process_card_payment( iv_amount = lv_invoice_amount ).
  CATCH cx_account_locked INTO DATA(lx_account).
    handle_account_locked( lx_account ).
ENDTRY.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NESTED_TRY

" SAP CI_ prefix format:
... "#EC CI_NO_NESTED_TRY
```

## Detection Details

The check tracks nesting depth of `TRY` statements within procedures. When a `TRY` statement is encountered at depth 1 or greater, finding code `NO_NESTTRY` is reported against that statement.

### Clean ABAP Remedy
Extract the inner `TRY ... CATCH` block into a dedicated private method (e.g. `process_card_payment`). This clarifies which layer owns each recovery path and reduces cognitive load.

### Suppression
Suppress individual occurrences using `"#EC NO_NESTED_TRY`.


## Related Rules

* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Assign Distinct Error Numbers in Classic Function EXCEPTIONS Clauses](/rules/no-exc-overlap) — <code>#EC NO_EXC_OVERLAP</code>
* [Protect CALL TRANSACTION Statements with AUTHORITY-CHECK](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_NESTED_TRY`
* **ABAP Implementation:** [/skyl/cl_no_nested_try.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_nested_try.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2393)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2393)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_NESTED_TRY&title=%5BBug%5D%3A%20Issue%20in%20no-nested-try)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-nested-try)**
