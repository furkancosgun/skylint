---
title: "Prefer SWITCH #( ) Expression over CASE Statement"
description: "Prefer SWITCH #( ) Expression over CASE Statement - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-switch, clean-abap"
---

# Prefer SWITCH #( ) Expression over CASE Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SWITCH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer SWITCH #( ) expression over CASE statement.

> **ATC Finding Message:** `Prefer SWITCH #( ) constructor expression over CASE`

## Rationale

A CASE statement whose branches only assign a result is a verbose value mapping: it repeats the assignment variable in every branch. SWITCH #( ) makes the input value and all possible results visible in one expression and avoids temporary state. Use SWITCH for pure mappings and CASE when a branch contains several statements or side effects.

### Non-Compliant

```abap
CASE lv_status.
  WHEN 'O'.
    lv_text = 'Open'.
  WHEN 'C'.
    lv_text = 'Closed'.
  WHEN OTHERS.
    lv_text = 'Unknown'.
ENDCASE.
```

### Compliant

```abap
lv_text = SWITCH string( lv_status
  WHEN 'O' THEN 'Open'
  WHEN 'C' THEN 'Closed'
  ELSE 'Unknown' ).
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
| `REQUIRE_OTHERS` | `Boolean` | <code>false</code> | Require explicit WHEN OTHERS branch in SWITCH #( ... ) to handle missing states |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SWITCH

" SAP CI_ prefix format:
... "#EC CI_PREF_SWITCH
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SWITCH`
* **Implementation File:** [zcl_skylint_pref_switch.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_switch.clas.abap)
