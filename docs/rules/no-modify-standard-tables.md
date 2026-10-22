---
description: "Modify Only Own Database Tables"
---

# Only Modify Tables Defined in Your Own Package/Component

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC OWN_TABLES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Modify Only Own Database Tables.

> **ATC Finding Message:** `Modify only customer-owned database tables (see OWN_TABLES)`

## Rationale

Directly inserting, updating, or deleting tables belonging to another application component bypasses business validation logic and violates modular architecture. Which tables are considered your own is configurable via `OWN_TABLES`, a case-insensitive regex (default `^[yz/]`); dynamic table names are reported when `REPORT_DYNAMIC` is enabled.

### Non-Compliant

```abap
DELETE FROM mara WHERE matnr = '100'.
```

### Compliant

```abap
DELETE FROM zmara WHERE matnr = '100'.
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
