---
title: "Limit Jump Statements (CONTINUE and EXIT) per Loop"
description: "Limit CONTINUE and EXIT statements per ABAP loop to prevent tangled loop control flow and improve iteration readability in SAP ATC."
keywords: "max-loop-jumps, CONTINUE EXIT limit, Clean ABAP loop, loop control flow, SAP ATC metrics"
category: "metrics"
ruleId: "max-loop-jumps"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5555"
---

# Limit Jump Statements (CONTINUE and EXIT) per Loop

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_LOOP_JUMPS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5555" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit jump statements (CONTINUE/EXIT) per loop.

> **ATC Finding Message:** `Loop has too many jump statements (CONTINUE/EXIT); simplify loop control flow`

## Rationale

Loops with multiple scattered CONTINUE and EXIT statements introduce unstructured control jumps that make it difficult to reason about loop invariants, post-conditions, and iteration state. Clean ABAP recommends keeping loop bodies small, predictable, and focused on processing elements. When a loop requires three or more jumps, filtering criteria should be pushed into a WHERE condition on the LOOP AT statement, iterations should use table expressions or FILTER #( ), or inner processing logic should be encapsulated inside a dedicated helper method to maintain Clean Core maintainability.

### Non-Compliant

```abap
LOOP AT lt_billing_items ASSIGNING FIELD-SYMBOL(<ls_item>).
  IF <ls_item>-is_deleted = abap_true.
    CONTINUE.
  ENDIF.
  IF <ls_item>-quantity <= 0.
    CONTINUE.
  ENDIF.
  IF <ls_item>-is_fatal_error = abap_true.
    EXIT.
  ENDIF.
  process_billing_item( <ls_item> ).
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_billing_items ASSIGNING FIELD-SYMBOL(<ls_item>)
     WHERE is_deleted = abap_false AND quantity > 0.
  IF process_item_safely( <ls_item> ) = abap_false.
    EXIT.
  ENDIF.
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_LOOP_JUMPS` | `Integer` | <code>2</code> | Maximum allowed jump statements (CONTINUE or EXIT) within a single LOOP, DO, or WHILE iteration block (default: 2). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_LOOP_JUMPS

" SAP CI_ prefix format:
... "#EC CI_MAX_LOOP_JUMPS
```

## Detection Scope

The check inspects all loop constructs (`LOOP AT ...`, `DO ... TIMES`, and `WHILE ...`):

- **Jump Statements**: Counts each statement with keyword `CONTINUE` or `EXIT`.
- **Nesting Isolation**: An internal loop stack tracks jumps per loop level. Jumps within an inner loop do not affect the jump counter of the outer enclosing loop.
- **Reporting**: When `ENDLOOP`, `ENDDO`, or `ENDWHILE` is reached and the count of jump statements exceeds `MAX_LOOP_JUMPS` (default `2`), finding `MAX_JUMPS` is reported on the opening loop statement (`LOOP`, `DO`, or `WHILE`).

## Suppression

Suppress a finding using the pseudo-comment `"#EC MAX_LOOP_JUMPS` placed on the opening loop statement (`LOOP`, `DO`, `WHILE`).


## Related Rules

* [Avoid CHECK Statements Inside and Outside Iteration Loops](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>
* [Avoid Unindexed Nested LOOP AT Statements](/rules/no-nested-loop) — <code>#EC NO_NESTED_LOOP</code>
* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_LOOP_JUMPS`
* **ABAP Implementation:** [/skyl/cl_max_loop_jumps.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_loop_jumps.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5555)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5555)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_LOOP_JUMPS&title=%5BBug%5D%3A%20Issue%20in%20max-loop-jumps)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-loop-jumps)**
