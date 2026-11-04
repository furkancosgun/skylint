---
title: "Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)"
description: "Prevent silent data corruption in ABAP RAP by requiring FAILED and REPORTED clauses in all EML statements."
keywords: "ABAP RAP EML Statements, FAILED REPORTED RAP, Silent Transaction Failure SAP, Clean ABAP Cloud RAP"
category: "security"
ruleId: "no-unhandled-eml"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3861"
---

# Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNHANDLED_EML" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3861" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

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

* **Native ATC Class:** `/SKYL/CL_NO_UNHANDLED_EML`
* **ABAP Implementation:** [/skyl/cl_no_unhandled_eml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unhandled_eml.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3861)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3861)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNHANDLED_EML&title=%5BBug%5D%3A%20Issue%20in%20no-unhandled-eml)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unhandled-eml)**
