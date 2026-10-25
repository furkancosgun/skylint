---
description: "Avoid chained declarations and chained assignments"
---

# Avoid Chained Declarations & Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC CHAIN_DECL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid chained declarations and chained assignments.

> **ATC Finding Messages:**
> - `Avoid chained declarations; declare each entity individually`
> - `Avoid chained assignments; write separate assignment statements`

## Rationale

Chained statements pack several definitions behind a colon and commas, so a modifier or type can appear to apply to more than one name. They also turn a one-line change into a large diff and make merge conflicts harder to resolve. Write each declaration or assignment as its own complete statement so scope and modifiers are unambiguous.

### Non-Compliant

```abap
DATA: lv_order_id TYPE string,
      lv_status   TYPE string.
```

### Compliant

```abap
DATA lv_order_id TYPE string.
DATA lv_status TYPE string.
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
| `ALLOW_STRUCTURE_CHAINS` | `Boolean` | <code>true</code> |
| `CHECK_CHAINED_DECL` | `Boolean` | <code>true</code> |
| `CHECK_CHAINED_ASSIGN` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CHAIN_DECL

" SAP CI_ prefix format:
... "#EC CI_CHAIN_DECL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAINED_STMT`
* **Implementation File:** [zcl_skylint_no_chained_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chained_stmt.clas.abap)
