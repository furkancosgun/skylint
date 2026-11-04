---
title: "Restrict Database Modifications to Customer-Owned Tables"
description: "Prevent direct OpenSQL modifications on SAP standard tables to preserve database integrity and ensure SAP Clean Core compliance."
keywords: "no-mod-std-table, Clean Core SAP, Direct Table Modification, OpenSQL Security, ABAP Cloud Contract C1, SAP ATC"
category: "security"
ruleId: "no-mod-std-table"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3043"
---

# Restrict Database Modifications to Customer-Owned Tables

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_MOD_STD_TABLE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3043" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Modify Only Own Database Tables.

> **ATC Finding Message:** `Modify only customer-owned database tables (see OWN_TABLES)`

## Rationale

Directly executing OpenSQL INSERT, UPDATE, MODIFY, or DELETE statements against SAP standard database tables (such as BKPF, VBAK, EKKO, or BUT000) bypasses standard document numbering, SAP business locks, consistency checks, and change document auditing. Direct table mutation corrupts enterprise data integrity and breaks Cloud Contract C1 compatibility in S/4HANA and Clean Core architectures. In Clean ABAP and modern SAP extensibility, standard entities must only be modified through released transactional APIs, RAP Business Objects, or standard BAPIs, while direct OpenSQL writes are strictly restricted to customer-owned tables in custom namespaces.

### Non-Compliant

```abap
UPDATE bkpf
  SET bstat = 'V'
  WHERE belnr = @lv_doc_num.
```

### Compliant

```abap
UPDATE zfi_doc_status
  SET processing_status = 'V'
  WHERE document_number = @lv_doc_num.

IF sy-subrc <> 0.
  " Record not found or status already updated
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `OWN_TABLES` | `String` | <code>^[yz/]</code> | Regular expression matching customer-owned table names permitted for direct OpenSQL mutation (default: ^[yz/]). |
| `REPORT_DYNAMIC` | `Boolean` | <code>true</code> | Flag dynamic database targets specified via variable names enclosed in parentheses (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MOD_STD_TABLE

" SAP CI_ prefix format:
... "#EC CI_NO_MOD_STD_TABLE
```

## Table Namespace Enforcement

The check validates the target database table of OpenSQL `INSERT`, `UPDATE`, `MODIFY`, and `DELETE` statements against the customer namespace regex configured in `OWN_TABLES`:

| Statement Pattern | Condition Evaluated | Default Rule Behavior |
|---|---|---|
| `UPDATE <dbtab> SET ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |
| `DELETE FROM <dbtab> ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |
| `INSERT INTO <dbtab> ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |
| `MODIFY <dbtab> FROM ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |
| `(lv_dynamic_table)` | Target enclosed in parentheses | Flagged when `REPORT_DYNAMIC` is set to `abap_true` |

In-memory operations on internal tables (such as `MODIFY itab FROM wa INDEX idx`) do not constitute database access and are ignored. Suppress valid exceptions with `"#EC NO_MOD_STD_TABLE` or `##NO_MOD_STD_TABLE`.


## Related Rules

* [Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Do Not Mutate or Sort Tables Currently Being Looped](/rules/no-mod-loop-tab) — <code>#EC NO_MOD_LOOP_TAB</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MOD_STD_TABLE`
* **ABAP Implementation:** [/skyl/cl_no_mod_std_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_mod_std_table.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3043)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3043)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MOD_STD_TABLE&title=%5BBug%5D%3A%20Issue%20in%20no-mod-std-table)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-mod-std-table)**
