---
description: "Avoid repeating the same string literal"
---

# Avoid Repeating the Same String Literal

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DUP_LITERALS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid repeating the same string literal.

> **ATC Finding Message:** `Replace repeated literals with a constant`

## Rationale

Repeating the same string literal in several places couples unrelated code to an unnamed value and makes a later change error-prone. Define a constant with a meaningful name and reuse it. The check focuses on fixed string literals that occur at least three times.

### Non-Compliant

```abap
IF lv_status = 'ACTIVE'.
  lv_text = 'ACTIVE'.
ENDIF.
```

### Compliant

```abap
CONSTANTS c_active TYPE string VALUE 'ACTIVE'.
IF lv_status = c_active.
  lv_text = c_active.
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `MIN_OCCURRENCES` | `Integer` | <code>3</code> |
| `MIN_LENGTH` | `Integer` | <code>3</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_LITERALS

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_LITERALS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_LITERALS`
* **Implementation File:** [zcl_skylint_no_dup_literals.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_literals.clas.abap)
