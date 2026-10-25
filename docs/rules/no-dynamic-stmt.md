---
title: "Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)"
description: "Prevent SQL injection and runtime type mismatches in SAP ABAP by avoiding unverified dynamic programming constructs."
keywords: "CWE-89 SQL Injection ABAP, Dynamic SQL Security SAP, cl_abap_dyn_prg, Clean ABAP Static Typing"
---

# Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_DYNAMIC_STMT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.).

> **ATC Finding Message:** `Avoid dynamic calls and language constructs`

## Rationale

Dynamic ABAP statements (like dynamic SQL `SELECT (lt_fields) FROM (lv_table) WHERE (lv_cond)`, dynamic method calls `CALL METHOD (lv_class)=>(lv_meth)`, or dynamic assignments `ASSIGN (lv_var) TO <fs>`) bypass compile-time syntax checks, cannot be analyzed by static ATC security tools, and introduce severe **SQL Injection (CWE-89)** risks.

**Security Standard:** Write static, strongly-typed OpenSQL and OOP code wherever possible. When dynamic SQL is unavoidable (e.g. in generic analytics engines), escape input variables thoroughly using `cl_abap_dyn_prg`.

### Non-Compliant

```abap
" Critical Security Vulnerability: SQL Injection via unsanitized WHERE string
DATA(lv_where) = |CUSTOMER_ID = '{ iv_user_input }'|.
SELECT * FROM zcustomers WHERE (lv_where) INTO TABLE @DATA(lt_cust).
```

### Compliant

```abap
" Secure: Static typed OpenSQL with host variable binding
SELECT customer_id, customer_name
  FROM zcustomers
  WHERE customer_id = @iv_user_input
  INTO TABLE @DATA(lt_cust).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DYNAMIC_SQL` | `Boolean` | <code>true</code> | Detect dynamic table names, column projections, and WHERE clauses in OpenSQL |
| `IGNORE_RAP_QUERY_PROVIDER` | `Boolean` | <code>true</code> | Allow dynamic queries inside custom RAP query provider implementations (IF_RAP_QUERY_PROVIDER) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DYNAMIC_STMT

" SAP CI_ prefix format:
... "#EC CI_NO_DYNAMIC_STMT
```

## References & Standards

* [CWE-89: SQL Injection](https://cwe.mitre.org/data/definitions/89.html)
* [Clean ABAP: Prefer Static Over Dynamic](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DYNAMIC_STMT`
* **Implementation File:** [zcl_skylint_no_dynamic_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dynamic_stmt.clas.abap)
