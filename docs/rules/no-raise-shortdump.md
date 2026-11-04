---
title: "Avoid Explicit RAISE SHORTDUMP in Application Logic"
description: "Eliminate deliberate crash statements in ABAP by replacing RAISE SHORTDUMP with structured class-based exceptions."
keywords: "RAISE SHORTDUMP ABAP, ST22 Dump Elimination, Clean ABAP Resilience"
category: "security"
ruleId: "no-raise-shortdump"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1880"
---

# Avoid Explicit RAISE SHORTDUMP in Application Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAISE_SHORTDUMP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1880" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid RAISE SHORTDUMP.

> **ATC Finding Message:** `Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions`

## Rationale

The statement `RAISE SHORTDUMP` deliberately triggers an instant runtime crash and short dump in transaction ST22. Triggering intentional crashes bypasses standard cleanup handlers, cancels asynchronous update tasks, and leaves database locks dangling.

**Best Practice:** Raise standard class-based exceptions inheriting from `CX_STATIC_CHECK` or `CX_NO_CHECK`. Allow the caller or global exception boundary to handle the incident gracefully.

### Non-Compliant

```abap
" Anti-pattern: Forces instant ST22 crash
RAISE SHORTDUMP TYPE zcx_fatal_error.
```

### Compliant

```abap
" Clean ABAP: Structured exception allowing caller recovery
RAISE EXCEPTION NEW zcx_fatal_error( textid = zcx_fatal_error=>c_system_unavailable ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAISE_SHORTDUMP

" SAP CI_ prefix format:
... "#EC CI_NO_RAISE_SHORTDUMP
```


## Related Rules

* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAISE_SHORTDUMP`
* **ABAP Implementation:** [/skyl/cl_no_raise_shortdump.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raise_shortdump.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1880)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1880)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RAISE_SHORTDUMP&title=%5BBug%5D%3A%20Issue%20in%20no-raise-shortdump)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-raise-shortdump)**
