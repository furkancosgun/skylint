---
title: "Protect CALL TRANSACTION Statements with AUTHORITY-CHECK"
description: "Enforce secure transaction execution in SAP ABAP by requiring WITH AUTHORITY-CHECK on CALL TRANSACTION statements to prevent authorization bypass."
keywords: "pref-auth-check, CALL TRANSACTION, WITH AUTHORITY-CHECK, S_TCODE, SAP authorization"
category: "security"
ruleId: "pref-auth-check"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1981"
---

# Protect CALL TRANSACTION Statements with AUTHORITY-CHECK

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_AUTH_CHECK" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1981" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Call Transaction Authority Check.

> **ATC Finding Message:** `CALL TRANSACTION must be protected with AUTHORITY-CHECK`

## Rationale

Invoking SAP transactions using CALL TRANSACTION without the WITH AUTHORITY-CHECK addition bypasses transaction code authorization verification (authorization object S_TCODE). Without explicit authorization checking, any user who can reach the calling program can execute restricted transactions, leading to unauthorized privilege escalation. In on-premise ABAP systems, CALL TRANSACTION statements must include WITH AUTHORITY-CHECK, while in ABAP Cloud (where CALL TRANSACTION is not permitted), access must be guarded using explicit business object authorization checks or RAP authorization handlers.

### Non-Compliant

```abap
CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
```

### Compliant

```abap
AUTHORITY-CHECK OBJECT 'S_TCODE'
  ID 'TCD' FIELD 'VA03'.
IF sy-subrc <> 0.
  RETURN.
ENDIF.
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

### Detection and QuickFix

The rule identifies `CALL TRANSACTION` statements that lack the `WITH AUTHORITY-CHECK` addition:

- **Finding Code:** `PREF_AUTH`
- **QuickFix Code:** `ADDAUTH` automatically inserts `WITH AUTHORITY-CHECK` after the transaction code identifier.
- **Suppression:** Suppress false positives with pseudo-comment `"#EC PREF_AUTH_CHECK`.

In modern ABAP Cloud environments, `CALL TRANSACTION` is obsolete and forbidden; secure business object access must be implemented using Core Data Services access controls or explicit `AUTHORITY-CHECK` statements against business authorization objects.


## Related Rules

* [Check sy-subrc Immediately After AUTHORITY-CHECK](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>
* [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) — <code>#EC PREF_CHECK_SUBRC</code>
* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_AUTH_CHECK`
* **ABAP Implementation:** [/skyl/cl_pref_auth_check.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_auth_check.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1981)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1981)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_AUTH_CHECK&title=%5BBug%5D%3A%20Issue%20in%20pref-auth-check)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-auth-check)**
