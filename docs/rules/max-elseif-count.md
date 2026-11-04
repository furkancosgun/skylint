---
title: "Limit Number of ELSEIF Branches in IF Statements"
description: "Limit ELSEIF clauses in ABAP IF statements to avoid tangled decision cascades and encourage modern SWITCH or CASE structures."
keywords: "max-elseif-count, ELSEIF limit ABAP, Clean ABAP IF, SWITCH constructor ABAP, SAP ATC metrics"
category: "metrics"
ruleId: "max-elseif-count"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5524"
---

# Limit Number of ELSEIF Branches in IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_ELSEIF_COUNT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5524" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit number of ELSEIF clauses per IF.

> **ATC Finding Message:** `IF statement has too many ELSEIF clauses; consider CASE or polymorphism`

## Rationale

Long chains of ELSEIF statements create convoluted decision cascades where earlier conditions implicitly constrain later ones, forcing readers to reconstruct complex truth tables in their heads. When multiple conditions check the same variable for distinct values, Clean ABAP strongly recommends using CASE ... WHEN or SWITCH #( ) instead, which expresses discrete matching clearly and allows the ABAP compiler to optimize branch dispatch. When checking distinct business predicates, polymorphism, dispatch tables, or separating into guard clauses should be preferred to preserve ABAP Cloud testability.

### Non-Compliant

```abap
IF lv_region_code = 'NORTH'.
  apply_regional_rate( '1.05' ).
ELSEIF lv_region_code = 'SOUTH'.
  apply_regional_rate( '1.08' ).
ELSEIF lv_region_code = 'EAST'.
  apply_regional_rate( '1.06' ).
ELSEIF lv_region_code = 'WEST'.
  apply_regional_rate( '1.07' ).
ELSEIF lv_region_code = 'CENTRAL'.
  apply_regional_rate( '1.04' ).
ELSEIF lv_region_code = 'EXPORT'.
  apply_regional_rate( '1.00' ).
ELSE.
  apply_regional_rate( '1.02' ).
ENDIF.
```

### Compliant

```abap
DATA lv_rate_multiplier TYPE string.

lv_rate_multiplier = SWITCH #( lv_region_code
  WHEN 'NORTH'   THEN '1.05'
  WHEN 'SOUTH'   THEN '1.08'
  WHEN 'EAST'    THEN '1.06'
  WHEN 'WEST'    THEN '1.07'
  WHEN 'CENTRAL' THEN '1.04'
  WHEN 'EXPORT'  THEN '1.00'
  ELSE                '1.02' ).
apply_regional_rate( lv_rate_multiplier ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_ELSEIF_COUNT` | `Integer` | <code>5</code> | Maximum number of ELSEIF clauses allowed per IF control block before recommending CASE or SWITCH (default: 5). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_ELSEIF_COUNT

" SAP CI_ prefix format:
... "#EC CI_MAX_ELSEIF_COUNT
```

## Detection Rules

- **Clause Counting**: Counts each `ELSEIF` statement within an `IF ... ENDIF` block. The final `ELSE` branch is not counted as an `ELSEIF`.
- **Nesting Support**: Evaluated per block level via an internal statement stack; inner `IF` blocks have their own independent counters and do not affect outer blocks.
- **Reporting**: When `ENDIF` is reached and the count of `ELSEIF` statements exceeds `MAX_ELSEIF_COUNT` (default `5`), finding code `MAX_ELSEIF` is reported on the opening `IF` statement.

## Suppression

Suppress the check using the pseudo-comment `"#EC MAX_ELSEIF_COUNT` placed on the opening `IF` statement.


## Related Rules

* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Limit Number of WHEN Branches in CASE Blocks](/rules/max-when-count) — <code>#EC MAX_WHEN_COUNT</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_ELSEIF_COUNT`
* **ABAP Implementation:** [/skyl/cl_max_elseif_count.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_elseif_count.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5524)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5524)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_ELSEIF_COUNT&title=%5BBug%5D%3A%20Issue%20in%20max-elseif-count)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-elseif-count)**
