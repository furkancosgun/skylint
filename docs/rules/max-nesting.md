---
title: "Limit Control Flow Block Nesting Depth"
description: "Enforce control flow nesting depth limits in ABAP methods to eliminate arrow antipatterns and promote clean guard clauses."
keywords: "max-nesting, Clean ABAP, guard clauses, control flow nesting, SAP ATC"
category: "metrics"
ruleId: "max-nesting"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1754"
---

# Limit Control Flow Block Nesting Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_NESTING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1754" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Nesting Depth Limit (excessive control block nesting).

> **ATC Finding Message:** `Control block nesting depth exceeds`

## Rationale

Deeply nested control structures (such as `IF`, `CASE`, `LOOP`, `DO`, `WHILE`, and `TRY`) cause the 'Arrow Antipattern', where code drifts heavily toward the right margin of the editor. Each level of nesting multiplies the developer's cognitive load, obscures error handling branches, and drastically increases the number of execution permutations that must be exercised during automated unit testing. Clean ABAP mandates flat control flow: inverting conditions and adopting guard clauses with early `RETURN`, `EXIT`, or `CONTINUE` statements keeps the happy path unindented and transparent.

### Non-Compliant

```abap
METHOD process_customer_order.
  IF is_order-is_active = abap_true.
    LOOP AT is_order-items INTO DATA(ls_item).
      IF ls_item-quantity > 0.
        IF ls_item-is_blocked = abap_false.
          reserve_inventory_stock( ls_item ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD process_customer_order.
  IF is_order-is_active = abap_false.
    RETURN.
  ENDIF.

  LOOP AT is_order-items INTO DATA(ls_item).
    IF ls_item-quantity <= 0 OR ls_item-is_blocked = abap_true.
      CONTINUE.
    ENDIF.

    reserve_inventory_stock( ls_item ).
  ENDLOOP.
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_DEPTH` | `Integer` | <code>3</code> | Maximum allowable nesting depth for control blocks (IF, CASE, LOOP, DO, WHILE, TRY) before reporting (default: 3). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_NESTING

" SAP CI_ prefix format:
... "#EC CI_MAX_NESTING
```

## Monitored Block Keywords

The check tracks nesting depth dynamically across all procedure statements:

- **Increments Depth:** `IF`, `CASE`, `LOOP`, `DO`, `WHILE`, and `TRY`.
- **Decrements Depth:** `ENDIF`, `ENDCASE`, `ENDLOOP`, `ENDDO`, `ENDWHILE`, and `ENDTRY`.

| Finding Code | Severity | Trigger | Suppression |
|---|---|---|---|
| `MAX_NEST` | Warning | Block statement nested beyond `MAX_DEPTH` (default 3 levels) | `##MAX_NESTING` or `"#EC MAX_NESTING` |

### Guard Clause Refactoring
Instead of nesting positive checks deeply, invert preconditions at the start of the procedure and exit immediately via `RETURN` or `CONTINUE`.


## Related Rules

* [Limit Class Inheritance Depth and Favor Object Composition](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_NESTING`
* **ABAP Implementation:** [/skyl/cl_max_nesting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_nesting.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1754)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1754)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_NESTING&title=%5BBug%5D%3A%20Issue%20in%20max-nesting)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-nesting)**
