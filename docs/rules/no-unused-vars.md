---
title: "Eliminate Unused Local Variables and Symbols"
description: "Eliminate Unused Local Variables and Symbols - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-unused-vars, anti-patterns"
category: "anti-patterns"
ruleId: "no-unused-vars"
---

# Eliminate Unused Local Variables and Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_UNUSED_VARS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect unused local variables and field symbols.

> **ATC Finding Message:** `Local variable or field symbol is declared but never read`

## Rationale

An unused variable or field symbol adds noise and suggests incomplete refactoring or a missing assignment. It keeps dead objects alive longer than necessary and makes reviews harder. Remove the declaration, or mark it with ##NEEDED when an external contract requires it.

### Non-Compliant

```abap
DATA lv_message TYPE string.
process_order( ).
```

### Compliant

```abap
DATA lv_message TYPE string.
lv_message = |Order { lv_id }|.
log_message( lv_message ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNUSED_VARS

" SAP CI_ prefix format:
... "#EC CI_NO_UNUSED_VARS
```


## Related Rules

* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Local Variables Shadowing Class Attributes](/rules/no-shadow) — <code>#EC NO_SHADOW</code>
* [Require Fully Typed Variables and Parameters](/rules/pref-full-typed) — <code>#EC PREF_FULL_TYPED</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNUSED_VARS`
* **Implementation File:** [zcl_skylint_no_unused_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unused_vars.clas.abap)
