---
title: "Specify TRANSPORTING in Internal Table MODIFY and READ Operations"
description: "Speed up internal table updates in ABAP by specifying TRANSPORTING fields in MODIFY statements to prevent full-structure copy overhead."
keywords: "MODIFY itab TRANSPORTING, Internal Table Performance ABAP, Clean ABAP Table Mutations, SAP Memory Optimization"
category: "performance"
ruleId: "pref-transport"
---

# Specify TRANSPORTING in Internal Table MODIFY and READ Operations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_TRANSPORT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid MODIFY itab in LOOP without TRANSPORTING clause.

> **ATC Finding Message:** `Specify TRANSPORTING fields in MODIFY itab inside loop for performance`

## Rationale

When updating internal table rows using `MODIFY itab FROM workarea`, ABAP by default copies every single field from the work area into the internal table row. If the table row contains wide structures, nested tables, or large string fields, copying unchanged fields incurs severe CPU cache misses and memory reallocation overhead.

**Best Practice:** Use the `TRANSPORTING` addition to explicitly specify only the specific columns being modified.

### Non-Compliant

```abap
" Anti-pattern: Deep copies all 60 columns of ls_customer back into the table row
ls_customer-status = 'ACTIVE'.
MODIFY lt_customers FROM ls_customer INDEX lv_tabix.
```

### Compliant

```abap
" Clean ABAP: Only transfers the modified status column (zero overhead on other fields)
ls_customer-status = 'ACTIVE'.
MODIFY lt_customers FROM ls_customer INDEX lv_tabix TRANSPORTING status.

" Even better: Mutate directly in-place via field symbol (zero copy)
<ls_customer>-status = 'ACTIVE'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TRANSPORT

" SAP CI_ prefix format:
... "#EC CI_PREF_TRANSPORT
```


## Related Rules

* [Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>
* [Prefer ASSIGNING over LOOP INTO Copy Targets](/rules/no-loop-into) — <code>#EC NO_LOOP_INTO</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TRANSPORT`
* **Implementation File:** [zcl_skylint_pref_transport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_transport.clas.abap)
