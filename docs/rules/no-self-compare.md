---
title: "Avoid Comparisons and Operations with Identical Operands"
description: "Detect redundant comparisons and arithmetic operations with identical left and right operands in ABAP conditional statements."
keywords: "self comparison ABAP, tautology check, Clean ABAP logic, SAP ATC check, no-self-compare"
category: "anti-patterns"
ruleId: "no-self-compare"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4238"
---

# Avoid Comparisons and Operations with Identical Operands

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SELF_COMPARE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4238" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect comparisons and arithmetic with identical operands.

> **ATC Finding Messages:**
> - `Both sides of the comparison resolve to the same symbol`
> - `Arithmetic operation uses the same symbol on both sides`

## Rationale

Comparing a variable or expression to itself (such as lv_status = lv_status) is either a tautology or permanently false, almost always signifying a copy-paste defect or missing field qualifier. Similarly, subtracting or dividing an operand by itself yields a constant value (0 or 1) while obscuring developer intent. Compiler symbol resolution validates both sides, ensuring accurate detection without false positives on shadowed identifiers.

### Non-Compliant

```abap
IF lv_order_status = lv_order_status.
  process_order( ).
ENDIF.
lv_net_amount = lv_gross_amount - lv_gross_amount.
```

### Compliant

```abap
IF lv_order_status = c_status_confirmed.
  process_order( ).
ENDIF.
lv_net_amount = lv_gross_amount - lv_discount_amount.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SELF_COMPARE

" SAP CI_ prefix format:
... "#EC CI_NO_SELF_COMPARE
```

### Checked operators and findings

The check examines expressions in `IF`, `ELSEIF`, `WHILE`, `CHECK`, and `COMPUTE` statements:

| Operator Category | Operators | Finding Code |
| --- | --- | --- |
| Comparison | `=`, `<>`, `<`, `>`, `<=`, `>=`, `EQ`, `NE`, `LT`, `GT`, `LE`, `GE` | `NO_SELFCMP` |
| Arithmetic | `-`, `/`, `DIV`, `MOD` | `NO_SELFOPR` |

Statements containing top-level logical chains (`AND`, `OR`, `BETWEEN`, `IS`) are bypassed to prevent duplicate findings with `no-dup-cond`.

### Suppression

In rare generated or macro-expanded routines where identical operand evaluations cannot be avoided, use `"#EC NO_SELF_COMPARE`.


## Related Rules

* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Duplicate Conditions in Branching Statements and Logical Operators](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Remove Redundant Self-Assignments and Identity Moves](/rules/no-redun-assign) — <code>#EC NO_IDENTICAL_MOVE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SELF_COMPARE`
* **ABAP Implementation:** [/skyl/cl_no_self_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_self_compare.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4238)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4238)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SELF_COMPARE&title=%5BBug%5D%3A%20Issue%20in%20no-self-compare)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-self-compare)**
