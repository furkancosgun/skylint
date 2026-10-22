---
description: "Prefer SWITCH #( ) expression over CASE statement"
---

# Prefer SWITCH #( ) Expression over CASE Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SWITCH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer SWITCH #( ) expression over CASE statement.

> **ATC Finding Message:** `Prefer SWITCH #( ) constructor expression over CASE`

## Rationale

CASE statements that merely assign values to a single variable can be written much more concisely using modern ABAP SWITCH #( ) constructor expressions, eliminating repetitive assignment code and improving readability.

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
lv_text = SWITCH #( lv_status
  WHEN 'O' THEN 'Open'
  WHEN 'C' THEN 'Closed'
  ELSE 'Unknown' ).
```

## Transformation

```diff
- CASE lv_status.
-   WHEN 'O'.
-     lv_text = 'Open'.
-   WHEN 'C'.
-     lv_text = 'Closed'.
-   WHEN OTHERS.
-     lv_text = 'Unknown'.
- ENDCASE.
+ lv_text = SWITCH #( lv_status
+   WHEN 'O' THEN 'Open'
+   WHEN 'C' THEN 'Closed'
+   ELSE 'Unknown' ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `REQUIRE_OTHERS` | `Boolean` | <code>false</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_SWITCH

" SAP CI_ prefix format:
... "#EC CI_PREF_SWITCH
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SWITCH`
* **Implementation File:** [zcl_skylint_pref_switch.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_switch.clas.abap)
