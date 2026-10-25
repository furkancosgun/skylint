---
title: "Avoid Method Override That Only Delegates to Super"
description: "Avoid Method Override That Only Delegates to Super - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-empty-override, anti-patterns"
---

# Avoid Method Override That Only Delegates to Super

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EMPTY_OVERRIDE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid method override that only calls super.

> **ATC Finding Message:** `Empty method override; method only delegates to super`

## Rationale

Redefining a method only to immediately call the superclass method without performing any additional initialization, logging, argument transformation, or side effect is redundant. It clutters the method implementation, adds needless call stack overhead, and requires maintenance whenever super signatures change. Omit the empty override and let polymorphism delegate to the superclass naturally.

### Non-Compliant

```abap
METHOD do_work.
  super->do_work( ).
ENDMETHOD.
```

### Compliant

```abap
" Omit method redefinition and let superclass handle execution naturally
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `IGNORE_CTOR` | `Boolean` | <code>true</code> | Ignore empty constructor redefinitions (when only calling super->constructor) |
| `IGNORE_CHECK` | `Boolean` | <code>true</code> | Ignore empty redefinitions in test classes or abstract interfaces |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_OVERRIDE

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_OVERRIDE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_OVERRIDE`
* **Implementation File:** [zcl_skylint_no_empty_override.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_override.clas.abap)
