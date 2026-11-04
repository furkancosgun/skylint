---
title: "Prefer READ TABLE WITH KEY over WHERE"
description: "Prefer READ TABLE WITH KEY over WHERE in ABAP for faster single line internal table access with key optimization. ABAP performance rules and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "READ TABLE WITH KEY, ABAP Single Line Access, Internal Table Performance, ABAP Cheat Sheet, ATC Code Review"
category: "performance"
ruleId: "pref-read-key"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5233"
---

# Prefer READ TABLE WITH KEY over WHERE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC PREF_READ_KEY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5233" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

READ With WITH KEY Instead of WHERE.

> **ATC Finding Message:** `READ TABLE WHERE - use WITH KEY so the access benefits from key optimization`

## Rationale

READ TABLE ... WITH KEY is the documented single-line access form and allows the runtime to exploit table keys and sorted access for a direct hit. The WHERE variant of READ TABLE forces a row-by-row scan of the internal table. The rule only reports WHERE clauses that WITH KEY can express: pure equality comparisons ( = / EQ ) combined with AND. Conditions with other operators ( CS, GT, OR, IS, ... ) cannot be converted and are not flagged. Clean ABAP cheat sheet (Single Line Access) recommends WITH KEY for one-line lookups.

### Non-Compliant

```abap
READ TABLE lt_data INTO ls_data WHERE field1 = 'X'.
```

### Compliant

```abap
READ TABLE lt_data INTO ls_data WITH KEY field1 = 'X'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_READ_KEY

" SAP CI_ prefix format:
... "#EC CI_PREF_READ_KEY
```


## Related Rules

* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Prefer LOOP AT WHERE over IF CONTINUE Guards](/rules/pref-loop-where) — <code>#EC PREF_LOOP_WHERE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_READ_KEY`
* **ABAP Implementation:** [/skyl/cl_pref_read_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_read_key.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5233)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5233)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_READ_KEY&title=%5BBug%5D%3A%20Issue%20in%20pref-read-key)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-read-key)**
