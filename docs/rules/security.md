---
title: "Security & Robustness (17 Rules)"
description: "Authorizations, dynamic execution sanitation, error handling, and runtime safety. Comprehensive reference, finding codes, and Clean ABAP examples for Security & Robustness."
category: "security"
keywords: "Clean ABAP, ABAP Cloud, SAP ATC, Security & Robustness, S/4HANA Readiness, SAP BTP, Steampunk"
---

# Security & Robustness (17 Rules)

Authorizations, dynamic execution sanitation, error handling, and runtime safety.

::: tip Category Overview
This category enforces **17 native ATC rules** adhering to SAP Clean ABAP and ABAP Cloud standards. Each check executes natively inside Eclipse ADT and SAP GUI.
:::

## Rules in this Category

| Rule Name | Native ATC Class | Suppression Tag | Automated QuickFix |
|---|---|:---:|:---:|
| [Ensure Opened Datasets and Cursors are Closed](/rules/no-unclosed-res) | `ZCL_SKYLINT_NO_UNCLOSED_RES` | <code>#EC NO_UNCLOSED_RES</code> | - |
| [Avoid Directly Modifying System Fields (sy-subrc, sy-tabix)](/rules/no-sy-modify) | `ZCL_SKYLINT_NO_SY_MODIFY` | <code>#EC NO_SY_MODIFY</code> | - |
| [Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)](/rules/no-prod-assert) | `ZCL_SKYLINT_NO_PROD_ASSERT` | <code>#EC NO_PROD_ASSERT</code> | - |
| [Avoid Explicit RAISE SHORTDUMP in Application Logic](/rules/no-raise-shortdump) | `ZCL_SKYLINT_NO_RAISE_SHORTDUMP` | <code>#EC NO_RAISE_SHORTDUMP</code> | - |
| [Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)](/rules/no-metaprogramming) | `ZCL_SKYLINT_NO_METAPROGRAMMING` | <code>#EC NO_METAPROGRAMMING</code> | - |
| [Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)](/rules/no-kernel-call) | `ZCL_SKYLINT_NO_KERNEL_CALL` | <code>#EC NO_KERNEL_CALL</code> | - |
| [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) | `ZCL_SKYLINT_PREF_AUTH_CHECK` | <code>#EC PREF_AUTH_CHECK</code> | ⚡ Ready |
| [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) | `ZCL_SKYLINT_NO_CATCH_ROOT` | <code>#EC NO_CATCH_ROOT</code> | - |
| [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) | `ZCL_SKYLINT_NO_RAISE_CX_SY` | <code>#EC NO_RAISE_CX_SY</code> | - |
| [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) | `ZCL_SKYLINT_PREF_AUTH_SUBRC` | <code>#EC PREF_AUTH_SUBRC</code> | - |
| [Avoid CLIENT SPECIFIED / USING CLIENT in Cloud (Multi-Tenant Isolation)](/rules/no-client-spec) | `ZCL_SKYLINT_NO_CLIENT_SPEC` | <code>#EC NO_CLIENT_SPEC</code> | ⚡ Ready |
| [Handle System and Communication Failures in Remote Function Calls (RFC)](/rules/no-rfc-err) | `ZCL_SKYLINT_NO_RFC_ERR` | <code>#EC NO_RFC_ERR</code> | - |
| [Only Modify Tables Defined in Your Own Package/Component](/rules/no-mod-std-table) | `ZCL_SKYLINT_NO_MOD_STD_TABLE` | <code>#EC NO_MOD_STD_TABLE</code> | - |
| [Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)](/rules/no-dynamic-stmt) | `ZCL_SKYLINT_NO_DYNAMIC_STMT` | <code>#EC NO_DYNAMIC_STMT</code> | - |
| [Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)](/rules/no-hardcoded-env) | `ZCL_SKYLINT_NO_HARDCODED_ENV` | <code>#EC NO_HARDCODED_ENV</code> | - |
| [Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)](/rules/no-unfilt-dml) | `ZCL_SKYLINT_NO_UNFILT_DML` | <code>#EC NO_UNFILT_DML</code> | - |
| [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) | `ZCL_SKYLINT_NO_UNHANDLED_EML` | <code>#EC NO_UNHANDLED_EML</code> | - |

---

[← Back to All Rules Catalog](/rules/)
