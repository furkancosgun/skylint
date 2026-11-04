---
title: "Handle System and Communication Failures in Remote RFC Calls"
description: "Prevent runtime short dumps during SAP RFC integration by handling COMMUNICATION_FAILURE, SYSTEM_FAILURE, and RESOURCE_FAILURE."
keywords: "no-rfc-err, COMMUNICATION_FAILURE, SYSTEM_FAILURE, RESOURCE_FAILURE, RFC Exception Handling, SAP ATC"
category: "security"
ruleId: "no-rfc-err"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2957"
---

# Handle System and Communication Failures in Remote RFC Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RFC_ERR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2957" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

RFC calls must handle system failures.

> **ATC Finding Message:** `RFC call must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE`

## Rationale

When calling remote function modules via CALL FUNCTION ... DESTINATION or asynchronous tasks with STARTING NEW TASK ... DESTINATION IN GROUP, network timeouts, gateway disconnections, target kernel crashes, or RFC resource exhaustion trigger classical exceptions COMMUNICATION_FAILURE, SYSTEM_FAILURE, or RESOURCE_FAILURE. Omitting these exception handlers causes the calling work process to crash immediately with an unhandled RFC_COMMUNICATION_ERROR or CALL_FUNCTION_NOT_FOUND runtime dump. In Clean ABAP and SAP ATC robustness guidelines, every RFC invocation must catch communication and system failures with the MESSAGE addition to capture diagnostic error text and maintain transactional resilience.

### Non-Compliant

```abap
CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
  DESTINATION lv_rfcdest
  EXPORTING
    order_header_in = ls_order_header.
```

### Compliant

```abap
CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
  DESTINATION lv_rfcdest
  EXPORTING
    order_header_in       = ls_order_header
  EXCEPTIONS
    communication_failure = 1 MESSAGE lv_comm_error
    system_failure        = 2 MESSAGE lv_sys_error
    others                = 3.

IF sy-subrc <> 0.
  mo_logger->error( |Remote RFC call failed: { lv_comm_error } { lv_sys_error }| ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RFC_ERR

" SAP CI_ prefix format:
... "#EC CI_NO_RFC_ERR
```

## Required Exceptions by RFC Mode

The check inspects `CALL FUNCTION` statements containing `DESTINATION` or `STARTING NEW TASK` and verifies that the `EXCEPTIONS` clause catches all required failure modes:

| RFC Invocation Syntax | Mandatory Exceptions in `EXCEPTIONS` Block |
|---|---|
| `CALL FUNCTION ... DESTINATION <dest>` | `COMMUNICATION_FAILURE`, `SYSTEM_FAILURE` |
| `CALL FUNCTION ... STARTING NEW TASK ... DESTINATION IN GROUP <grp>` | `COMMUNICATION_FAILURE`, `SYSTEM_FAILURE`, `RESOURCE_FAILURE` |

Capturing the error message using `MESSAGE <lv_message_var>` is recommended so diagnostic details returned by the remote gateway or kernel can be recorded in application logs. Suppress individual findings using the pseudo comment `"#EC NO_RFC_ERR`.


## Related Rules

* [Avoid Internal C-Kernel Calls and Native Database SQL](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>
* [Avoid Dynamic Metaprogramming and Runtime Code Generation](/rules/no-metaprogramming) — <code>#EC NO_METAPROGRAMMING</code>
* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RFC_ERR`
* **ABAP Implementation:** [/skyl/cl_no_rfc_err.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_rfc_err.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2957)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2957)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RFC_ERR&title=%5BBug%5D%3A%20Issue%20in%20no-rfc-err)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-rfc-err)**
