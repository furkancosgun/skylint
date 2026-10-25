---
title: "Prefer xsdbool( ) for Boolean Assignments"
description: "Prefer xsdbool( ) for Boolean Assignments - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-xsdbool, clean-abap"
---

# Prefer xsdbool( ) for Boolean Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_XSDBOOL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer xsdbool( ) expression over manual IF-ELSE assignment.

> **ATC Finding Message:** `Prefer xsdbool( ) over manual IF-ELSE assignment`

## Rationale

An IF/ELSE whose only task is to assign abap_true or abap_false uses many lines for a single boolean conversion. xsdbool( ) expresses the condition directly and assigns the result in one statement. This removes duplicated branches and makes the relationship between condition and flag obvious.

### Non-Compliant

```abap
IF lv_discount > 0.
  lv_has_discount = abap_true.
ELSE.
  lv_has_discount = abap_false.
ENDIF.
```

### Compliant

```abap
lv_has_discount = xsdbool( lv_discount > 0 ).
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
... "#EC PREF_XSDBOOL

" SAP CI_ prefix format:
... "#EC CI_PREF_XSDBOOL
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_XSDBOOL`
* **Implementation File:** [zcl_skylint_pref_xsdbool.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_xsdbool.clas.abap)
