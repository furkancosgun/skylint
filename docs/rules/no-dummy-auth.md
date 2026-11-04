---
title: "Avoid DUMMY Addition in AUTHORITY-CHECK Statements"
description: "Detect AUTHORITY-CHECK statements using the DUMMY addition in ABAP to prevent authorization check bypasses and access control vulnerabilities."
keywords: "no-dummy-auth, AUTHORITY-CHECK DUMMY, ABAP Authorization Security, Broken Access Control, Clean ABAP, SAP ATC"
category: "security"
ruleId: "no-dummy-auth"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4570"
---

# Avoid DUMMY Addition in AUTHORITY-CHECK Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_DUMMY_AUTH" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4570" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid AUTHORITY-CHECK with the DUMMY addition.

> **ATC Finding Message:** `AUTHORITY-CHECK DUMMY never checks the field; supply FIELD and evaluate sy-subrc`

## Rationale

The DUMMY addition in an AUTHORITY-CHECK statement bypasses authorization verification for the designated authorization field, causing the SAP kernel to accept the check without verifying the user's role assignment against that field. Developers sometimes insert DUMMY as a temporary workaround during local development or to satisfy rudimentary static security scans without implementing real access control, leaving sensitive business operations exposed to unauthorized users (OWASP Top 10 A01: Broken Access Control). Clean ABAP and SAP ATC security guidelines require supplying valid authorization field values using the FIELD addition and verifying sy-subrc immediately.

### Non-Compliant

```abap
AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
  ID 'BUKRS' DUMMY
  ID 'ACTVT' FIELD '03'.
```

### Compliant

```abap
AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
  ID 'BUKRS' FIELD lv_company_code
  ID 'ACTVT' FIELD '03'.

IF sy-subrc <> 0.
  RAISE EXCEPTION NEW zcx_auth_failure( ).
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

## Security Risk of DUMMY Field Checks

In ABAP authorization checks, `ID <field> DUMMY` informs the kernel that the authorization field should be ignored during evaluation:

| AUTHORITY-CHECK Construct | Kernel Evaluation Behavior | Security Status |
|---|---|---|
| `ID <field> DUMMY` | Authorization field is completely ignored; any user passes | Insecure (Broken Access Control) |
| `ID <field> FIELD lv_val` | Verified against user profile / authorization role | Secure (Enforced access control) |
| `OBJECT 'DUMMY'` | Evaluates authorization object named `DUMMY` | Permitted (string literal name) |

The check scans `AUTHORITY-CHECK OBJECT` statements and flags any occurrence of the `DUMMY` keyword. Literal strings (such as authorization object names) are not flagged. Suppress approved exceptions with `"#EC NO_DUMMY_AUTH` or `##NO_DUMMY_AUTH`.


## Related Rules

* [Check sy-subrc Immediately After AUTHORITY-CHECK](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>
* [Protect CALL TRANSACTION Statements with AUTHORITY-CHECK](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Avoid Dynamic OpenSQL and Metaprogramming Language Constructs](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DUMMY_AUTH`
* **ABAP Implementation:** [/skyl/cl_no_dummy_auth.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dummy_auth.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4570)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4570)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUMMY_AUTH&title=%5BBug%5D%3A%20Issue%20in%20no-dummy-auth)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dummy-auth)**
