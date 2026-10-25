---
title: "Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations"
description: "Ensure role-based authorization checks precede sensitive database modifications and financial records in SAP ABAP."
keywords: "SAP Authorization Check, Role-Based Access Control ABAP, Data Security SAP, ATC Security Check"
category: "security"
ruleId: "pref-auth-check"
---

# Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_AUTH_CHECK" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Call Transaction Authority Check.

> **ATC Finding Message:** `CALL TRANSACTION must be protected with AUTHORITY-CHECK`

## Rationale

Accessing or modifying sensitive business entities (such as financials, HR master data, and sales pricing) without prior authorization verification allows unauthorized users to read or tamper with protected company assets. Every business service, remote-enabled function module, or RAP BO handler must enforce an explicit authorization check at the entry point of sensitive operations.

### Non-Compliant

```abap
" Insecure: Direct update to payroll records without verifying user permissions
UPDATE pa0008 SET betrg = @iv_new_salary WHERE pernr = @iv_employee_id.
```

### Compliant

```abap
" Secure: Authorization check precedes data modification
AUTHORITY-CHECK OBJECT 'P_ORGIN'
  ID 'INFTY' FIELD '0008'
  ID 'AUTHC' FIELD 'W'.
IF sy-subrc <> 0.
  RAISE EXCEPTION NEW zcx_no_authorization( ).
ENDIF.

UPDATE pa0008 SET betrg = @iv_new_salary WHERE pernr = @iv_employee_id.
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
... "#EC PREF_AUTH_CHECK

" SAP CI_ prefix format:
... "#EC CI_PREF_AUTH_CHECK
```


## Related Rules

* [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>
* [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) — <code>#EC PREF_CHECK_SUBRC</code>
* [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_AUTH_CHECK`
* **Implementation File:** [zcl_skylint_pref_auth_check.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_auth_check.clas.abap)
