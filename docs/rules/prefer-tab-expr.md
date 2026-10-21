---
description: "Prefer table expression itab[ ... ] over READ TABLE"
---

# Prefer Table Expression itab[ ... ] over READ TABLE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_TAB_EXPR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer table expression itab[ ... ] over READ TABLE.

> **ATC Finding Message:** `Prefer table expression itab[ ... ] over READ TABLE`

## Rationale

Table expressions provide a direct, functional syntax for accessing internal table rows by key or index, eliminating procedural `READ TABLE` boilerplate and integrating seamlessly into expressions.

### Non-Compliant

```abap
READ TABLE lt_items INTO ls_item WITH KEY id = lv_id.
READ TABLE lt_items ASSIGNING <fs_item> INDEX 1.
```

### Compliant

```abap
ls_item = VALUE #( lt_items[ id = lv_id ] OPTIONAL ).
ASSIGN lt_items[ 1 ] TO <fs_item>.
```

## Transformation

```diff
- READ TABLE lt_items INTO ls_item WITH KEY id = lv_id.
- READ TABLE lt_items ASSIGNING <fs_item> INDEX 1.
+ ls_item = VALUE #( lt_items[ id = lv_id ] OPTIONAL ).
+ ASSIGN lt_items[ 1 ] TO <fs_item>.
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
| `USE_OPTIONAL` | `Boolean` | <code>true</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-tab-expr:
    enabled: true
    severity: warning
    attributes:
      useOptional: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TAB_EXPR

" SAP CI_ prefix format:
... "#EC CI_PREF_TAB_EXPR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TAB_EXPR`
* **Implementation File:** [zcl_skylint_pref_tab_expr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_tab_expr.clas.abap)
