---
title: "Limit Number of WHEN Branches in CASE Blocks"
description: "Limit the number of WHEN branches in ABAP CASE statements to maintain clean polymorphism and low cyclomatic complexity in SAP ATC."
keywords: "max-when-count, CASE WHEN limit ABAP, Clean ABAP CASE, polymorphism refactoring, SAP ATC metrics"
category: "metrics"
ruleId: "max-when-count"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5493"
---

# Limit Number of WHEN Branches in CASE Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_WHEN_COUNT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5493" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit number of WHEN clauses per CASE.

> **ATC Finding Message:** `CASE statement has too many WHEN clauses; consider refactoring`

## Rationale

A CASE statement containing more than ten WHEN branches is a classic code smell indicating missing polymorphism, lack of strategy patterns, or hardcoded business rules that belong in customizing or database configuration tables. Long CASE blocks inflate cyclomatic complexity, make unit tests tedious and difficult to achieve comprehensive branch coverage on, and violate the Open-Closed Principle (OCP) because adding a new business variant requires modifying existing procedural control flow. In Clean ABAP and ABAP Cloud, replace oversized CASE blocks with object-oriented polymorphism or factory lookup tables.

### Non-Compliant

```abap
CASE ls_order_status-status_code.
  WHEN 'DRAFT'.
    handle_draft_order( ).
  WHEN 'SUBMITTED'.
    handle_submitted_order( ).
  WHEN 'APPROVED'.
    handle_approved_order( ).
  WHEN 'REJECTED'.
    handle_rejected_order( ).
  WHEN 'PROCESSING'.
    handle_processing_order( ).
  WHEN 'SHIPPED'.
    handle_shipped_order( ).
  WHEN 'DELIVERED'.
    handle_delivered_order( ).
  WHEN 'INVOICED'.
    handle_invoiced_order( ).
  WHEN 'PAID'.
    handle_paid_order( ).
  WHEN 'CANCELLED'.
    handle_cancelled_order( ).
  WHEN OTHERS.
    handle_unknown_status( ).
ENDCASE.
```

### Compliant

```abap
DATA lo_order_handler TYPE REF TO zif_order_status_handler.

lo_order_handler = mo_status_factory->get_handler( ls_order_status-status_code ).
lo_order_handler->process_status( ls_order_status ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_WHEN_COUNT` | `Integer` | <code>10</code> | Maximum number of WHEN clauses (including WHEN OTHERS) allowed in a single CASE statement block (default: 10). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_WHEN_COUNT

" SAP CI_ prefix format:
... "#EC CI_MAX_WHEN_COUNT
```

## Branch Counting and Stack Behavior

- **Clause Counting**: Every statement with keyword `WHEN` is counted, including `WHEN OTHERS`.
- **Nesting Support**: An internal stack tracks nested `CASE ... ENDCASE` structures independently. Branches inside an inner `CASE` block do not increment the counter of the enclosing outer block.
- **Reporting**: When `ENDCASE` is reached and the recorded branch count exceeds `MAX_WHEN_COUNT` (default `10`), finding code `MAX_WHEN` is reported on the opening `CASE` statement.

## Suppression

Suppress a finding with the pseudo-comment `"#EC MAX_WHEN_COUNT` placed on the opening `CASE` statement.


## Related Rules

* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Number of ELSEIF Branches in IF Statements](/rules/max-elseif-count) — <code>#EC MAX_ELSEIF_COUNT</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_WHEN_COUNT`
* **ABAP Implementation:** [/skyl/cl_max_when_count.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_when_count.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5493)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5493)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_WHEN_COUNT&title=%5BBug%5D%3A%20Issue%20in%20max-when-count)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-when-count)**
