---
description: "Modify Only Own Database Tables"
---

# Only Modify Tables Defined in Your Own Package/Component

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC OWN_TABLES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Modify Only Own Database Tables.

> **ATC Finding Message:** `Modify only customer-owned database tables (see OWN_TABLES)`

## Rationale

Writing directly to tables owned by another application component bypasses its validations, change documents, and authorization logic. It also creates an undocumented dependency that can break when the owning component evolves. Modify only tables in your own package and use released APIs for foreign data.

### Non-Compliant

```abap
UPDATE mara SET matnr = @lv_matnr WHERE matnr = @lv_old_matnr.
```

### Compliant

```abap
UPDATE zmara SET matnr = @lv_matnr WHERE matnr = @lv_old_matnr.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `OWN_TABLES` | `String` | <code>^[yz/]</code> |
| `REPORT_DYNAMIC` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC OWN_TABLES

" SAP CI_ prefix format:
... "#EC CI_OWN_TABLES
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MOD_STD_TABLE`
* **Implementation File:** [zcl_skylint_no_mod_std_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_mod_std_table.clas.abap)
