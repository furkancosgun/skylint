---
title: "Close Opened Datasets and Database Cursors Explicitly"
description: "Prevent resource leaks in SAP ABAP by verifying that all OPEN DATASET and OPEN CURSOR statements are explicitly paired with CLOSE operations."
keywords: "no-unclosed-res, OPEN DATASET, OPEN CURSOR, DBSQL_TOO_MANY_OPEN_CURSOR, ABAP resource management"
category: "security"
ruleId: "no-unclosed-res"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1187"
---

# Close Opened Datasets and Database Cursors Explicitly

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_UNCLOSED_RES" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1187" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Ensure opened datasets and cursors are closed.

> **ATC Finding Messages:**
> - `OPEN DATASET is not closed; resource leak risk`
> - `OPEN CURSOR is not closed; database cursor leak risk`

## Rationale

Resources opened on the application server (OPEN DATASET) or database (OPEN CURSOR) must always be explicitly closed with CLOSE DATASET or CLOSE CURSOR before procedure completion. Leaving resources open causes operating system file descriptor leaks, persistent file locks, and risks triggering the fatal runtime error DBSQL_TOO_MANY_OPEN_CURSOR when reaching the SAP session limit of 17 open database cursors. In modern ABAP Cloud, legacy file and cursor operations are replaced with set-based ABAP SQL queries or released streaming APIs.

### Non-Compliant

```abap
OPEN CURSOR @DATA(lv_cursor) FOR
  SELECT partner, name_first, name_last
    FROM but000
    WHERE type = '1'.
FETCH NEXT CURSOR @lv_cursor INTO TABLE @DATA(lt_partners).
" Anti-pattern: Database cursor remains unclosed without CLOSE CURSOR!
```

### Compliant

```abap
SELECT partner, name_first, name_last
  FROM but000
  WHERE type = '1'
  INTO TABLE @DATA(lt_partners)
  UP TO 500 ROWS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DATASET` | `Boolean` | <code>true</code> | Report OPEN DATASET statements that lack a subsequent CLOSE DATASET statement in the same procedure. |
| `CHECK_CURSOR` | `Boolean` | <code>true</code> | Report OPEN CURSOR statements that lack a matching CLOSE CURSOR statement in the same procedure. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNCLOSED_RES

" SAP CI_ prefix format:
... "#EC CI_NO_UNCLOSED_RES
```

### Finding Codes

| Finding Code | Description |
|---|---|
| `NO_UNCL_DS` | Reports an `OPEN DATASET` statement without a subsequent `CLOSE DATASET` targeting the same file. |
| `NO_UNCL_CR` | Reports an `OPEN CURSOR` statement without a subsequent `CLOSE CURSOR` targeting the same cursor variable. |

### Configuration Attributes

- `CHECK_DATASET` (Boolean, default `abap_true`): Enables or disables detection of unclosed application server datasets.
- `CHECK_CURSOR` (Boolean, default `abap_true`): Enables or disables detection of unclosed database cursors.

Findings can be suppressed using the pseudo-comment `"#EC NO_UNCLOSED_RES`. In ABAP Cloud development, use set-based Open SQL with `UP TO n ROWS` or released file storage APIs instead of low-level cursor and dataset operations.


## Related Rules

* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Prohibit Obsolete ABAP Memory and Cluster Statements](/rules/no-obs-memory) — <code>#EC NO_OBS_MEMORY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNCLOSED_RES`
* **ABAP Implementation:** [/skyl/cl_no_unclosed_res.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unclosed_res.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1187)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1187)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNCLOSED_RES&title=%5BBug%5D%3A%20Issue%20in%20no-unclosed-res)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unclosed-res)**
