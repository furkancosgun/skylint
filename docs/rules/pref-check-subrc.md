---
title: "Verify sy-subrc Promptly After Data Retrieval and Search"
description: "Enforce an immediate sy-subrc check after SELECT SINGLE, READ TABLE, FIND, SEARCH, ASSIGN and table MODIFY to stop silently ignored failures."
keywords: "pref-check-subrc, sy-subrc, SELECT SINGLE, READ TABLE, Clean ABAP"
category: "clean-abap"
ruleId: "pref-check-subrc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2450"
---

# Verify sy-subrc Promptly After Data Retrieval and Search

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CHECK_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2450" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Check sy-subrc after DB, table and string operations.

> **ATC Finding Message:** `Check sy-subrc after SELECT SINGLE, READ, INSERT, MODIFY, FIND, SEARCH`

## Rationale

Statements such as SELECT SINGLE, READ TABLE, FIND, SEARCH, dynamic ASSIGN and table MODIFY report success only through sy-subrc. If any other statement runs first, sy-subrc is overwritten and failures are silently ignored, which produces empty structures, unassigned field symbols or missing rows at runtime. The check demands that the immediately following statement evaluates sy-subrc, and its switches avoid the finding for operation kinds where the result is genuinely irrelevant.

### Non-Compliant

```abap
SELECT SINGLE customer_name FROM /dmo/customer
  WHERE customer_id = @lv_customer_id
  INTO @DATA(lv_customer_name).
process_customer( lv_customer_name ).
```

### Compliant

```abap
SELECT SINGLE customer_name FROM /dmo/customer
  WHERE customer_id = @lv_customer_id
  INTO @DATA(lv_customer_name).
IF sy-subrc <> 0.
  RAISE EXCEPTION NEW zcx_customer_not_found( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SELECT_SINGLE` | `Boolean` | <code>true</code> | Report SELECT SINGLE statements whose next statement does not evaluate sy-subrc. Keep enabled so empty results are never silently processed. |
| `CHECK_READ_TABLE` | `Boolean` | <code>true</code> | Report READ TABLE statements that are not followed by a sy-subrc evaluation, so a missing table line cannot go unnoticed. |
| `CHECK_FIND_SEARCH` | `Boolean` | <code>true</code> | Report FIND and SEARCH statements without an immediate sy-subrc check. Disable when the offset result is genuinely optional. |
| `CHECK_ASSIGN` | `Boolean` | <code>true</code> | Report dynamic ASSIGN statements without a sy-subrc check, which otherwise leave a field symbol unassigned and cause short dumps. |
| `CHECK_INSERT` | `Boolean` | <code>true</code> | Report database INSERT statements without a sy-subrc check. Disable for customizing writes that are validated elsewhere. |
| `CHECK_MODIFY` | `Boolean` | <code>true</code> | Report MODIFY statements on internal tables without a sy-subrc check, which reveals rows that were not found. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CHECK_SUBRC

" SAP CI_ prefix format:
... "#EC CI_PREF_CHECK_SUBRC
```

### Covered statements

| Statement | Attribute |
| --- | --- |
| `SELECT SINGLE` | `CHECK_SELECT_SINGLE` |
| `READ TABLE` | `CHECK_READ_TABLE` |
| `FIND`, `SEARCH` | `CHECK_FIND_SEARCH` |
| `ASSIGN` | `CHECK_ASSIGN` |
| database `INSERT` | `CHECK_INSERT` |
| internal-table `MODIFY` | `CHECK_MODIFY` |

`OPEN DATASET`, `UPDATE ... SET` and `DELETE FROM` are always inspected and have no switch. Only the directly following statement is examined, therefore a declaration or log statement between the operation and the `sy-subrc` test still produces `PREF_CHKSC` — that is intentional, because almost any statement updates `sy-subrc`. Use `"#EC PREF_CHECK_SUBRC` where the result is truly irrelevant.


## Related Rules

* [Check sy-subrc Immediately After AUTHORITY-CHECK](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>
* [Protect CALL TRANSACTION Statements with AUTHORITY-CHECK](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CHECK_SUBRC`
* **ABAP Implementation:** [/skyl/cl_pref_check_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_check_subrc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2450)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2450)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CHECK_SUBRC&title=%5BBug%5D%3A%20Issue%20in%20pref-check-subrc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-check-subrc)**
