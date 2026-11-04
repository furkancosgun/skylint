---
title: "Avoid Ambiguous Statements"
description: "Avoid ambiguous MODIFY/DELETE statements between internal and database tables."
keywords: "Clean ABAP, ambiguous statement, no-ambiguous-stmt"
category: "clean-abap"
ruleId: "no-ambiguous-stmt"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4599"
---

# Avoid Ambiguous Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_AMBIGUOUS_STMT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4599" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid ambiguous statements between itab and database.

> **ATC Finding Message:** `Ambiguous statement; use explicit syntax (TABLE keyword or @ for SQL variables)`

## Rationale

ABAP allows ambiguous syntax for MODIFY and DELETE between internal tables and database tables. Use TABLE keyword or @ host escape to clarify intent.

### Non-Compliant

```abap
MODIFY lt_data FROM ls_row.
```

### Compliant

```abap
MODIFY TABLE lt_data FROM ls_row.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_AMBIGUOUS_STMT

" SAP CI_ prefix format:
... "#EC CI_NO_AMBIGUOUS_STMT
```


## Related Rules

* [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>
* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_AMBIGUOUS_STMT`
* **ABAP Implementation:** [/skyl/cl_no_ambiguous_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ambiguous_stmt.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4599)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4599)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_AMBIGUOUS_STMT&title=%5BBug%5D%3A%20Issue%20in%20no-ambiguous-stmt)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ambiguous-stmt)**
