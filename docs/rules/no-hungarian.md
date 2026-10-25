---
description: "Avoid Hungarian notation and encoding prefixes"
---

# Avoid Hungarian Notation and Type Prefixes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_HUNGARIAN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Hungarian notation and encoding prefixes.

> **ATC Finding Message:** `Avoid Hungarian notation and encoding prefixes in names`

## Rationale

Hungarian notation prefixes (such as lv_, ls_, lt_, mv_, iv_, rv_) add visual clutter, encode technical types that frequently change, and conflict with modern Clean ABAP principles. Name variables and parameters after their domain meaning instead.

### Non-Compliant

```abap
DATA lv_count TYPE i.
DATA mv_value TYPE string.
METHODS process IMPORTING iv_input TYPE string.
```

### Compliant

```abap
DATA count TYPE i.
DATA value TYPE string.
METHODS process IMPORTING input TYPE string.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_ATTR` | `Boolean` | <code>true</code> |
| `CHECK_LOCAL` | `Boolean` | <code>true</code> |
| `CHECK_PARAM` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HUNGARIAN

" SAP CI_ prefix format:
... "#EC CI_NO_HUNGARIAN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_HUNGARIAN`
* **Implementation File:** [zcl_skylint_no_hungarian.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_hungarian.clas.abap)
