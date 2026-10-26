---
title: "Performance & Database (10 Rules)"
description: "Database query efficiency, buffer protection, and internal table operation guidelines. Comprehensive reference, finding codes, and Clean ABAP examples for Performance & Database."
category: "performance"
keywords: "Clean ABAP, ABAP Cloud, SAP ATC, Performance & Database, S/4HANA Readiness, SAP BTP, Steampunk"
---

# Performance & Database (10 Rules)

Database query efficiency, buffer protection, and internal table operation guidelines.

::: tip Category Overview
This category enforces **10 native ATC rules** adhering to SAP Clean ABAP and ABAP Cloud standards. Each check executes natively inside Eclipse ADT and SAP GUI.
:::

## Rules in this Category

| Rule Name | Native ATC Class | Suppression Tag | Automated QuickFix |
|---|---|:---:|:---:|
| [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) | `ZCL_SKYLINT_NO_DB_IN_LOOP` | <code>#EC NO_DB_IN_LOOP</code> | - |
| [Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)](/rules/no-empty-fae) | `ZCL_SKYLINT_NO_EMPTY_FAE` | <code>#EC NO_EMPTY_FAE</code> | ⚡ Ready |
| [Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)](/rules/no-select-star) | `ZCL_SKYLINT_NO_SELECT_STAR` | <code>#EC NO_SELECT_STAR</code> | - |
| [Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops](/rules/no-endselect) | `ZCL_SKYLINT_NO_ENDSELECT` | <code>#EC NO_ENDSELECT</code> | - |
| [Require Explicit ORDER BY for Deterministic SELECT Queries](/rules/pref-order-by) | `ZCL_SKYLINT_PREF_ORDER_BY` | <code>#EC PREF_ORDER_BY</code> | - |
| [Specify TRANSPORTING in Internal Table MODIFY and READ Operations](/rules/pref-transport) | `ZCL_SKYLINT_PREF_TRANSPORT` | <code>#EC PREF_TRANSPORT</code> | - |
| [Prefer Pass-by-Reference for Internal Tables in Method Signatures](/rules/pref-pass-by-ref) | `ZCL_SKYLINT_PREF_PASS_BY_REF` | <code>#EC PREF_PASS_BY_REF</code> | - |
| [Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)](/rules/no-mod-loop-tab) | `ZCL_SKYLINT_NO_MOD_LOOP_TAB` | <code>#EC NO_MOD_LOOP_TAB</code> | - |
| [Avoid String Concatenation Inside Loops (Quadratic Memory Allocation)](/rules/no-concat-loop) | `ZCL_SKYLINT_NO_CONCAT_LOOP` | <code>#EC NO_CONCAT_LOOP</code> | - |
| [Prefer ASSIGNING over LOOP INTO Copy Targets](/rules/no-loop-into) | `ZCL_SKYLINT_NO_LOOP_INTO` | <code>#EC NO_LOOP_INTO</code> | - |

---

[← Back to All Rules Catalog](/rules/)
