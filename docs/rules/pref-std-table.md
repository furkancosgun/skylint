---
title: "Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF"
description: "Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-std-table, clean-abap"
category: "clean-abap"
ruleId: "pref-std-table"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3608"
---

# Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STD_TABLE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3608" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer explicit TYPE STANDARD TABLE OF over TYPE TABLE OF.

> **ATC Finding Message:** `Specify the table kind explicitly: TYPE STANDARD TABLE OF`

## Rationale

TYPE TABLE OF implicitly means a standard table, so the reader must know the default to understand access costs. Spelling out STANDARD makes the table kind and its linear search behavior explicit. It also keeps declarations consistent when tables are later changed to sorted or hashed.

### Non-Compliant

```abap
DATA lt_customers TYPE TABLE OF ty_customer.
```

### Compliant

```abap
DATA lt_customers TYPE STANDARD TABLE OF ty_customer.
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
... "#EC PREF_STD_TABLE

" SAP CI_ prefix format:
... "#EC CI_PREF_STD_TABLE
```


## Related Rules

* [Only Modify Tables Defined in Your Own Package/Component](/rules/no-mod-std-table) — <code>#EC NO_MOD_STD_TABLE</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) — <code>#EC PREF_LINES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_STD_TABLE`
* **ABAP Implementation:** [/skyl/cl_pref_std_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_std_table.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3608)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3608)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_STD_TABLE&title=%5BBug%5D%3A%20Issue%20in%20pref-std-table)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-std-table)**
