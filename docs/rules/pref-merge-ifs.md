---
title: "Merge Redundant Nested IF Blocks"
description: "Flatten nested IF blocks with boolean AND and convert an IF inside ELSE into ELSEIF to reduce cyclomatic complexity."
keywords: "pref-merge-ifs, nested IF, ELSEIF, cyclomatic complexity, Clean ABAP"
category: "clean-abap"
ruleId: "pref-merge-ifs"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L892"
---

# Merge Redundant Nested IF Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_MERGE_IFS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L892" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Merge consecutive nested IF blocks using boolean AND.

> **ATC Finding Messages:**
> - `Nested IF block can be merged with outer IF using AND`
> - `Nested IF in ELSE block can be changed to ELSEIF`

## Rationale

A nested IF that immediately follows the outer IF and closes right before the outer ENDIF adds indentation without adding a decision: the two conditions can be combined with AND. An IF that is the only statement of an ELSE block is the same story, where ELSEIF expresses the alternative in one line. The check reports PREF_MRGIF and PREF_ELSIF and offers the USE_ELSEIF quickfix that rewrites ELSE plus IF into ELSEIF and removes the inner ENDIF, lowering nesting and cyclomatic complexity.

### Non-Compliant

```abap
IF lv_is_active = abap_true.
  IF lv_is_authorized = abap_true.
    release_sales_order( lv_order_id ).
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF lv_is_active = abap_true AND lv_is_authorized = abap_true.
  release_sales_order( lv_order_id ).
ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_MERGE_IFS

" SAP CI_ prefix format:
... "#EC CI_PREF_MERGE_IFS
```

## Finding Codes

| Finding code | Pattern | Fix |
|---|---|---|
| `PREF_MRGIF` | The inner IF is the first statement of the outer IF and closes immediately before the outer ENDIF | Combine both conditions with `AND` |
| `PREF_ELSIF` | The outer ELSE block contains exactly one IF that closes immediately before the outer ENDIF | Change `ELSE` + `IF` to `ELSEIF` (quickfix `USE_ELSEIF`) |

Blocks where the inner IF has its own `ELSE` or `ELSEIF`, or where further statements follow it, are not reported because merging would change semantics.


## Related Rules

* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_MERGE_IFS`
* **ABAP Implementation:** [/skyl/cl_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_merge_ifs.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 892)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L892)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_MERGE_IFS&title=%5BBug%5D%3A%20Issue%20in%20pref-merge-ifs)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-merge-ifs)**
