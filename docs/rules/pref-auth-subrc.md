---
title: "Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)"
description: "Prevent CWE-862 authorization bypass vulnerabilities in SAP ABAP by verifying sy-subrc immediately following AUTHORITY-CHECK statements."
keywords: "CWE-862 ABAP, AUTHORITY-CHECK sy-subrc, SAP Security Audit Log, Clean ABAP Authorization, Privilege Escalation SAP"
category: "security"
ruleId: "pref-auth-subrc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2440"
---

# Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_AUTH_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2440" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_AUTH_SUBRC

" SAP CI_ prefix format:
... "#EC CI_PREF_AUTH_SUBRC
```


## Related Rules

* [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) — <code>#EC PREF_CHECK_SUBRC</code>
* [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_AUTH_SUBRC`
* **ABAP Implementation:** [/skyl/cl_pref_auth_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_auth_subrc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2440)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2440)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_AUTH_SUBRC&title=%5BBug%5D%3A%20Issue%20in%20pref-auth-subrc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-auth-subrc)**
