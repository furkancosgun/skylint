---
title: "Eliminate Obsolete Control Flow and Procedural Statements"
description: "Prevent obsolete control statements including FORM, BREAK-POINT, AT NEW, and macros in ABAP Cloud."
keywords: "no-obs-control, FORM PERFORM, BREAK-POINT, Clean ABAP, ABAP Cloud"
category: "anti-patterns"
ruleId: "no-obs-control"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1260"
---

# Eliminate Obsolete Control Flow and Procedural Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_OBS_CONTROL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1260" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete Control Flow and Procedural Statements.

> **ATC Finding Message:** `Avoid obsolete control flow (FORM, AT NEW, BREAK, DEFINE, etc.)`

## Rationale

Procedural control flow constructs—including subroutines (FORM / PERFORM), macro expansions (DEFINE), unconditioned BREAK-POINT, control breaks (AT NEW, AT END, ON CHANGE OF, SUM), and SET EXTENDED CHECK—violate modern lexical scoping and are prohibited in ABAP Cloud (Contract C1). Subroutines lack typed interfaces and leak global variables, while control break statements inside loops rely on brittle field positioning in work areas. Encapsulating logic in modular class methods and modern LOOP AT ... GROUP BY expressions creates robust, testable code.

### Non-Compliant

```abap
BREAK-POINT.
SET EXTENDED CHECK OFF.
```

### Compliant

```abap
calculate_subtotal( ).
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
| `CHECK_FORM` | `Boolean` | <code>true</code> | Report obsolete FORM definitions and PERFORM subroutine calls in favor of methods. |
| `CHECK_LOOP_CTL` | `Boolean` | <code>true</code> | Report legacy control break statements like AT NEW, AT END, ON CHANGE OF, and SUM. |
| `CHECK_BREAK` | `Boolean` | <code>true</code> | Report hardcoded BREAK-POINT and BREAK statements in non-test production source code. |
| `CHECK_DEFINE` | `Boolean` | <code>true</code> | Report DEFINE macro blocks; macros hide control flow and cannot be debugged cleanly. |
| `CHECK_TEST_SEAMS` | `Boolean` | <code>true</code> | Report TEST-SEAM and TEST-INJECT statements; use dependency injection and interfaces instead. |
| `CHECK_CATCH_SYSTEM` | `Boolean` | <code>true</code> | Report obsolete CATCH SYSTEM-EXCEPTIONS syntax in favor of TRY ... CATCH blocks. |
| `CHECK_SET_EXT_CHECK` | `Boolean` | <code>true</code> | Report obsolete SET EXTENDED CHECK statements that suppress code inspector checks. |
| `CHECK_SELECT_NO_INTO` | `Boolean` | <code>true</code> | Report obsolete SELECT statements without an INTO or APPENDING clause. |
| `CHECK_EXIT_SQL` | `Boolean` | <code>true</code> | Report obsolete EXIT FROM SQL statements that terminate open SQL loops. |
| `CHECK_SORT_BY_FS` | `Boolean` | <code>true</code> | Report obsolete dynamic SORT itab BY `<fs>` field symbol syntax. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_CONTROL

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_CONTROL
```

### Reported Obsolete Constructs

| Construct | Category | QuickFix |
|---|---|---|
| `BREAK-POINT` / `BREAK` | Unconditioned debugging stop | `RMBRK` (removes statement) |
| `SET EXTENDED CHECK` | Inspection suppression | `RMEXTCHK` (removes statement) |
| `FORM` / `PERFORM` | Procedural subroutines | None (refactor to methods) |
| `DEFINE` | Preprocessor macros | None (refactor to methods) |
| `AT NEW/END/FIRST/LAST` | Positional loop control breaks | None (use `GROUP BY`) |
| `ON CHANGE OF` / `SUM` | Legacy loop calculations | None |
| `TEST-SEAM` / `TEST-INJECT` | Legacy test seams | None (use test injection) |
| `CATCH SYSTEM-EXCEPTIONS` | Obsolete catch syntax | None (use `TRY..CATCH`) |
| `EXIT FROM SQL` | SQL loop termination | None |
| `SORT itab BY <fs>` | Obsolete dynamic sort | None |

Suppress findings with `"#EC NO_OBS_CONTROL`.


## Related Rules

* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Replace Obsolete Data Declarations with Explicit Types](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>
* [Prohibit Obsolete ABAP Memory and Cluster Statements](/rules/no-obs-memory) — <code>#EC NO_OBS_MEMORY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_CONTROL`
* **ABAP Implementation:** [/skyl/cl_no_obs_control.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_control.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1260)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1260)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_CONTROL&title=%5BBug%5D%3A%20Issue%20in%20no-obs-control)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-control)**
