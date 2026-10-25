---
description: "Avoid obsolete statements (MOVE, REFRESH, FORM, etc.)"
---

# Avoid Obsolete & Forbidden Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC OBSOLETE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid obsolete statements (MOVE, REFRESH, FORM, etc.).

> **ATC Finding Message:** `Avoid obsolete or deprecated statement; use modern Clean ABAP construct`

## Rationale

Statements such as MOVE, REFRESH, TABLES, STATICS, FORM, and LEAVE are legacy constructs that are discouraged by Clean ABAP and several are forbidden in ABAP Cloud. They bypass modern type checking and object-oriented structure, and they make the code harder to migrate. Replace them with direct assignments, modern table operations, and class methods.

### Non-Compliant

```abap
MOVE lv_source TO lv_target.
```

### Compliant

```abap
lv_target = lv_source.
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
| `CHECK_MOVE` | `Boolean` | <code>true</code> |
| `CHECK_REFRESH` | `Boolean` | <code>true</code> |
| `CHECK_COMPUTE` | `Boolean` | <code>true</code> |
| `CHECK_TABLES` | `Boolean` | <code>true</code> |
| `CHECK_FIELD_GROUPS` | `Boolean` | <code>true</code> |
| `CHECK_TEST_SEAMS` | `Boolean` | <code>true</code> |
| `CHECK_BREAK` | `Boolean` | <code>true</code> |
| `CHECK_STATICS` | `Boolean` | <code>true</code> |
| `CHECK_DEFINE` | `Boolean` | <code>true</code> |
| `CHECK_EXPORT_MEMORY` | `Boolean` | <code>true</code> |
| `CHECK_FORM` | `Boolean` | <code>true</code> |
| `CHECK_LOOP_CTL` | `Boolean` | <code>true</code> |
| `CHECK_ADD` | `Boolean` | <code>true</code> |
| `CHECK_ADD_CORR` | `Boolean` | <code>true</code> |
| `CHECK_TYPE_POOLS` | `Boolean` | <code>true</code> |
| `CHECK_RANGES` | `Boolean` | <code>true</code> |
| `CHECK_HEADER_LINE` | `Boolean` | <code>true</code> |
| `CHECK_LOAD` | `Boolean` | <code>true</code> |
| `CHECK_PACK` | `Boolean` | <code>true</code> |
| `CHECK_UNPACK` | `Boolean` | <code>true</code> |
| `CHECK_EXTRACT` | `Boolean` | <code>true</code> |
| `CHECK_COMMON_PART` | `Boolean` | <code>true</code> |
| `CHECK_FREE_MEMORY` | `Boolean` | <code>true</code> |
| `CHECK_PROVIDE` | `Boolean` | <code>true</code> |
| `CHECK_CONTEXTS` | `Boolean` | <code>true</code> |
| `CHECK_INITIAL_SIZE` | `Boolean` | <code>true</code> |
| `CHECK_CATCH_SYSTEM` | `Boolean` | <code>true</code> |
| `CHECK_GET_REFERENCE` | `Boolean` | <code>true</code> |
| `CHECK_INFOTYPES` | `Boolean` | <code>true</code> |
| `CHECK_COMMUNICATION` | `Boolean` | <code>true</code> |
| `CHECK_SET_EXT_CHECK` | `Boolean` | <code>true</code> |
| `CHECK_OCCURS` | `Boolean` | <code>true</code> |
| `CHECK_FS_STRUCTURE` | `Boolean` | <code>true</code> |
| `CHECK_PARAMETER` | `Boolean` | <code>true</code> |
| `CHECK_SELECT_NO_INTO` | `Boolean` | <code>true</code> |
| `CHECK_EXIT_SQL` | `Boolean` | <code>true</code> |
| `CHECK_SORT_BY_FS` | `Boolean` | <code>true</code> |
| `CHECK_CALL_TRANSF` | `Boolean` | <code>true</code> |
| `CHECK_REGEX` | `Boolean` | <code>true</code> |
| `CHECK_OCCURENCES` | `Boolean` | <code>true</code> |
| `CHECK_REPLACE_INTO` | `Boolean` | <code>true</code> |
| `CHECK_LOOP_EXTRACT` | `Boolean` | <code>true</code> |
| `CHECK_SORT_EXTRACT` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC OBSOLETE

" SAP CI_ prefix format:
... "#EC CI_OBSOLETE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBSOLETE`
* **Implementation File:** [zcl_skylint_no_obsolete.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obsolete.clas.abap)
