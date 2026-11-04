---
title: "Limit Number of WHEN Branches in CASE Statements"
description: "Limit the maximum number of WHEN clauses in ABAP CASE statements to maintain clean code and low cyclomatic complexity."
keywords: "ABAP CASE WHEN limit, Cyclomatic Complexity, Clean ABAP, Polymorphism"
category: "metrics"
ruleId: "max-when-count"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5313"
---

# Limit Number of WHEN Branches in CASE Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_WHEN_COUNT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5313" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit number of WHEN clauses per CASE.

> **ATC Finding Message:** `CASE statement has too many WHEN clauses; consider refactoring`

## Rationale

A CASE statement with an excessive number of WHEN branches violates the Single Responsibility Principle and often indicates missing polymorphism, dictionary tables, or strategy patterns. Complex CASE structures are prone to bugs during maintenance.

### Non-Compliant

```abap
CASE lv_status.
  WHEN 'A'. ...
  WHEN 'B'. ...
  " ... 10+ more branches
ENDCASE.
```

### Compliant

```abap
" Use a strategy pattern, lookup table, or dispatch method
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_WHEN_COUNT` | `Integer` | <code>10</code> | Maximum number of WHEN clauses allowed per CASE statement (default: 10) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_WHEN_COUNT

" SAP CI_ prefix format:
... "#EC CI_MAX_WHEN_COUNT
```


## Related Rules

* [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Number of ELSEIF Branches in IF Statements](/rules/max-elseif-count) — <code>#EC MAX_ELSEIF_COUNT</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_WHEN_COUNT`
* **ABAP Implementation:** [/skyl/cl_max_when_count.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_when_count.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5313)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5313)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_WHEN_COUNT&title=%5BBug%5D%3A%20Issue%20in%20max-when-count)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-when-count)**
