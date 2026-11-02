---
title: "Prefer READ TABLE WITH KEY over WHERE"
description: "Prefer READ TABLE WITH KEY over WHERE in ABAP for faster single line internal table access with key optimization. ABAP performance rules and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "READ TABLE WITH KEY, ABAP Single Line Access, Internal Table Performance, ABAP Cheat Sheet, ATC Code Review"
category: "performance"
ruleId: "pref-read-key"
---

# Prefer READ TABLE WITH KEY over WHERE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_READ_KEY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

READ With WITH KEY Instead of WHERE.

> **ATC Finding Message:** `READ TABLE WHERE - use WITH KEY so the access benefits from key optimization`

## Rationale

READ TABLE ... WITH KEY is the documented single-line access form and allows the runtime to exploit table keys and sorted access for a direct hit. The WHERE variant of READ TABLE forces a row-by-row scan of the internal table. The rule only reports WHERE clauses that WITH KEY can express: pure equality comparisons ( = / EQ ) combined with AND. Conditions with other operators ( CS, GT, OR, IS, ... ) cannot be converted and are not flagged. Clean ABAP cheat sheet (Single Line Access) recommends WITH KEY for one-line lookups.

### Non-Compliant

```abap
READ TABLE lt_data INTO ls_data WHERE field1 = 'X'.
```

### Compliant

```abap
READ TABLE lt_data INTO ls_data WITH KEY field1 = 'X'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_READ_KEY

" SAP CI_ prefix format:
... "#EC CI_PREF_READ_KEY
```


## Related Rules

* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Prefer LOOP AT WHERE over IF CONTINUE Guards](/rules/pref-loop-where) — <code>#EC PREF_LOOP_WHERE</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_READ_KEY`
* **Implementation File:** [zcl_skylint_pref_read_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_read_key.clas.abap)
