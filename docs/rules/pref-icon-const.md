---
title: "Prefer ICON_ Constants over Hardcoded Icon Codes"
description: "Prefer ICON_ constants over hardcoded @xx@ icon literals in ABAP to enhance readability and avoid magic strings."
keywords: "ABAP icon constants, type pool ICON, ABAP icon codes, Clean ABAP icon, SAP ATC check icon constants"
category: "clean-abap"
ruleId: "pref-icon-const"
---

# Prefer ICON_ Constants over Hardcoded Icon Codes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_ICON_CONST" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer ICON_ constants over hardcoded icon codes.

> **ATC Finding Message:** `Use icon_ constants instead of hardcoded icon codes`

## Rationale

SAP UI icons in dynpros, lists, and ALV grids are represented internally by 4-character codes enclosed in '@' symbols (such as '@01@'). Hardcoded string literals make code obscure and difficult to maintain. Clean ABAP requires using pre-defined system constants (such as icon_okay or icon_cancel from type pool ICON) instead of magic icon literals.

### Non-Compliant

```abap
lv_icon = '@01@'.
```

### Compliant

```abap
lv_icon = icon_okay.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ICON_CONST

" SAP CI_ prefix format:
... "#EC CI_PREF_ICON_CONST
```


## Related Rules

* [Avoid Magic Numbers; Use Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Avoid Repeating the Same String Literal](/rules/no-dup-literals) — <code>#EC NO_DUP_LITERALS</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_ICON_CONST`
* **Implementation File:** [zcl_skylint_pref_icon_const.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_icon_const.clas.abap)
