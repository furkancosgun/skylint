---
title: "Check sy-subrc Immediately After AUTHORITY-CHECK"
description: "Prevent CWE-862 authorization bypass vulnerabilities in SAP ABAP by verifying sy-subrc immediately following AUTHORITY-CHECK statements."
keywords: "pref-auth-subrc, AUTHORITY-CHECK, CWE-862, sy-subrc, SAP security"
category: "security"
ruleId: "pref-auth-subrc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2486"
---

# Check sy-subrc Immediately After AUTHORITY-CHECK

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_AUTH_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2486" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Check sy-subrc immediately after AUTHORITY-CHECK.

> **ATC Finding Message:** `AUTHORITY-CHECK sy-subrc must be checked immediately; failing to check bypasses authorization`

## Rationale

Executing an AUTHORITY-CHECK statement without immediately inspecting sy-subrc is a critical security vulnerability classified under CWE-862 (Missing Authorization Check). The SAP kernel evaluates user authorizations and returns sy-subrc = 0 on success or a non-zero authorization return code on failure. If intermediate statements execute before evaluating sy-subrc, subsequent statements (such as SELECT, READ TABLE, or method calls) overwrite sy-subrc, inadvertently allowing unauthorized users to execute privileged operations or access confidential data.

### Non-Compliant

```abap
DATA lv_partner_id TYPE string VALUE '1000001'.
AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
  ID 'DICBERCLS' FIELD '&NC&'
  ID 'ACTVT'     FIELD '03'.

SELECT SINGLE partner, name_first
  FROM but000
  WHERE partner = @lv_partner_id
  INTO @DATA(ls_partner).
" Anti-pattern: sy-subrc was overwritten by SELECT without checking authorization!
```

### Compliant

```abap
DATA lv_partner_id TYPE string VALUE '1000001'.
AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
  ID 'DICBERCLS' FIELD '&NC&'
  ID 'ACTVT'     FIELD '03'.
IF sy-subrc <> 0.
  RETURN.
ENDIF.

SELECT SINGLE partner, name_first
  FROM but000
  WHERE partner = @lv_partner_id
  INTO @DATA(ls_partner).
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

### Security Vulnerability (CWE-862)

Omitting the `sy-subrc` check immediately following `AUTHORITY-CHECK` leads to privilege escalation because any subsequent statement that succeeds sets `sy-subrc` to 0, completely nullifying the security check.

- **Finding Code:** `PREF_AUTHS` (Severity: Error)
- **QuickFix Code:** `CHK_AUTHS` automatically inserts the standard `IF sy-subrc <> 0. RETURN. ENDIF.` block immediately following the `AUTHORITY-CHECK` statement.
- **Suppression:** Suppress with pseudo-comment `"#EC PREF_AUTH_SUBRC`.


## Related Rules

* [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) — <code>#EC PREF_CHECK_SUBRC</code>
* [Protect CALL TRANSACTION Statements with AUTHORITY-CHECK](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_AUTH_SUBRC`
* **ABAP Implementation:** [/skyl/cl_pref_auth_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_auth_subrc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2486)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2486)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_AUTH_SUBRC&title=%5BBug%5D%3A%20Issue%20in%20pref-auth-subrc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-auth-subrc)**
