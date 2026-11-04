---
title: "Avoid Generic CATCH cx_root and Catch Specific Exceptions"
description: "Prevent black hole exception handling in SAP ABAP by catching specific domain exceptions instead of generic CATCH cx_root."
keywords: "no-catch-root, CX_ROOT, Clean ABAP, exception handling, SAP ATC"
category: "security"
ruleId: "no-catch-root"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2336"
---

# Avoid Generic CATCH cx_root and Catch Specific Exceptions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_CATCH_ROOT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2336" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Catch specific exceptions instead of generic cx_root.

> **ATC Finding Message:** `Avoid generic CATCH cx_root; catch specific exception classes instead`

## Rationale

Catching the base exception class CX_ROOT indiscriminately traps all class-based exceptions, including fatal runtime anomalies such as CX_SY_RESOURCE_FAILURE, database connection loss, and critical assertion failures. Catching CX_ROOT without proper re-raising creates the Black Hole Exception anti-pattern: severe system defects are masked, and execution continues in a corrupted state. Application code should catch only specific, anticipated domain or system exception classes (such as zcx_order_not_found or cx_sy_conversion_no_number) where meaningful recovery or domain logging can take place.

### Non-Compliant

```abap
DATA lv_invoice_id TYPE string VALUE 'INV-1001'.
TRY.
    zcl_billing_service=>process_invoice( iv_invoice_id = lv_invoice_id ).
  CATCH cx_root.
    " Anti-pattern: Silently traps all exceptions including fatal system faults
    RETURN.
ENDTRY.
```

### Compliant

```abap
DATA lv_invoice_id TYPE string VALUE 'INV-1001'.
TRY.
    zcl_billing_service=>process_invoice( iv_invoice_id = lv_invoice_id ).
  CATCH cx_static_check INTO DATA(lx_error).
    " Clean ABAP: Handle expected domain exception specifically
    RETURN.
ENDTRY.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CATCH_ROOT

" SAP CI_ prefix format:
... "#EC CI_NO_CATCH_ROOT
```

### Exception Handling Principles

The check inspects `CATCH` statements and flags references resolved to `\TY:CX_ROOT` with finding code `NO_CAT_ROT`.

Best practices for exception handling:
1. Catch specific domain exceptions (`zcx_order_processing_failed`, `zcx_invalid_partner`).
2. If catching high-level exceptions at application boundaries (e.g. background job controllers or API gateways), always log the exception or wrap it into a domain-specific fault.
3. Never leave `CATCH cx_root` empty.

Suppress findings when building top-level resilience boundaries using pseudo-comment `"#EC NO_CATCH_ROOT`.


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Raising System Exceptions Directly (cx_sy_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Extract Nested TRY Blocks into Dedicated Helper Methods](/rules/no-nested-try) — <code>#EC NO_NESTED_TRY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CATCH_ROOT`
* **ABAP Implementation:** [/skyl/cl_no_catch_root.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_catch_root.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2336)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2336)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CATCH_ROOT&title=%5BBug%5D%3A%20Issue%20in%20no-catch-root)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-catch-root)**
