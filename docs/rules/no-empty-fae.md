---
description: "Unsecure FOR ALL ENTRIES (Missing empty itab check)"
---

# Prevent Empty FOR ALL ENTRIES Inquiries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC EMPTY_FAE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Unsecure FOR ALL ENTRIES (Missing empty itab check).

> **ATC Finding Message:** `FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan`

## Rationale

When the driver table of a FOR ALL ENTRIES query is empty, ABAP SQL drops the WHERE condition and reads the entire database table. That can cause timeouts, huge memory consumption, and unintended data exposure. Guard the statement with an IS NOT INITIAL check before executing it.

### Non-Compliant

```abap
SELECT customer_id FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customer_ids.
```

### Compliant

```abap
IF lt_orders IS NOT INITIAL.
  SELECT customer_id FROM /dmo/customer
    FOR ALL ENTRIES IN @lt_orders
    WHERE customer_id = @lt_orders-customer_id
    INTO TABLE @lt_customer_ids.
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
... "#EC EMPTY_FAE

" SAP CI_ prefix format:
... "#EC CI_EMPTY_FAE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_FAE`
* **Implementation File:** [zcl_skylint_no_empty_fae.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_fae.clas.abap)
