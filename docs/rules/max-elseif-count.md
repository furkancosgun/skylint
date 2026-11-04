---
title: "Limit Number of ELSEIF Branches in IF Statements"
description: "Limit the number of ELSEIF clauses in ABAP IF statements to avoid excessive branch complexity."
keywords: "ABAP ELSEIF limit, Branch Complexity, Clean ABAP, Refactor IF to CASE"
category: "metrics"
ruleId: "max-elseif-count"
---

# Limit Number of ELSEIF Branches in IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_ELSEIF_COUNT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit number of ELSEIF clauses per IF.

> **ATC Finding Message:** `IF statement has too many ELSEIF clauses; consider CASE or polymorphism`

## Rationale

Deep chains of ELSEIF statements are difficult to read and test. Consider replacing long ELSEIF cascades with a CASE statement, polymorphism, or separate dispatch methods.

### Non-Compliant

```abap
IF lv_code = 1. ...
ELSEIF lv_code = 2. ...
ELSEIF lv_code = 3. ...
" ... 6+ branches
ENDIF.
```

### Compliant

```abap
CASE lv_code.
  WHEN 1. ...
  WHEN 2. ...
ENDCASE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_ELSEIF_COUNT` | `Integer` | <code>5</code> | Maximum number of ELSEIF clauses allowed per IF statement (default: 5) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_ELSEIF_COUNT

" SAP CI_ prefix format:
... "#EC CI_MAX_ELSEIF_COUNT
```


## Related Rules

* [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Number of WHEN Branches in CASE Statements](/rules/max-when-count) — <code>#EC MAX_WHEN_COUNT</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_ELSEIF_COUNT`
* **Implementation File:** [#skyl#cl_max_elseif_count.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_elseif_count.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_ELSEIF_COUNT&title=%5BBug%5D%3A%20Issue%20in%20max-elseif-count)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-elseif-count)**
