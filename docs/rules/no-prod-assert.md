---
title: "Avoid Native ASSERT Statements in Production Logic"
description: "Prevent catastrophic ASSERTION_FAILED short dumps in production SAP systems by replacing native ASSERT statements with class-based exceptions."
keywords: "no-prod-assert, ASSERTION_FAILED, ABAP short dump, Clean ABAP, exception handling"
category: "security"
ruleId: "no-prod-assert"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1869"
---

# Avoid Native ASSERT Statements in Production Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_PROD_ASSERT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1869" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Native ASSERT in Production Logic.

> **ATC Finding Message:** `Avoid native ASSERT in production logic; raise an exception instead`

## Rationale

The native ASSERT statement triggers an immediate and uncatchable runtime crash (ASSERTION_FAILED short dump) when the condition evaluates to false. In production business processing, triggering an uncatchable short dump abruptly aborts the user session, discards uncommitted transactional work, and fails to provide diagnostic error details to the caller. Native ASSERT statements belong exclusively in automated test classes (LCL_TEST) or checkpoint groups (ASSERT ID ... CONDITION ...), whereas production business code should evaluate conditions and raise structured, catchable class-based exceptions.

### Non-Compliant

```abap
ASSERT lv_invoice_amount > 0.
```

### Compliant

```abap
IF lv_invoice_amount <= 0.
  RAISE EXCEPTION NEW cx_static_check( ).
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

### Scope and Behavior

The rule flags all native `ASSERT` statements found in non-test procedure implementations with finding code `NO_PRD_AST`. Checkpoint assertions with explicit activation groups (e.g., `ASSERT ID group CONDITION ...`) or unit test assertion methods (`cl_abap_unit_assert=>assert_true`) are recommended alternatives when assertions are required during development or automated testing.

Findings can be suppressed using the pseudo-comment `"#EC NO_PROD_ASSERT`.


## Related Rules

* [Avoid Internal C-Kernel Calls and Native Database SQL](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>
* [Protect CALL TRANSACTION Statements with AUTHORITY-CHECK](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Check sy-subrc Immediately After AUTHORITY-CHECK](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_PROD_ASSERT`
* **ABAP Implementation:** [/skyl/cl_no_prod_assert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_prod_assert.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1869)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1869)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_PROD_ASSERT&title=%5BBug%5D%3A%20Issue%20in%20no-prod-assert)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-prod-assert)**
