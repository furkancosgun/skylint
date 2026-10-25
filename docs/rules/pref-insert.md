---
title: "Prefer INSERT ... INTO TABLE over APPEND"
description: "Prefer INSERT ... INTO TABLE over APPEND - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-insert, clean-abap"
category: "clean-abap"
ruleId: "pref-insert"
---

# Prefer INSERT ... INTO TABLE over APPEND

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_INSERT" />
  <Badge type="info" text="Remote Enabled" />
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

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INSERT`
* **Implementation File:** [zcl_skylint_pref_insert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_insert.clas.abap)
