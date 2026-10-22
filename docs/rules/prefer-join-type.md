---
description: "Prefer an explicit JOIN type such as INNER JOIN"
---

# Prefer an Explicit JOIN Type

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC JOIN_TYPE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer an explicit JOIN type such as INNER JOIN.

> **ATC Finding Message:** `Specify the JOIN type explicitly, for example INNER JOIN`

## Rationale

A bare `JOIN` silently defaults to an inner join, which hides the intended cardinality and makes the query harder to review. State the join type explicitly with `INNER JOIN`, `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, or `CROSS JOIN`.

### Non-Compliant

```abap
SELECT * FROM mara JOIN makt ON mara~matnr = makt~matnr INTO TABLE @DATA(lt_result).
```

### Compliant

```abap
SELECT * FROM mara INNER JOIN makt ON mara~matnr = makt~matnr INTO TABLE @DATA(lt_result).
```

## Transformation

```diff
- SELECT * FROM mara JOIN makt ON mara~matnr = makt~matnr INTO TABLE @DATA(lt_result).
+ SELECT * FROM mara INNER JOIN makt ON mara~matnr = makt~matnr INTO TABLE @DATA(lt_result).
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
... "#EC JOIN_TYPE

" SAP CI_ prefix format:
... "#EC CI_JOIN_TYPE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_JOIN_TYPE`
* **Implementation File:** [zcl_skylint_pref_join_type.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_join_type.clas.abap)
