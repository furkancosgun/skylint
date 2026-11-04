---
title: "Avoid Explicit RAISE SHORTDUMP in Application Logic"
description: "Eliminate deliberate ST22 runtime crashes in SAP applications by replacing RAISE SHORTDUMP with structured, catchable class-based exceptions."
keywords: "no-raise-shortdump, RAISE SHORTDUMP, ST22 dump, ABAP Cloud, Clean ABAP"
category: "security"
ruleId: "no-raise-shortdump"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1897"
---

# Avoid Explicit RAISE SHORTDUMP in Application Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAISE_SHORTDUMP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1897" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid RAISE SHORTDUMP.

> **ATC Finding Message:** `Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions`

## Rationale

The RAISE SHORTDUMP statement deliberately terminates execution by creating an ST22 runtime dump with an uncatchable exception. Manually aborting application processing circumvents structured exception handling hierarchies, prevents cleanup handlers and transaction rollback routines from executing gracefully, and leaves external systems without informative error responses. Applications should raise catchable class-based exceptions (inheriting from CX_STATIC_CHECK or CX_NO_CHECK) containing contextual error parameters that permit calling layers to recover or log the failure cleanly.

### Non-Compliant

```abap
IF ls_sales_order_header-customer_id IS INITIAL.
  RAISE SHORTDUMP TYPE cx_no_check.
ENDIF.
```

### Compliant

```abap
IF ls_sales_order_header-customer_id IS INITIAL.
  RAISE EXCEPTION NEW cx_no_check( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAISE_SHORTDUMP

" SAP CI_ prefix format:
... "#EC CI_NO_RAISE_SHORTDUMP
```

### Impact and Mitigation

The rule checks for statements starting with `RAISE` that contain the `SHORTDUMP` token, reporting finding code `NO_DUMP`.

Rather than executing `RAISE SHORTDUMP TYPE <class>`, application components should instantiate and raise a domain-specific exception using `RAISE EXCEPTION NEW <class>( ... )`. This allows top-level exception boundaries, background job frameworks, or OData gateway runtimes to handle the incident predictably.

Findings can be suppressed using the pseudo-comment `"#EC NO_RAISE_SHORTDUMP`.


## Related Rules

* [Avoid Raising System Exceptions Directly (cx_sy_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Protect CALL TRANSACTION Statements with AUTHORITY-CHECK](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Check sy-subrc Immediately After AUTHORITY-CHECK](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAISE_SHORTDUMP`
* **ABAP Implementation:** [/skyl/cl_no_raise_shortdump.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raise_shortdump.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1897)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1897)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RAISE_SHORTDUMP&title=%5BBug%5D%3A%20Issue%20in%20no-raise-shortdump)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-raise-shortdump)**
