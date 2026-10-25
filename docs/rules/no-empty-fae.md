---
title: "Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)"
description: "Avoid full table scan database crashes in SAP ABAP by ensuring FOR ALL ENTRIES driver tables are checked for initial state before querying."
keywords: "SAP FOR ALL ENTRIES empty, Full Table Scan ABAP, TSV_TNEW_PAGE_ALLOC_FAILED, Clean ABAP FAE Check, S/4HANA Database Stability"
---

# Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_EMPTY_FAE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Unsecure FOR ALL ENTRIES (Missing empty itab check).

> **ATC Finding Message:** `FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan`

## Rationale

In ABAP OpenSQL, if the internal table specified in `FOR ALL ENTRIES IN @lt_tab` is empty at runtime, **the database drops the WHERE clause entirely** and executes an unrestricted full-table scan (`SELECT * FROM dbtab`). This is a well-known legacy behavior in SAP NetWeaver and ABAP Cloud that can lock massive production tables, exhaust application server memory, and result in catastrophic runtime dumps (`TSV_TNEW_PAGE_ALLOC_FAILED`).

**Best Practice:** Always guard any `FOR ALL ENTRIES` query with an explicit `IF itab IS NOT INITIAL` condition before invoking the database.

### Non-Compliant

```abap
" Anti-pattern: If lt_items is empty, WHERE is ignored -> Entire ZINVOICES read!
SELECT invoice_id, amount, status
  FROM zinvoices
  FOR ALL ENTRIES IN @lt_items
  WHERE item_id = @lt_items-item_id
  INTO TABLE @DATA(lt_invoices).
```

### Compliant

```abap
" Clean ABAP: Guard check guarantees safety and avoids full table scan
IF lt_items IS NOT INITIAL.
  SELECT invoice_id, amount, status
    FROM zinvoices
    FOR ALL ENTRIES IN @lt_items
    WHERE item_id = @lt_items-item_id
    INTO TABLE @DATA(lt_invoices).
ELSE.
  CLEAR lt_invoices.
ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_FAE

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_FAE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_FAE`
* **Implementation File:** [zcl_skylint_no_empty_fae.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_fae.clas.abap)
