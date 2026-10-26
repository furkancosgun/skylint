---
title: "Limit Cognitive Complexity per Method"
description: "Control cognitive complexity in ABAP methods with nesting-aware scoring so deeply nested branches do not become unreadable."
keywords: "cognitive complexity ABAP, Sonar S3776 ABAP, method readability metric, SAP ATC complexity check, nested IF penalty ABAP"
category: "metrics"
ruleId: "max-cognitive"
---

# Limit Cognitive Complexity per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_COGNITIVE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit cognitive complexity per procedure.

> **ATC Finding Message:** `Procedure cognitive complexity exceeds threshold`

## Rationale

Cognitive complexity measures how hard a procedure is to understand: every branch adds one point plus the current nesting depth, so deeply nested IFs and loops escalate quickly even when the raw branch count looks acceptable. Unlike cyclomatic complexity it rewards flat guard clauses and early exits. Keep procedures below the configured threshold and extract nested logic into well-named helper methods.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  IF ls_item-active = abap_true.
    IF ls_item-amount > 0.
      IF ls_item-currency = lv_currency.
        process( ls_item ).
      ENDIF.
    ENDIF.
  ENDIF.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
  IF is_relevant( <ls_item> ) = abap_false.
    CONTINUE.
  ENDIF.
  process( <ls_item> ).
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_COGNITIVE` | `Integer` | <code>15</code> | Maximum allowed cognitive complexity score per procedure (default: 15) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_COGNITIVE

" SAP CI_ prefix format:
... "#EC CI_MAX_COGNITIVE
```


## Related Rules

* [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_COGNITIVE`
* **Implementation File:** [zcl_skylint_max_cognitive.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cognitive.clas.abap)
