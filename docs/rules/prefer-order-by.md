---
description: "SELECT UP TO 1 ROWS requires ORDER BY"
---

# Require ORDER BY for Deterministic SELECT Results

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC ORDER_BY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

SELECT UP TO 1 ROWS requires ORDER BY.

> **ATC Finding Message:** `SELECT UP TO 1 ROWS requires an explicit ORDER BY clause for determinism`

## Rationale

A SELECT with UP TO n ROWS but no ORDER BY returns an arbitrary subset whose contents can change after database reorganization or parallel execution. That makes results non-deterministic and difficult to reproduce in tests. Add ORDER BY on a stable key so the same query returns the same rows.

### Non-Compliant

```abap
SELECT customer_id FROM /dmo/customer UP TO 1 ROWS INTO @lv_customer_id.
```

### Compliant

```abap
SELECT customer_id FROM /dmo/customer ORDER BY customer_id UP TO 1 ROWS INTO @lv_customer_id.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ORDER_BY

" SAP CI_ prefix format:
... "#EC CI_ORDER_BY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_ORDER_BY`
* **Implementation File:** [zcl_skylint_pref_order_by.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_order_by.clas.abap)
