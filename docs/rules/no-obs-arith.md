---
title: "Replace Obsolete Arithmetic Statements with Modern Operators"
description: "Replace obsolete arithmetic and assignment statements like ADD, MOVE, and COMPUTE with modern operators in ABAP Cloud."
keywords: "no-obs-arith, obsolete arithmetic, MOVE TO, REF operator, Clean ABAP"
category: "anti-patterns"
ruleId: "no-obs-arith"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1152"
---

# Replace Obsolete Arithmetic Statements with Modern Operators

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_OBS_ARITH" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1152" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete Arithmetic and Assignment Statements.

> **ATC Finding Message:** `Avoid obsolete arithmetic or assignment statements; use =, +, -, *, /`

## Rationale

Legacy arithmetic statements such as ADD, SUBTRACT, MULTIPLY, DIVIDE, and ADD-CORRESPONDING originate from early procedural ABAP and clutter code compared to standard mathematical expressions (=, +, -, *, /). Similarly, COMPUTE is redundant before assignment, MOVE ... TO is superseded by =, and GET REFERENCE OF ... INTO is replaced by REF #( ). In modern ABAP Cloud (Contract C1), these obsolete statements are deprecated or syntax errors, and replacing them with concise functional expressions significantly enhances code readability.

### Non-Compliant

```abap
ADD 1 TO lv_item_counter.
MOVE ls_order_item-gross_amount TO lv_total_amount.
GET REFERENCE OF lv_total_amount INTO lr_total_ref.
```

### Compliant

```abap
lv_item_counter = lv_item_counter + 1.
lv_total_amount = ls_order_item-gross_amount.
lr_total_ref = REF #( lv_total_amount ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_ADD` | `Boolean` | <code>true</code> | Detect obsolete ADD ... TO, SUBTRACT ... FROM, MULTIPLY ... BY, and DIVIDE ... BY statements. |
| `CHECK_ADD_CORR` | `Boolean` | <code>true</code> | Detect obsolete ADD-CORRESPONDING, SUBTRACT-CORRESPONDING, and related CORRESPONDING arithmetic. |
| `CHECK_COMPUTE` | `Boolean` | <code>true</code> | Detect redundant COMPUTE keywords preceding calculation assignments. |
| `CHECK_MOVE` | `Boolean` | <code>true</code> | Detect obsolete MOVE ... TO assignment statements in favor of the equal (=) operator. |
| `CHECK_GET_REF` | `Boolean` | <code>true</code> | Detect obsolete GET REFERENCE OF ... INTO statements in favor of modern REF #( ) expressions. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_ARITH

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_ARITH
```

### Modern Replacements

| Obsolete Statement | Modern Syntax | QuickFix Code |
|---|---|---|
| `ADD x TO y.` | `y = y + x.` | `REPLACE_AR` |
| `SUBTRACT x FROM y.` | `y = y - x.` | `REPLACE_AR` |
| `MULTIPLY y BY x.` | `y = y * x.` | `REPLACE_AR` |
| `DIVIDE y BY x.` | `y = y / x.` | `REPLACE_AR` |
| `COMPUTE y = x + 1.` | `y = x + 1.` | `REPLACE_AR` |
| `MOVE x TO y.` | `y = x.` | `REPLACE_AR` |
| `GET REFERENCE OF x INTO y.` | `y = REF #( x ).` | `REPLACE_AR` |

Suppress findings using `"#EC NO_OBS_ARITH`.


## Related Rules

* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Replace Obsolete Data Declarations with Explicit Types](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>
* [Prohibit Obsolete ABAP Memory and Cluster Statements](/rules/no-obs-memory) — <code>#EC NO_OBS_MEMORY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_ARITH`
* **ABAP Implementation:** [/skyl/cl_no_obs_arith.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_arith.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1152)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1152)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_ARITH&title=%5BBug%5D%3A%20Issue%20in%20no-obs-arith)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-arith)**
