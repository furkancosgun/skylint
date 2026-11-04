---
title: "Avoid Obsolete Control Flow and Procedural Forms"
description: "Avoid Obsolete Control Flow and Procedural Forms - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-obs-control, anti-patterns"
category: "anti-patterns"
ruleId: "no-obs-control"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1259"
---

# Avoid Obsolete Control Flow and Procedural Forms

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_OBS_CONTROL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1259" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete Control Flow and Procedural Statements.

> **ATC Finding Message:** `Avoid obsolete control flow (FORM, AT NEW, BREAK, DEFINE, etc.)`

## Rationale

Subroutines (FORM / PERFORM), macro definitions (DEFINE), hardcoded break points (BREAK-POINT / BREAK), control break statements (AT NEW, AT END, ON CHANGE OF, SUM), and SET EXTENDED CHECK belong to legacy procedural programming. They lack proper scope isolation, cause unpredictable side effects, and are completely prohibited in modern ABAP Cloud. Encapsulate all logic within methods, modern LOOP GROUP BY syntax, and unit tests.

### Non-Compliant

```abap
PERFORM calculate_total USING lv_subtotal.
AT NEW order_id.
  SUM.
ENDAT.
```

### Compliant

```abap
calculate_total( iv_subtotal = lv_subtotal ).
LOOP AT lt_orders INTO DATA(ls_order) GROUP BY ls_order-order_id ...
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
| `CHECK_FORM` | `Boolean` | <code>true</code> | Detect obsolete PERFORM / FORM subroutine routines |
| `CHECK_LOOP_CTL` | `Boolean` | <code>true</code> | Detect obsolete control break statements (ON CHANGE OF, EXIT FROM STEP-LOOP) |
| `CHECK_BREAK` | `Boolean` | <code>true</code> | Detect unconditioned BREAK-POINT statements in non-test code |
| `CHECK_DEFINE` | `Boolean` | <code>true</code> | Detect DEFINE macro declarations |
| `CHECK_TEST_SEAMS` | `Boolean` | <code>true</code> | Detect TEST-SEAM injection blocks in production logic |
| `CHECK_CATCH_SYSTEM` | `Boolean` | <code>true</code> | Detect obsolete CATCH SYSTEM-EXCEPTIONS syntax |
| `CHECK_SET_EXT_CHECK` | `Boolean` | <code>true</code> | Detect obsolete SET EXTENDED CHECK statements |
| `CHECK_SELECT_NO_INTO` | `Boolean` | <code>true</code> | Detect obsolete SELECT without INTO statements |
| `CHECK_EXIT_SQL` | `Boolean` | <code>true</code> | Detect obsolete EXIT FROM SQL statements |
| `CHECK_SORT_BY_FS` | `Boolean` | <code>true</code> | Detect obsolete dynamic SORT BY field symbol syntax |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_CONTROL

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_CONTROL
```


## Related Rules

* [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Avoid Obsolete Declarations and Table Headers](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>
* [Avoid Obsolete ABAP Memory and Context Statements](/rules/no-obs-memory) — <code>#EC NO_OBS_MEMORY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_CONTROL`
* **ABAP Implementation:** [/skyl/cl_no_obs_control.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_control.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1259)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1259)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_CONTROL&title=%5BBug%5D%3A%20Issue%20in%20no-obs-control)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-control)**
