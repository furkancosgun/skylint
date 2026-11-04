---
title: "Prefer INSERT ... INTO TABLE over APPEND"
description: "Prefer INSERT ... INTO TABLE over APPEND - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-insert, clean-abap"
category: "clean-abap"
ruleId: "pref-insert"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2128"
---

# Prefer INSERT ... INTO TABLE over APPEND

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_INSERT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2128" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer INSERT ... INTO TABLE over APPEND for table safety.

> **ATC Finding Message:** `Prefer INSERT ... INTO TABLE over APPEND`

## Rationale

APPEND only works for index tables and implies sequential insertion, so changing the table type to sorted or hashed later breaks the code. INSERT ... INTO TABLE works with every table category and states the intent generically. Use INSERT for table handling that should remain independent of the concrete table kind.

### Non-Compliant

```abap
APPEND ls_order_item TO lt_order_items.
```

### Compliant

```abap
INSERT ls_order_item INTO TABLE lt_order_items.
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
... "#EC PREF_INSERT

" SAP CI_ prefix format:
... "#EC CI_PREF_INSERT
```


## Related Rules

* [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) — <code>#EC PREF_LINES</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>
* [Specify TRANSPORTING in Internal Table MODIFY and READ Operations](/rules/pref-transport) — <code>#EC PREF_TRANSPORT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_INSERT`
* **ABAP Implementation:** [/skyl/cl_pref_insert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_insert.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2128)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2128)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_INSERT&title=%5BBug%5D%3A%20Issue%20in%20pref-insert)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-insert)**
