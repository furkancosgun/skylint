---
title: "Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)"
description: "Prevent CWE-862 authorization bypass vulnerabilities in SAP ABAP by verifying sy-subrc immediately following AUTHORITY-CHECK statements."
keywords: "CWE-862 ABAP, AUTHORITY-CHECK sy-subrc, SAP Security Audit Log, Clean ABAP Authorization, Privilege Escalation SAP"
---

# Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC PREF_AUTH_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Check sy-subrc immediately after AUTHORITY-CHECK.

> **ATC Finding Message:** `AUTHORITY-CHECK sy-subrc must be checked immediately; failing to check bypasses authorization`

## Rationale

Executing `AUTHORITY-CHECK` without verifying `sy-subrc` immediately afterwards is one of the most critical security vulnerabilities in SAP ABAP (CWE-862: Missing Authorization Check). The SAP kernel evaluates the user's authorizations and sets `sy-subrc` to 0 on success or a non-zero code on failure. If intermediate statements execute before evaluating `sy-subrc`, another statement might overwrite `sy-subrc`, resulting in unauthorized privilege escalation.

**Security Standard:** Always check `IF sy-subrc <> 0` immediately on the statement following `AUTHORITY-CHECK` and raise an authorization exception or terminate execution.

### Non-Compliant

```abap
" Critical Vulnerability: sy-subrc is NOT checked immediately; overwritten by subsequent SELECT
AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
  ID 'ACTVT' FIELD '02'.

SELECT SINGLE * FROM zsens_data INTO @DATA(ls_data). " Overwrites sy-subrc!
IF sy-subrc <> 0. " Checks SELECT, not the authorization check!
  MESSAGE 'Not authorized' TYPE 'E'.
ENDIF.
```

### Compliant

```abap
" Secure: Immediate verification prevents authorization bypass
AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
  ID 'ACTVT' FIELD '02'.
IF sy-subrc <> 0.
  RAISE EXCEPTION NEW zcx_auth_exception( textid = zcx_auth_exception=>c_not_authorized ).
ENDIF.

SELECT SINGLE * FROM zsens_data INTO @DATA(ls_data).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_AUTH_SUBRC

" SAP CI_ prefix format:
... "#EC CI_PREF_AUTH_SUBRC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_AUTH_SUBRC`
* **Implementation File:** [zcl_skylint_pref_auth_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_auth_subrc.clas.abap)
