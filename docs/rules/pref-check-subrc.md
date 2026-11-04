---
title: "Verify sy-subrc Promptly After Data Retrieval and Search"
description: "Verify sy-subrc Promptly After Data Retrieval and Search - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-check-subrc, clean-abap"
category: "clean-abap"
ruleId: "pref-check-subrc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2404"
---

# Verify sy-subrc Promptly After Data Retrieval and Search

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CHECK_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2404" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Check sy-subrc after DB, table and string operations.

> **ATC Finding Message:** `Check sy-subrc after SELECT SINGLE, READ, INSERT, MODIFY, FIND, SEARCH`

## Rationale

Statements such as SELECT SINGLE, READ TABLE, FIND, and SEARCH report success through sy-subrc. If intervening statements execute before inspection, sy-subrc is overwritten and failure states are silently ignored. Check sy-subrc immediately after execution.

### Non-Compliant

```abap
SELECT SINGLE customer_id FROM /dmo/customer
  WHERE customer_id = @lv_id
  INTO @lv_customer_id.
process_customer( lv_customer_id ).
```

### Compliant

```abap
SELECT SINGLE customer_id FROM /dmo/customer
  WHERE customer_id = @lv_id
  INTO @lv_customer_id.
IF sy-subrc = 0.
  process_customer( lv_customer_id ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SELECT_SINGLE` | `Boolean` | <code>true</code> | Require sy-subrc check after SELECT SINGLE |
| `CHECK_READ_TABLE` | `Boolean` | <code>true</code> | Require sy-subrc check after READ TABLE |
| `CHECK_FIND_SEARCH` | `Boolean` | <code>true</code> | Require sy-subrc check after FIND or SEARCH |
| `CHECK_ASSIGN` | `Boolean` | <code>true</code> | Require sy-subrc check after dynamic ASSIGN |
| `CHECK_INSERT` | `Boolean` | <code>true</code> | Require sy-subrc check after database INSERT |
| `CHECK_MODIFY` | `Boolean` | <code>true</code> | Require sy-subrc check after database MODIFY |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CHECK_SUBRC

" SAP CI_ prefix format:
... "#EC CI_PREF_CHECK_SUBRC
```


## Related Rules

* [Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)](/rules/pref-auth-subrc) — <code>#EC PREF_AUTH_SUBRC</code>
* [Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations](/rules/pref-auth-check) — <code>#EC PREF_AUTH_CHECK</code>
* [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CHECK_SUBRC`
* **ABAP Implementation:** [/skyl/cl_pref_check_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_check_subrc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2404)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2404)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CHECK_SUBRC&title=%5BBug%5D%3A%20Issue%20in%20pref-check-subrc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-check-subrc)**
