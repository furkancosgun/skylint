---
description: "Avoid sy-* System Variable Modification"
---

# Avoid Modifying System Fields (sy-*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC SY_MODIFY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid sy-* System Variable Modification.

> **ATC Finding Message:** `Avoid modifying system fields (sy-*); system variables are read-only`

## Rationale

System fields such as sy-subrc, sy-tabix, and sy-index are maintained by the ABAP runtime and carry the result of the last statement. Writing to them falsifies that contract and can break framework logic or later checks. Return explicit values or flags instead of changing runtime state.

### Non-Compliant

```abap
sy-subrc = 0.
sy-tabix = 1.
```

### Compliant

```abap
rv_success = abap_true.
rt_result = lt_result.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SY_MODIFY

" SAP CI_ prefix format:
... "#EC CI_SY_MODIFY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SY_MODIFY`
* **Implementation File:** [zcl_skylint_no_sy_modify.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_sy_modify.clas.abap)
