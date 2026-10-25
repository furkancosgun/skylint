---
title: "Use Predicate Naming for Boolean Methods (is_, has_, can_)"
description: "Use Predicate Naming for Boolean Methods (is_, has_, can_) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-pred-name, clean-abap"
---

# Use Predicate Naming for Boolean Methods (is_, has_, can_)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PRED_NAME" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Enforce predicate naming (IS_, HAS_) on boolean methods.

> **ATC Finding Message:** `Boolean-returning method should use predicate name (IS_, HAS_, CAN_)`

## Rationale

A boolean method reads best as a yes/no question, especially when it appears inside an IF condition. Names such as check_active or get_active leave the return type ambiguous and can suggest a side effect. Use is_, has_, or can_ prefixes for methods that return abap_bool.

### Non-Compliant

```abap
METHODS check_active
  RETURNING VALUE(rv_active) TYPE abap_bool.
```

### Compliant

```abap
METHODS is_active
  RETURNING VALUE(rv_active) TYPE abap_bool.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PRED_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_PRED_NAME
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PRED_NAME`
* **Implementation File:** [zcl_skylint_pref_pred_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pred_name.clas.abap)
