---
description: "Do not CLEAR or FREE variables redundantly"
---

# Do Not CLEAR Variables Directly After Declaration

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC REDUNDANT_CLEAR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Do not CLEAR or FREE variables redundantly.

> **ATC Finding Messages:**
> - `Do not CLEAR or FREE variables after declaration; they are already initial`
> - `Variable is CLEARed or FREEd but never read again before procedure ends`

## Rationale

Variables in ABAP are automatically initialized to their type-specific default initial value upon declaration. Explicitly executing `CLEAR` immediately after declaration adds visual noise and redundant statements without any functional effect.

### Non-Compliant

```abap
DATA lv_count TYPE i.
CLEAR lv_count.
```

### Compliant

```abap
DATA lv_count TYPE i.
```

## Transformation

```diff
- DATA lv_count TYPE i.
- CLEAR lv_count.
+ DATA lv_count TYPE i.
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
| `CHECK_BEFORE_WRITE` | `Boolean` | <code>true</code> |
| `CHECK_WITHOUT_READ` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC REDUNDANT_CLEAR

" SAP CI_ prefix format:
... "#EC CI_REDUNDANT_CLEAR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_REDUNDANT_CLEAR`
* **Implementation File:** [zcl_skylint_no_redundant_clear.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_redundant_clear.clas.abap)
