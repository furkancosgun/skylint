---
title: "Avoid DUMMY Authorization Checks"
description: "Detect AUTHORITY-CHECK statements that use the DUMMY addition, which silently disables the authorization check and exposes protected operations."
keywords: "ABAP AUTHORITY-CHECK DUMMY, ABAP authorization bypass, SAP ATC security check, ABAP authorization check, SAP security anti-pattern"
category: "security"
ruleId: "no-dummy-auth"
---

# Avoid DUMMY Authorization Checks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_DUMMY_AUTH" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid AUTHORITY-CHECK with the DUMMY addition.

> **ATC Finding Message:** `AUTHORITY-CHECK DUMMY never checks the field; supply FIELD and evaluate sy-subrc`

## Rationale

The DUMMY addition turns AUTHORITY-CHECK into a no-op: the runtime accepts the statement without evaluating the authorization object, so the protected operation runs for every user. Such dummy checks are frequently added to satisfy scanners or to unblock a test and then remain in production. Remove the DUMMY addition and evaluate sy-subrc so the authorization is genuinely enforced.

### Non-Compliant

```abap
AUTHORITY-CHECK OBJECT 'Z_FI_BUKRS'
  ID 'BUKRS' DUMMY.
```

### Compliant

```abap
AUTHORITY-CHECK OBJECT 'Z_FI_BUKRS'
  ID 'BUKRS' FIELD lv_bukrs.
IF sy-subrc <> 0.
  RAISE EXCEPTION NEW zcx_no_authorization( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUMMY_AUTH

" SAP CI_ prefix format:
... "#EC CI_NO_DUMMY_AUTH
```


## Related Rules

* [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>
* [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUMMY_AUTH`
* **Implementation File:** [zcl_skylint_no_dummy_auth.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dummy_auth.clas.abap)
