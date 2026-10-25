---
title: "Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF"
description: "Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-std-table, clean-abap"
category: "clean-abap"
ruleId: "pref-std-table"
---

# Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STD_TABLE" />
  <Badge type="info" text="Remote Enabled" />
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

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STD_TABLE`
* **Implementation File:** [zcl_skylint_pref_std_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_std_table.clas.abap)
