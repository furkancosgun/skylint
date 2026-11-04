---
title: "Limit NPath Complexity per Method"
description: "Limit NPath execution path complexity in ABAP procedures to prevent combinatorial branch explosion and ensure thorough unit testability."
keywords: "NPath complexity ABAP, Checkstyle NPath, PMD NPath complexity, SAP ATC complexity check, acyclic execution paths"
category: "metrics"
ruleId: "max-npath"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2037"
---

# Limit NPath Complexity per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_NPATH" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2037" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit NPath complexity per procedure.

> **ATC Finding Message:** `Procedure NPath complexity exceeds threshold`

## Rationale

NPath complexity measures the total number of acyclic execution paths through a procedure. Unlike cyclomatic complexity which grows linearly with decision points, NPath complexity grows multiplicatively across sequential and nested control structures (IF, CASE, loops, compound boolean expressions). High NPath complexity makes exhaustive testing impossible. Keep NPath under the threshold by breaking large procedures into cohesive helper methods.

### Non-Compliant

```abap
METHOD process.
  IF cond_a = abap_true.
    ...
  ENDIF.
  IF cond_b = abap_true.
    ...
  ENDIF.
  IF cond_c = abap_true.
    ...
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD process.
  handle_condition_a( ).
  handle_condition_b( ).
  handle_condition_c( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_NPATH` | `Integer` | <code>200</code> | Maximum allowed NPath execution paths per procedure (default: 200) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_NPATH

" SAP CI_ prefix format:
... "#EC CI_MAX_NPATH
```


## Related Rules

* [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Cognitive Complexity per Method](/rules/max-cognitive) — <code>#EC MAX_COGNITIVE</code>
* [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_NPATH`
* **ABAP Implementation:** [/skyl/cl_max_npath.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_npath.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2037)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2037)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_NPATH&title=%5BBug%5D%3A%20Issue%20in%20max-npath)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-npath)**
