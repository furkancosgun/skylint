---
title: "Avoid Variable Scope Leaking from Inner Blocks"
description: "Avoid Variable Scope Leaking from Inner Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-scope-leak, anti-patterns"
category: "anti-patterns"
ruleId: "no-scope-leak"
---

# Avoid Variable Scope Leaking from Inner Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SCOPE_LEAK" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid variable usage outside its declaring control block.

> **ATC Finding Message:** `Variable declared in inner block is referenced outside its scope`

## Rationale

A variable declared inside an IF or LOOP block is still visible after the block ends, so using it later creates a hidden dependency on whether the branch executed. This makes behavior hard to reason about and can leave the variable uninitialized. Declare the variable in the enclosing scope and assign it explicitly inside the branch.

### Non-Compliant

```abap
IF is_valid( ).
  DATA(lv_message) = |Order { lv_id }|.
ENDIF.
log_message( lv_message ).
```

### Compliant

```abap
DATA lv_message TYPE string.
IF is_valid( ).
  lv_message = |Order { lv_id }|.
ENDIF.
log_message( lv_message ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SCOPE_LEAK

" SAP CI_ prefix format:
... "#EC CI_NO_SCOPE_LEAK
```


## Related Rules

* [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Single-Letter Variable Names](/rules/no-single-letter) — <code>#EC NO_SINGLE_LETTER</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SCOPE_LEAK`
* **Implementation File:** [zcl_skylint_no_scope_leak.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_scope_leak.clas.abap)
