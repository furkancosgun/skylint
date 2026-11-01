---
title: "Avoid Ambiguous Statements"
description: "Avoid ambiguous MODIFY/DELETE statements between internal and database tables."
keywords: "Clean ABAP, ambiguous statement, no-ambiguous-stmt"
category: "clean-abap"
ruleId: "no-ambiguous-stmt"
---

# Avoid Ambiguous Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_AMBIGUOUS_STMT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid ambiguous statements between itab and database.

> **ATC Finding Message:** `Ambiguous statement; use explicit syntax (TABLE keyword or @ for SQL variables)`

## Rationale

ABAP allows ambiguous syntax for MODIFY and DELETE between internal tables and database tables. Use TABLE keyword or @ host escape to clarify intent.

### Non-Compliant

```abap
MODIFY lt_data FROM ls_row.
```

### Compliant

```abap
MODIFY TABLE lt_data FROM ls_row.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_AMBIGUOUS_STMT

" SAP CI_ prefix format:
... "#EC CI_NO_AMBIGUOUS_STMT
```


## Related Rules

* [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>
* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_AMBIGUOUS_STMT`
* **Implementation File:** [zcl_skylint_no_ambiguous_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_ambiguous_stmt.clas.abap)
