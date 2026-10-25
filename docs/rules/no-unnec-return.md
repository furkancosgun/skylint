---
title: "Omit Unnecessary RETURN Statement"
description: "Omit Unnecessary RETURN Statement - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-unnec-return, anti-patterns"
---

# Omit Unnecessary RETURN Statement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNNEC_RETURN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Omit unnecessary RETURN at end of routine.

> **ATC Finding Message:** `Omit optional RETURN at end of routine; routines return automatically`

## Rationale

A RETURN as the final statement of a method, form, or function changes nothing because the routine ends at ENDMETHOD, ENDFORM, or ENDFUNCTION anyway. It adds a line that implies a special exit and can obscure the real control flow. Remove trailing RETURN statements and keep early returns only where they are meaningful.

### Non-Compliant

```abap
METHOD get_total.
  rv_total = lv_subtotal + lv_tax.
  RETURN.
ENDMETHOD.
```

### Compliant

```abap
METHOD get_total.
  rv_total = lv_subtotal + lv_tax.
ENDMETHOD.
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
... "#EC NO_UNNEC_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_UNNEC_RETURN
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNNEC_RETURN`
* **Implementation File:** [zcl_skylint_no_unnec_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unnec_return.clas.abap)
