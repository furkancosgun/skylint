---
title: "Prefer UNION over UNION ALL"
description: "Prefer standard UNION over UNION ALL in ABAP SQL query combinations."
keywords: "Clean ABAP, UNION, UNION ALL, pref-union"
category: "performance"
ruleId: "pref-union"
---

# Prefer UNION over UNION ALL

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_UNION" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer UNION over UNION ALL in SQL queries.

> **ATC Finding Message:** `Prefer UNION over UNION ALL in SQL queries`

## Rationale

In ABAP SQL queries, prefer UNION to prevent duplicate record processing unless duplicates are explicitly intended and handled.

### Non-Compliant

```abap
SELECT a FROM ztab1 UNION ALL SELECT a FROM ztab2 INTO TABLE @lt_data.
```

### Compliant

```abap
SELECT a FROM ztab1 UNION SELECT a FROM ztab2 INTO TABLE @lt_data.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_UNION

" SAP CI_ prefix format:
... "#EC CI_PREF_UNION
```


## Related Rules

* [Prefer an Explicit JOIN Type](/rules/pref-join-type) — <code>#EC PREF_JOIN_TYPE</code>
* [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_UNION`
* **Implementation File:** [#skyl#cl_pref_union.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_union.clas.abap)
