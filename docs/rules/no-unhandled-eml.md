---
title: "Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)"
description: "Prevent silent data corruption in ABAP RAP by requiring FAILED and REPORTED clauses in all EML statements."
keywords: "ABAP RAP EML Statements, FAILED REPORTED RAP, Silent Transaction Failure SAP, Clean ABAP Cloud RAP"
category: "security"
ruleId: "no-unhandled-eml"
---

# Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_UNHANDLED_EML" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Provide FAILED and REPORTED in RAP EML statements.

> **ATC Finding Message:** `Always provide FAILED and REPORTED in EML statements`

## Rationale

In the ABAP RESTful Application Programming Model (RAP), Entity Manipulation Language (EML) statements process transactional data across Business Objects. Omitting `FAILED` and `REPORTED` clauses causes business exceptions, validation errors, and lock rejections to fail silently. The caller assumes success while the transactional buffer remains unsaved, resulting in severe data inconsistency.

**RAP Standard:** Always provide both response parameters (`FAILED DATA(lt_failed) REPORTED DATA(lt_reported)`) and check `IF lt_failed IS NOT INITIAL` before proceeding or committing.

### Non-Compliant

```abap
" Dangerous: Omits response structures; silent failure on lock or validation error
MODIFY ENTITIES OF z_root_travel
  ENTITY travel
  UPDATE FIELDS ( description total_price )
  WITH lt_travel_updates.
```

### Compliant

```abap
" Clean RAP: Inspects failed keys and propagates messages to caller
MODIFY ENTITIES OF z_root_travel
  ENTITY travel
  UPDATE FIELDS ( description total_price )
  WITH lt_travel_updates
  FAILED DATA(lt_failed)
  REPORTED DATA(lt_reported).

IF lt_failed IS NOT INITIAL.
  mo_message_handler->propagate_errors( lt_reported ).
  RETURN.
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_MODIFY` | `Boolean` | <code>true</code> | Enforce FAILED and REPORTED on MODIFY ENTITY / ENTITIES statements |
| `CHECK_READ` | `Boolean` | <code>true</code> | Enforce FAILED and REPORTED on READ ENTITY / ENTITIES statements |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNHANDLED_EML

" SAP CI_ prefix format:
... "#EC CI_NO_UNHANDLED_EML
```


## Related Rules

* [Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>
* [Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)](/rules/no-metaprogramming) — <code>#EC NO_METAPROGRAMMING</code>
* [Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNHANDLED_EML`
* **Implementation File:** [zcl_skylint_no_unhandled_eml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unhandled_eml.clas.abap)
