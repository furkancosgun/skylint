---
title: "Avoid DUMMY Authorization Checks"
description: "Detect AUTHORITY-CHECK statements that use the DUMMY addition, which silently disables the authorization check and exposes protected operations."
keywords: "ABAP AUTHORITY-CHECK DUMMY, ABAP authorization bypass, SAP ATC security check, ABAP authorization check, SAP security anti-pattern"
category: "security"
ruleId: "no-dummy-auth"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4460"
---

# Avoid DUMMY Authorization Checks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_DUMMY_AUTH" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4460" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

* **Native ATC Class:** `/SKYL/CL_NO_DUMMY_AUTH`
* **ABAP Implementation:** [/skyl/cl_no_dummy_auth.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dummy_auth.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4460)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4460)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DUMMY_AUTH&title=%5BBug%5D%3A%20Issue%20in%20no-dummy-auth)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dummy-auth)**
