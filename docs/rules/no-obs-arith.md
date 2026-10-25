---
title: "Avoid Obsolete Arithmetic and Assignment Statements"
description: "Avoid Obsolete Arithmetic and Assignment Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-obs-arith, anti-patterns"
---

# Avoid Obsolete Arithmetic and Assignment Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_OBS_ARITH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Obsolete Arithmetic and Assignment Statements.

> **ATC Finding Message:** `Avoid obsolete arithmetic or assignment statements; use =, +, -, *, /`

## Rationale

Legacy calculation statements (ADD, SUBTRACT, MULTIPLY, DIVIDE, ADD-CORRESPONDING, and COMPUTE) and verbose assignments (MOVE ... TO, GET REFERENCE OF ... INTO) clutter code and hinder readability. Modern ABAP provides clean functional expressions, compound arithmetic, and standard assignment operators (=, +, -, *, /, REF #()) that are strictly required in Clean ABAP and ABAP Cloud.

### Non-Compliant

```abap
ADD 1 TO lv_count.
MOVE lv_source TO lv_target.
GET REFERENCE OF lv_val INTO lr_ref.
```

### Compliant

```abap
lv_count = lv_count + 1.
lv_target = lv_source.
lr_ref = REF #( lv_val ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_ADD` | `Boolean` | <code>true</code> | Detect obsolete ADD ... TO and SUBTRACT ... FROM statements |
| `CHECK_ADD_CORR` | `Boolean` | <code>true</code> | Detect obsolete ADD-CORRESPONDING statements |
| `CHECK_COMPUTE` | `Boolean` | <code>true</code> | Detect obsolete COMPUTE keyword |
| `CHECK_MOVE` | `Boolean` | <code>true</code> | Detect obsolete MOVE ... TO statements (prefer =) |
| `CHECK_GET_REF` | `Boolean` | <code>true</code> | Detect obsolete GET REFERENCE OF statement (prefer REF #( )) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_ARITH

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_ARITH
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_ARITH`
* **Implementation File:** [zcl_skylint_no_obs_arith.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_arith.clas.abap)
