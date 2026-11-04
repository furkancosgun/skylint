---
title: "Replace Obsolete Data Declarations with Explicit Types"
description: "Eliminate obsolete ABAP declarations including TABLES, RANGES, and WITH HEADER LINE for ABAP Cloud."
keywords: "no-obs-decl, WITH HEADER LINE, TABLES declaration, RANGES, Clean ABAP"
category: "anti-patterns"
ruleId: "no-obs-decl"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1218"
---

# Replace Obsolete Data Declarations with Explicit Types

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_OBS_DECL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1218" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Obsolete Data and Type Declarations.

> **ATC Finding Message:** `Avoid obsolete declaration constructs (TABLES, RANGES, TYPE-POOLS, etc.)`

## Rationale

Legacy declaration constructs such as TABLES, RANGES, TYPE-POOLS, and internal tables defined WITH HEADER LINE, OCCURS, or INITIAL SIZE introduce implicit global state, obsolete paging mechanisms, and ambiguous identifier semantics. Modern ABAP Cloud and Clean ABAP strictly require explicit type definitions, standard RANGE OF types, explicit table keys (WITH EMPTY KEY or WITH UNIQUE KEY), and CLEAR instead of REFRESH. Eliminating these obsolete declarations guarantees compatibility with S/4HANA Cloud and clean object-oriented scopes.

### Non-Compliant

```abap
DATA lt_sales_items TYPE STANDARD TABLE OF string WITH HEADER LINE.
REFRESH lt_sales_items.
```

### Compliant

```abap
DATA lt_sales_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
CLEAR lt_sales_items.
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
| `CHECK_TABLES` | `Boolean` | <code>true</code> | Detect obsolete TABLES declarations that define global table work areas. |
| `CHECK_TYPE_POOLS` | `Boolean` | <code>true</code> | Detect obsolete TYPE-POOLS statements; type pools are loaded automatically in modern ABAP. |
| `CHECK_RANGES` | `Boolean` | <code>true</code> | Detect obsolete RANGES declarations in favor of modern RANGE OF types. |
| `CHECK_HEADER_LINE` | `Boolean` | <code>true</code> | Detect internal tables defined with obsolete header lines (WITH HEADER LINE). |
| `CHECK_OCCURS` | `Boolean` | <code>true</code> | Detect legacy OCCURS additions in internal table declarations. |
| `CHECK_INITIAL_SIZE` | `Boolean` | <code>true</code> | Detect obsolete INITIAL SIZE additions on internal table declarations. |
| `CHECK_COMMON_PART` | `Boolean` | <code>true</code> | Detect obsolete DATA COMMON PART statements that share memory across programs. |
| `CHECK_STATICS` | `Boolean` | <code>true</code> | Detect STATICS declarations in methods; persist state in object attributes instead. |
| `CHECK_FS_STRUCTURE` | `Boolean` | <code>true</code> | Detect obsolete FIELD-SYMBOLS declarations typed with the STRUCTURE addition. |
| `CHECK_LOAD` | `Boolean` | <code>true</code> | Detect obsolete CLASS ... LOAD or INTERFACE ... LOAD statements. |
| `CHECK_PARAMETER` | `Boolean` | <code>true</code> | Detect obsolete PARAMETER keyword (singular) in selection screens; use PARAMETERS. |
| `CHECK_REFRESH` | `Boolean` | <code>true</code> | Detect obsolete REFRESH statements on internal tables in favor of CLEAR. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_OBS_DECL

" SAP CI_ prefix format:
... "#EC CI_NO_OBS_DECL
```

### Supported Replacements and QuickFixes

| Legacy Declaration | Modern Replacement | QuickFix |
|---|---|---|
| `REFRESH itab.` | `CLEAR itab.` | `REPLACE_DC` |
| `PARAMETER p_param.` | `PARAMETERS p_param.` | `REPLACE_DC` |
| `TABLES dbtab.` | Explicit work area `DATA ls_row TYPE dbtab.` | None |
| `RANGES lr_range FOR field.` | `DATA lr_range TYPE RANGE OF field.` | None |
| `... WITH HEADER LINE` | Separate table and work area declarations | None |
| `... OCCURS n` / `INITIAL SIZE n` | Modern internal table declaration | None |
| `TYPE-POOLS pool.` | Remove statement; type pools are automatic | None |

Suppress findings with `"#EC NO_OBS_DECL`.


## Related Rules

* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Prohibit Obsolete ABAP Memory and Cluster Statements](/rules/no-obs-memory) — <code>#EC NO_OBS_MEMORY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_OBS_DECL`
* **ABAP Implementation:** [/skyl/cl_no_obs_decl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_obs_decl.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1218)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1218)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_OBS_DECL&title=%5BBug%5D%3A%20Issue%20in%20no-obs-decl)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-obs-decl)**
