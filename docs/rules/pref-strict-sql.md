---
title: "Prefer Strict SQL Host Variable Escaping"
description: "Ensure ABAP SQL host variables are escaped with '@' for strict SQL mode."
keywords: "Clean ABAP, strict SQL, host variables, pref-strict-sql"
category: "clean-abap"
ruleId: "pref-strict-sql"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4799"
---

# Prefer Strict SQL Host Variable Escaping

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_STRICT_SQL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4799" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer strict SQL; escape host variables and targets with @.

> **ATC Finding Message:** `Use strict SQL syntax; escape host variables and targets with @`

## Rationale

Modern ABAP SQL requires host variables and structures to be escaped with the '@' character for strict mode compliance.

### Non-Compliant

```abap
SELECT * FROM ztable INTO TABLE lt_data.
```

### Compliant

```abap
SELECT * FROM ztable INTO TABLE @lt_data.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_STRICT_SQL

" SAP CI_ prefix format:
... "#EC CI_PREF_STRICT_SQL
```


## Related Rules

* [Avoid INTO with Field Symbols](/rules/no-into-fs) — <code>#EC NO_INTO_FS</code>
* [Avoid Ambiguous Statements](/rules/no-ambiguous-stmt) — <code>#EC NO_AMBIGUOUS_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_STRICT_SQL`
* **ABAP Implementation:** [/skyl/cl_pref_strict_sql.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_strict_sql.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4799)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4799)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_STRICT_SQL&title=%5BBug%5D%3A%20Issue%20in%20pref-strict-sql)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-strict-sql)**
