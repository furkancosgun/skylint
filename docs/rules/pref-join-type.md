---
title: "Prefer an Explicit JOIN Type"
description: "Prefer an Explicit JOIN Type - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-join-type, clean-abap"
category: "clean-abap"
ruleId: "pref-join-type"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3580"
---

# Prefer an Explicit JOIN Type

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_JOIN_TYPE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3580" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer an explicit JOIN type such as INNER JOIN.

> **ATC Finding Message:** `Specify the JOIN type explicitly, for example INNER JOIN`

## Rationale

A bare JOIN defaults to INNER JOIN, but the default is invisible at the call site and easy to misread as an outer join. Explicit join types document cardinality and make reviews safer. Always write INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, or CROSS JOIN.

### Non-Compliant

```abap
SELECT mara~matnr, makt~maktx
  FROM mara JOIN makt ON mara~matnr = makt~matnr
  INTO TABLE @lt_result.
```

### Compliant

```abap
SELECT mara~matnr, makt~maktx
  FROM mara INNER JOIN makt ON mara~matnr = makt~matnr
  INTO TABLE @lt_result.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_JOIN_TYPE

" SAP CI_ prefix format:
... "#EC CI_PREF_JOIN_TYPE
```


## Related Rules

* [Require Explicit ORDER BY for Deterministic SELECT Queries](/rules/pref-order-by) — <code>#EC PREF_ORDER_BY</code>
* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_JOIN_TYPE`
* **ABAP Implementation:** [/skyl/cl_pref_join_type.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_join_type.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3580)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3580)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_JOIN_TYPE&title=%5BBug%5D%3A%20Issue%20in%20pref-join-type)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-join-type)**
