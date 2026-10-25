---
title: "Prefer IS SUPPLIED over IS REQUESTED"
description: "Prefer IS SUPPLIED over IS REQUESTED - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-is-supplied, clean-abap"
---

# Prefer IS SUPPLIED over IS REQUESTED

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_SUPPLIED" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer IS SUPPLIED over the obsolete IS REQUESTED.

> **ATC Finding Message:** `Use IS SUPPLIED instead of IS REQUESTED`

## Rationale

IS REQUESTED is obsolete and only reports whether an output parameter was requested by the caller, not whether an input was actually supplied. IS SUPPLIED works for every parameter direction and states the real condition. Replace IS REQUESTED with IS SUPPLIED.

### Non-Compliant

```abap
IF iv_currency IS REQUESTED.
  convert_amount( iv_currency ).
ENDIF.
```

### Compliant

```abap
IF iv_currency IS SUPPLIED.
  convert_amount( iv_currency ).
ENDIF.
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
... "#EC PREF_IS_SUPPLIED

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_SUPPLIED
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_SUPPLIED`
* **Implementation File:** [zcl_skylint_pref_is_supplied.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_supplied.clas.abap)
