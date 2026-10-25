---
title: "Avoid WITH DEFAULT KEY"
description: "Avoid WITH DEFAULT KEY - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-default-key, anti-patterns"
category: "anti-patterns"
ruleId: "no-default-key"
---

# Avoid WITH DEFAULT KEY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DEFAULT_KEY" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys.

> **ATC Finding Message:** `Avoid WITH DEFAULT KEY; specify EMPTY KEY or explicit key`

## Rationale

WITH DEFAULT KEY makes every non-numeric field part of the implicit table key, so which rows count as duplicates depends on the structure definition. Adding a field later silently changes the key and can introduce unexpected duplicates or sort behavior. Use WITH EMPTY KEY for standard tables that are accessed by index, or declare an explicit key for sorted and hashed tables.

### Non-Compliant

```abap
DATA lt_open_orders TYPE STANDARD TABLE OF ty_open_order WITH DEFAULT KEY.
```

### Compliant

```abap
DATA lt_open_orders TYPE STANDARD TABLE OF ty_open_order WITH EMPTY KEY.
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
... "#EC NO_DEFAULT_KEY

" SAP CI_ prefix format:
... "#EC CI_NO_DEFAULT_KEY
```


## Related Rules

* [Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>
* [Only Modify Tables Defined in Your Own Package/Component](/rules/no-mod-std-table) — <code>#EC NO_MOD_STD_TABLE</code>
* [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) — <code>#EC PREF_LINES</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DEFAULT_KEY`
* **Implementation File:** [zcl_skylint_no_default_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_default_key.clas.abap)
