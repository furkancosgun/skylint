---
title: "Enforce Cognitive Complexity Thresholds per Procedure"
description: "Measure and constrain cognitive complexity in ABAP methods to prevent deeply nested control flow and unreadable logic in SAP ATC."
keywords: "max-cognitive, cognitive complexity ABAP, nesting penalty, Sonar S3776 ABAP, Clean ABAP metrics"
category: "metrics"
ruleId: "max-cognitive"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4416"
---

# Enforce Cognitive Complexity Thresholds per Procedure

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_COGNITIVE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4416" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit cognitive complexity per procedure.

> **ATC Finding Message:** `Procedure cognitive complexity exceeds threshold`

## Rationale

Cognitive complexity measures the mental effort required for a human developer to understand and reason about control flow. Unlike classic cyclomatic complexity, which treats every decision branch identically, cognitive complexity heavily penalizes nesting: an IF or LOOP located three levels deep incurs an exponential mental penalty. High cognitive complexity in SAP S/4HANA core business methods leads directly to defect hotspots, regression risks, and unmaintainable legacy code. Refactoring deeply nested control structures into flat guard clauses and decomposed private methods preserves Clean Core agility.

### Non-Compliant

```abap
LOOP AT lt_invoices ASSIGNING FIELD-SYMBOL(<ls_invoice>).
  IF <ls_invoice>-is_posted = abap_false.
    IF <ls_invoice>-currency = 'EUR' AND <ls_invoice>-total_amount > 1000.
      LOOP AT <ls_invoice>-items ASSIGNING FIELD-SYMBOL(<ls_item>).
        IF <ls_item>-tax_rate > 0.
          apply_tax_adjustment( <ls_item> ).
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_invoices ASSIGNING FIELD-SYMBOL(<ls_invoice>).
  IF <ls_invoice>-is_posted = abap_true OR <ls_invoice>-currency <> 'EUR'.
    CONTINUE.
  ENDIF.

  process_single_invoice( <ls_invoice> ).
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_COGNITIVE` | `Integer` | <code>15</code> | Maximum allowable cognitive complexity score per procedure based on nesting penalties and logical operators (default: 15). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_COGNITIVE

" SAP CI_ prefix format:
... "#EC CI_MAX_COGNITIVE
```

## Scoring Rules

The cognitive complexity algorithm evaluates procedures using depth-weighted increments:

- **Nesting Increases**: Statements `IF`, `LOOP`, `DO`, `WHILE`, and `CASE` add `1 + current_depth` to the score and increase nesting depth by 1.
- **Branch Continuations**: Statements `ELSEIF`, `ELSE`, `WHEN`, and `CATCH` add `1 + current_depth` to the score without increasing depth.
- **Nesting Reductions**: Closing statements `ENDIF`, `ENDLOOP`, `ENDDO`, `ENDWHILE`, and `ENDCASE` decrease the nesting depth by 1.
- **Logical Operators**: Any statement with unparenthesized `AND` or `OR` (excluding `BETWEEN ... AND ...`) incurs an additional `+1` penalty.
- **Threshold**: When the accumulated score exceeds `MAX_COGNITIVE` (default `15`), finding `MAX_COGNIT` is reported on the opening procedure statement.

## Suppression

Suppress the rule with the pseudo-comment `"#EC MAX_COGNITIVE` placed on the `METHOD` statement.


## Related Rules

* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_COGNITIVE`
* **ABAP Implementation:** [/skyl/cl_max_cognitive.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_cognitive.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4416)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4416)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_COGNITIVE&title=%5BBug%5D%3A%20Issue%20in%20max-cognitive)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-cognitive)**
