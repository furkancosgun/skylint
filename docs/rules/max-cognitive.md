---
title: "Limit Cognitive Complexity per Method"
description: "Control cognitive complexity in ABAP methods with nesting-aware scoring so deeply nested branches do not become unreadable."
keywords: "cognitive complexity ABAP, Sonar S3776 ABAP, method readability metric, SAP ATC complexity check, nested IF penalty ABAP"
category: "metrics"
ruleId: "max-cognitive"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4312"
---

# Limit Cognitive Complexity per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_COGNITIVE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4312" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

* **Native ATC Class:** `/SKYL/CL_MAX_COGNITIVE`
* **ABAP Implementation:** [/skyl/cl_max_cognitive.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_cognitive.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4312)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4312)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_COGNITIVE&title=%5BBug%5D%3A%20Issue%20in%20max-cognitive)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-cognitive)**
