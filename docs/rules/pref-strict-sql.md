---
title: "Prefer Strict SQL Host Variable Escaping"
description: "Ensure ABAP SQL host variables are escaped with '@' for strict SQL mode."
keywords: "Clean ABAP, strict SQL, host variables, pref-strict-sql"
category: "clean-abap"
ruleId: "pref-strict-sql"
---

# Prefer Strict SQL Host Variable Escaping

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_STRICT_SQL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer strict SQL; escape host variables and targets with @.

> **ATC Finding Message:** `Use strict SQL syntax; escape host variables and targets with @`

## Rationale

Modern ABAP SQL requires host variables and structures to be escaped with the '@' character for strict mode compliance.

### Non-Compliant

```abap
SELECT * FROM ztable INTO TABLE lt_data.
```

### Compliant

```abap
SELECT * FROM ztable INTO TABLE @lt_data.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_STRICT_SQL

" SAP CI_ prefix format:
... "#EC CI_PREF_STRICT_SQL
```


## Related Rules

* [Avoid INTO with Field Symbols](/rules/no-into-fs) — <code>#EC NO_INTO_FS</code>
* [Avoid Ambiguous Statements](/rules/no-ambiguous-stmt) — <code>#EC NO_AMBIGUOUS_STMT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STRICT_SQL`
* **Implementation File:** [zcl_skylint_pref_strict_sql.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_strict_sql.clas.abap)
