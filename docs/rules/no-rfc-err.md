---
title: "Handle System and Communication Failures in Remote Function Calls (RFC)"
description: "Prevent short dumps during remote SAP integration by handling COMMUNICATION_FAILURE and SYSTEM_FAILURE in RFC calls."
keywords: "RFC Exception Handling ABAP, COMMUNICATION_FAILURE SAP, SYSTEM_FAILURE RFC, Resilient SAP Integration"
category: "security"
ruleId: "no-rfc-err"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2897"
---

# Handle System and Communication Failures in Remote Function Calls (RFC)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RFC_ERR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2897" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

RFC calls must handle system failures.

> **ATC Finding Message:** `RFC call must handle SYSTEM_FAILURE and COMMUNICATION_FAILURE`

## Rationale

When invoking remote SAP systems via `CALL FUNCTION ... DESTINATION`, network timeouts, gateway unreachability, target kernel crashes, and authorization rejections trigger classic exceptions `COMMUNICATION_FAILURE` and `SYSTEM_FAILURE`. Omitting these exception handlers causes the local caller to crash with an unhandled short dump (`CALL_FUNCTION_NOT_FOUND` or `RFC_COMMUNICATION_ERROR`).

**Reliability Standard:** Always catch and log both `COMMUNICATION_FAILURE` and `SYSTEM_FAILURE` with `MESSAGE lv_msg` when calling remote destinations.

### Non-Compliant

```abap
" Fragile: Network glitch crashes the entire batch job with short dump
CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
  DESTINATION lv_rfcdest
  EXPORTING
    order_header_in = ls_header.
```

### Compliant

```abap
" Resilient: Catches network and remote kernel failures gracefully
CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
  DESTINATION lv_rfcdest
  EXPORTING
    order_header_in       = ls_header
  EXCEPTIONS
    communication_failure = 1 MESSAGE lv_comm_error
    system_failure        = 2 MESSAGE lv_sys_error
    OTHERS                = 3.

IF sy-subrc <> 0.
  mo_logger->error( |Remote RFC failed: { lv_comm_error } { lv_sys_error }| ).
  RAISE EXCEPTION NEW zcx_rfc_connection_failed( ).
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


## Related Rules

* [Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>
* [Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)](/rules/no-metaprogramming) — <code>#EC NO_METAPROGRAMMING</code>
* [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RFC_ERR`
* **ABAP Implementation:** [/skyl/cl_no_rfc_err.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_rfc_err.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2897)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2897)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RFC_ERR&title=%5BBug%5D%3A%20Issue%20in%20no-rfc-err)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-rfc-err)**
