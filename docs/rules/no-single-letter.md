---
title: "Avoid Single-Letter Variable Names"
description: "Avoid Single-Letter Variable Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-single-letter, clean-abap"
category: "clean-abap"
ruleId: "no-single-letter"
---

# Avoid Single-Letter Variable Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_SINGLE_LETTER" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid single-letter variable names.

> **ATC Finding Message:** `Avoid single-letter variable names; use descriptive identifiers`

## Rationale

Single-letter variables (e.g. i, x, lv_i, ls_x) obscure the meaning of code, make text searching difficult, and increase cognitive load. Use intention-revealing names such as index, customer, or total_amount.

### Non-Compliant

```abap
DATA i TYPE i.
DATA lv_i TYPE i.
```

### Compliant

```abap
DATA line_index TYPE i.
DATA count TYPE i.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MIN_NAME_LEN` | `Integer` | <code>2</code> | Minimum allowable identifier length (default: 2, excludes i, j, x, y loop indices) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SINGLE_LETTER

" SAP CI_ prefix format:
... "#EC CI_NO_SINGLE_LETTER
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SINGLE_LETTER`
* **Implementation File:** [zcl_skylint_no_single_letter.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_single_letter.clas.abap)
