---
title: "Avoid Explicit RAISE SHORTDUMP in Application Logic"
description: "Eliminate deliberate crash statements in ABAP by replacing RAISE SHORTDUMP with structured class-based exceptions."
keywords: "RAISE SHORTDUMP ABAP, ST22 Dump Elimination, Clean ABAP Resilience"
category: "security"
ruleId: "no-raise-shortdump"
---

# Avoid Explicit RAISE SHORTDUMP in Application Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAISE_SHORTDUMP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid RAISE SHORTDUMP.

> **ATC Finding Message:** `Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions`

## Rationale

The statement `RAISE SHORTDUMP` deliberately triggers an instant runtime crash and short dump in transaction ST22. Triggering intentional crashes bypasses standard cleanup handlers, cancels asynchronous update tasks, and leaves database locks dangling.

**Best Practice:** Raise standard class-based exceptions inheriting from `CX_STATIC_CHECK` or `CX_NO_CHECK`. Allow the caller or global exception boundary to handle the incident gracefully.

### Non-Compliant

```abap
" Anti-pattern: Forces instant ST22 crash
RAISE SHORTDUMP TYPE zcx_fatal_error.
```

### Compliant

```abap
" Clean ABAP: Structured exception allowing caller recovery
RAISE EXCEPTION NEW zcx_fatal_error( textid = zcx_fatal_error=>c_system_unavailable ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAISE_SHORTDUMP

" SAP CI_ prefix format:
... "#EC CI_NO_RAISE_SHORTDUMP
```


## Related Rules

* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAISE_SHORTDUMP`
* **Implementation File:** [zcl_skylint_no_raise_shortdump.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_shortdump.clas.abap)
