---
title: "Avoid Raising System Exceptions Directly (CX_SY_*)"
description: "Maintain clear exception boundaries in ABAP by defining custom domain exceptions instead of raising internal CX_SY_* classes."
keywords: "CX_SY_* exceptions ABAP, Clean ABAP Domain Exceptions, Error Handling Best Practices SAP"
category: "security"
ruleId: "no-raise-cx-sy"
---

# Avoid Raising System Exceptions Directly (CX_SY_*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAISE_CX_SY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid raising SAP internal system exceptions (cx_sy_*).

> **ATC Finding Message:** `Avoid raising SAP internal system exceptions; use application exceptions`

## Rationale

Classes in the `CX_SY_*` namespace (such as `CX_SY_ZERODIVIDE`, `CX_SY_REF_IS_INITIAL`) are reserved for the ABAP runtime engine and virtual machine. Raising them manually in business application logic confuses callers, pollutes error logs, and obscures the true origin of technical errors.

**Best Practice:** Define dedicated domain exception classes inheriting from `CX_STATIC_CHECK` or `zcx_application_error`.

### Non-Compliant

```abap
" Anti-pattern: Raising internal kernel exception
RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
```

### Compliant

```abap
" Clean ABAP: Custom domain exception expressing business context
RAISE EXCEPTION NEW zcx_customer_not_found( iv_customer_id ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAISE_CX_SY

" SAP CI_ prefix format:
... "#EC CI_NO_RAISE_CX_SY
```


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Explicit RAISE SHORTDUMP in Application Logic](/rules/no-raise-shortdump) — <code>#EC NO_RAISE_SHORTDUMP</code>
* [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAISE_CX_SY`
* **Implementation File:** [zcl_skylint_no_raise_cx_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_cx_sy.clas.abap)
