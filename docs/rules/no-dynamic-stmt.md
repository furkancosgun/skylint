---
title: "Avoid Dynamic OpenSQL and Metaprogramming Language Constructs"
description: "Prevent SQL injection and runtime errors in ABAP by avoiding dynamic OpenSQL queries, dynamic method calls, and dynamic assignments."
keywords: "no-dynamic-stmt, Dynamic SQL ABAP, SQL Injection CWE-89, Clean ABAP, cl_abap_dyn_prg, SAP ATC"
category: "security"
ruleId: "no-dynamic-stmt"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3076"
---

# Avoid Dynamic OpenSQL and Metaprogramming Language Constructs

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_DYNAMIC_STMT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3076" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.).

> **ATC Finding Message:** `Avoid dynamic calls and language constructs`

## Rationale

Dynamic language constructs in ABAP—such as dynamic OpenSQL queries (`FROM (lv_table)`, `WHERE (lv_where)`), dynamic method calls (`CALL METHOD lo->(lv_method)`), dynamic assignments (`ASSIGN (lv_var) TO <fs>`), and dynamic program execution (`SUBMIT (lv_prog)`)—bypass static type checking and compile-time syntax verification. Unvalidated dynamic SQL introduces high-severity SQL Injection vulnerabilities (OWASP A03 / CWE-89), prevents static ATC security scanning, and degrades database query plan caching. In Clean ABAP and ABAP Cloud, logic should be statically typed and bound to explicit artifacts; unavoidable dynamic SQL in RAP custom query providers must be strictly sanitized using cl_abap_dyn_prg.

### Non-Compliant

```abap
DATA(lv_table_name) = 'ZCUSTOMERS'.
SELECT customer_id, customer_name
  FROM (lv_table_name)
  WHERE customer_id = @lv_customer_id
  INTO TABLE @DATA(lt_customers).
```

### Compliant

```abap
SELECT customer_id, customer_name
  FROM zcustomers
  WHERE customer_id = @lv_customer_id
  INTO TABLE @DATA(lt_customers).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DYNAMIC_SQL` | `Boolean` | <code>true</code> | Flag dynamic table names, column projections, and WHERE clauses enclosed in parentheses in OpenSQL (default: true). |
| `IGNORE_RAP_QUERY_PROVIDER` | `Boolean` | <code>true</code> | Exempt dynamic OpenSQL queries located within RAP query provider methods implementing IF_RAP_QUERY_PROVIDER~SELECT (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DYNAMIC_STMT

" SAP CI_ prefix format:
... "#EC CI_NO_DYNAMIC_STMT
```

## Detected Dynamic Statements

The check inspects procedure statements and flags the following dynamic patterns:

| Statement Type | Dynamic Pattern Detected | Risk / Vulnerability |
|---|---|---|
| `SELECT` / `UPDATE` / `DELETE` | `FROM (lv_table)` or `WHERE (lv_where)` | SQL Injection (CWE-89), lack of static type checking |
| `CALL FUNCTION` | Non-literal function name `CALL FUNCTION lv_func` | Unverified remote or local function dispatch |
| `CALL METHOD` | Dynamic method or class dispatch `lo->(lv_meth)` | Dynamic invoke failure, runtime dump `CX_SY_DYN_CALL_ILLEGAL_METHOD` |
| `ASSIGN` | `ASSIGN (lv_var) TO <fs>` or `ASSIGN COMPONENT` | Dynamic field symbol binding without symbol validation |
| `CREATE OBJECT` | Dynamic type instantiation `TYPE (lv_class)` | Dynamic type mismatch, unexpected class creation |
| `SUBMIT` / `PERFORM` | Dynamic program or routine invocation `(lv_prog)` | Arbitrary code execution risk |
| `SORT` | Dynamic sort key `SORT itab BY (lv_col)` | Runtime dump on invalid column name |

Dynamic SQL inside custom RAP query provider implementations (`IF_RAP_QUERY_PROVIDER~SELECT`) is exempted when `IGNORE_RAP_QUERY_PROVIDER` is enabled. Suppress false positives with `"#EC NO_DYNAMIC_STMT` or `##NO_DYNAMIC_STMT`.


## Related Rules

* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>
* [Avoid Dynamic Metaprogramming and Runtime Code Generation](/rules/no-metaprogramming) — <code>#EC NO_METAPROGRAMMING</code>
* [Avoid Internal C-Kernel Calls and Native Database SQL](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DYNAMIC_STMT`
* **ABAP Implementation:** [/skyl/cl_no_dynamic_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dynamic_stmt.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3076)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3076)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DYNAMIC_STMT&title=%5BBug%5D%3A%20Issue%20in%20no-dynamic-stmt)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dynamic-stmt)**
