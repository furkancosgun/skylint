---
title: "Only Modify Tables Defined in Your Own Package/Component"
description: "Protect SAP database integrity and preserve Clean Core support by updating standard tables via official BAPIs and RAP interfaces."
keywords: "Modify SAP standard tables, Clean Core ABAP, Direct Table Mutation Integrity, SAP S/4HANA Support Guidelines"
category: "security"
ruleId: "no-mod-std-table"
---

# Only Modify Tables Defined in Your Own Package/Component

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_MOD_STD_TABLE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Modify Only Own Database Tables.

> **ATC Finding Message:** `Modify only customer-owned database tables (see OWN_TABLES)`

## Rationale

Directly executing `INSERT`, `UPDATE`, `MODIFY`, or `DELETE` statements on SAP standard tables (like `VBAK`, `BKPF`, `EKKO`, `BUT000`) bypasses core SAP document locking, document numbering, consistency validations, and business events. Such direct updates corrupt standard SAP database integrity and void SAP enterprise support agreements.

**Clean Core Standard:** Always use released SAP Business APIs (BAPIs), standard Business Objects, or RAP transactional interfaces to create or update SAP standard data.

### Non-Compliant

```abap
" Highly Dangerous: Direct modification of standard SAP Financials header table
UPDATE bkpf SET bstat = 'V' WHERE belnr = @lv_doc_num.
```

### Compliant

```abap
" Clean Core: Modification via official released BAPI / RAP interface
CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
  EXPORTING
    documentheader = ls_header
  TABLES
    accountgl      = lt_gl
    return         = lt_return.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `OWN_TABLES` | `String` | <code>^[yz/]</code> | Regex pattern matching custom namespace tables permitted for direct mutation (default: ^[yz/]) |
| `REPORT_DYNAMIC` | `Boolean` | <code>true</code> | Report dynamic database statements targeting unverified table variables |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MOD_STD_TABLE

" SAP CI_ prefix format:
... "#EC CI_NO_MOD_STD_TABLE
```


## Related Rules

* [Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MOD_STD_TABLE`
* **Implementation File:** [zcl_skylint_no_mod_std_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_mod_std_table.clas.abap)
