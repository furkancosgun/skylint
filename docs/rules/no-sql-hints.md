---
title: "Avoid Database Hints (%_HINTS) in ABAP SQL"
description: "Eliminate proprietary %_HINTS in ABAP SQL to ensure database portability and allow optimizer flexibility."
keywords: "ABAP %_HINTS, Database Hints SAP, HANA Migration, Vendor Agnostic SQL"
category: "performance"
ruleId: "no-sql-hints"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5562"
---

# Avoid Database Hints (%_HINTS) in ABAP SQL

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_SQL_HINTS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5562" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid database hints (%_HINTS) in ABAP SQL queries.

> **ATC Finding Message:** `Avoid %_HINTS; hints bypass query optimizer and break DB portability`

## Rationale

Hardcoding `%_HINTS` overrides the database optimizer and tightly couples ABAP code to a specific database vendor (e.g. HDB, Oracle, DB6). Hints break portability during database upgrades, HANA migrations, or ABAP Cloud downports.

**Standard:** Optimize queries through proper secondary indexes, CDS views, and index-backed WHERE conditions rather than vendor-specific hints.

### Non-Compliant

```abap
" Vendor-specific database hint
SELECT * FROM t000 INTO TABLE lt_data %_HINTS HDB 'INDEX_SEARCH'.
```

### Compliant

```abap
" Clean SQL without vendor hints
SELECT * FROM t000 INTO TABLE lt_data.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SQL_HINTS

" SAP CI_ prefix format:
... "#EC CI_NO_SQL_HINTS
```


## Related Rules

* [Avoid Unfiltered SELECT on Database Tables (Full Table Scan Prevention)](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SQL_HINTS`
* **ABAP Implementation:** [/skyl/cl_no_sql_hints.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_sql_hints.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5562)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5562)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SQL_HINTS&title=%5BBug%5D%3A%20Issue%20in%20no-sql-hints)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-sql-hints)**
