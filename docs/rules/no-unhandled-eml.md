---
title: "Provide FAILED and REPORTED in RAP EML Statements"
description: "Enforce FAILED and REPORTED response clauses in ABAP RAP EML statements to prevent silent transactional failures and data inconsistency."
keywords: "no-unhandled-eml, ABAP RAP EML, FAILED and REPORTED, Business Object Security, Clean ABAP, SAP ATC"
category: "security"
ruleId: "no-unhandled-eml"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3954"
---

# Provide FAILED and REPORTED in RAP EML Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNHANDLED_EML" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3954" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Provide FAILED and REPORTED in RAP EML statements.

> **ATC Finding Message:** `Always provide FAILED and REPORTED in EML statements`

## Rationale

In the ABAP RESTful Application Programming Model (RAP), Entity Manipulation Language (EML) statements interact with business objects during transactional phases. Omitting FAILED and REPORTED clauses causes validation failures, authorization denials, and lock conflicts to fail silently. When response parameters are omitted, the calling program proceeds under the mistaken assumption that changes were successfully applied, leading to transactional buffer discrepancies, partial updates, and severe data inconsistency. Clean ABAP and SAP RAP architecture require always specifying both FAILED and REPORTED clauses and validating error tables before committing transactions.

### Non-Compliant

```abap
MODIFY ENTITIES OF z_root_travel
  ENTITY travel
  UPDATE FIELDS ( description total_price )
  WITH lt_travel_updates.
```

### Compliant

```abap
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
| `CHECK_MODIFY` | `Boolean` | <code>true</code> | Enforce FAILED and REPORTED response structures on MODIFY ENTITY and MODIFY ENTITIES statements (default: true). |
| `CHECK_READ` | `Boolean` | <code>true</code> | Enforce FAILED and REPORTED response structures on READ ENTITY and READ ENTITIES statements (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNHANDLED_EML

" SAP CI_ prefix format:
... "#EC CI_NO_UNHANDLED_EML
```

## Required EML Response Handling

The check inspects RAP EML operations and verifies that both response parameters are explicitly declared:

| EML Statement | Parameter Checked | Finding Behavior | Quickfix Code |
|---|---|---|---|
| `MODIFY ENTITY` / `MODIFY ENTITIES` | Controlled by `CHECK_MODIFY` | Flagged if `FAILED` or `REPORTED` is omitted | `ADD_EML` |
| `READ ENTITY` / `READ ENTITIES` | Controlled by `CHECK_READ` | Flagged if `FAILED` or `REPORTED` is omitted | `ADD_EML` |

When either clause is missing, the `ADD_EML` quickfix automatically appends `FAILED DATA(failed)` and/or `REPORTED DATA(reported)` to the end of the EML statement. Suppress false positives using `"#EC NO_UNHANDLED_EML` or `##NO_UNHANDLED_EML`.


## Related Rules

* [Avoid Dynamic OpenSQL and Metaprogramming Language Constructs](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>
* [Avoid Dynamic Metaprogramming and Runtime Code Generation](/rules/no-metaprogramming) — <code>#EC NO_METAPROGRAMMING</code>
* [Avoid Internal C-Kernel Calls and Native Database SQL](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNHANDLED_EML`
* **ABAP Implementation:** [/skyl/cl_no_unhandled_eml.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unhandled_eml.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3954)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3954)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNHANDLED_EML&title=%5BBug%5D%3A%20Issue%20in%20no-unhandled-eml)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unhandled-eml)**
