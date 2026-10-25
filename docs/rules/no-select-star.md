---
description: "Avoid SELECT * (specify columns explicitly)"
---

# Avoid SELECT * Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC SELECT_STAR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid SELECT * (specify columns explicitly).

> **ATC Finding Message:** `Avoid SELECT *; specify required columns explicitly`

## Rationale

SELECT * reads every column even when only a few fields are used, increasing network traffic and memory consumption. It also prevents efficient covering-index access and makes the code break when the table structure changes. List the required columns explicitly so the query stays stable and efficient.

### Non-Compliant

```abap
SELECT * FROM /dmo/customer WHERE country = 'DE' INTO TABLE @lt_customers.
```

### Compliant

```abap
SELECT customer_id, first_name, last_name
  FROM /dmo/customer
  WHERE country = 'DE'
  INTO TABLE @lt_customers.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SELECT_STAR

" SAP CI_ prefix format:
... "#EC CI_SELECT_STAR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELECT_STAR`
* **Implementation File:** [zcl_skylint_no_select_star.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_select_star.clas.abap)
