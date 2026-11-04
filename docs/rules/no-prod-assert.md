---
title: "Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)"
description: "Prevent production short dumps in SAP ABAP by replacing uncatchable ASSERT statements with structured exception handling."
keywords: "ASSERTION_FAILED dump ABAP, Avoid ASSERT in production SAP, Clean ABAP Exception Handling"
category: "security"
ruleId: "no-prod-assert"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1855"
---

# Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_PROD_ASSERT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1855" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Native ASSERT in Production Logic.

> **ATC Finding Message:** `Avoid native ASSERT in production logic; raise an exception instead`

## Rationale

The ABAP statement `ASSERT condition` immediately raises an uncatchable short dump (`ASSERTION_FAILED`) if the condition evaluates to false. While useful in unit test classes, using unconditioned assertions in production application logic abruptly terminates end-user sessions, loses uncommitted data, and creates emergency incidents.

**Best Practice:** Check conditions gracefully and raise recoverable class-based exceptions with informative error messages. Reserve `ASSERT` strictly for ABAP Unit test includes (`LCL_TEST`).

### Non-Compliant

```abap
" Dangerous: Causes catastrophic user session crash in production
ASSERT iv_amount > 0.
```

### Compliant

```abap
" Clean ABAP: Graceful validation with recoverable domain exception
IF iv_amount <= 0.
  RAISE EXCEPTION NEW zcx_invalid_amount( iv_amount ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_PROD_ASSERT

" SAP CI_ prefix format:
... "#EC CI_NO_PROD_ASSERT
```


## Related Rules

* [Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>
* [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_PROD_ASSERT`
* **ABAP Implementation:** [/skyl/cl_no_prod_assert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_prod_assert.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1855)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1855)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_PROD_ASSERT&title=%5BBug%5D%3A%20Issue%20in%20no-prod-assert)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-prod-assert)**
