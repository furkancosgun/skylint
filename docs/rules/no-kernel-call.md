---
title: "Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)"
description: "Ensure cross-platform compatibility and cloud compliance by avoiding SYSTEM-CALL and native EXEC SQL in ABAP."
keywords: "SYSTEM-CALL ABAP, EXEC SQL SAP Security, Clean Core Cloud Compliance"
category: "security"
ruleId: "no-kernel-call"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1931"
---

# Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_KERNEL_CALL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1931" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Kernel and Native Calls.

> **ATC Finding Message:** `Avoid internal kernel calls (CALL, SYSTEM-CALL, EXEC SQL)`

## Rationale

Executing internal SAP kernel commands (`SYSTEM-CALL`) or native database procedures (`EXEC SQL`) bypasses the OpenSQL syntax layer, authorization buffers, and client separation. Kernel calls are undocumented, internal SAP proprietary instructions that break across kernel upgrades and are strictly forbidden in ABAP Cloud.

### Non-Compliant

```abap
" Anti-pattern: Undocumented kernel instruction
SYSTEM-CALL rfc_clone_connection.
```

### Compliant

```abap
" Clean ABAP Cloud: Use official released SAP APIs
cl_rfc_connection_factory=>create( )->clone( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_KERNEL_CALL

" SAP CI_ prefix format:
... "#EC CI_NO_KERNEL_CALL
```


## Related Rules

* [Handle System and Communication Failures in Remote Function Calls (RFC)](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>
* [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>
* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_KERNEL_CALL`
* **ABAP Implementation:** [/skyl/cl_no_kernel_call.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_kernel_call.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1931)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1931)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_KERNEL_CALL&title=%5BBug%5D%3A%20Issue%20in%20no-kernel-call)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-kernel-call)**
