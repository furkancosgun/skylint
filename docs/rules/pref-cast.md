---
description: "Prefer modern CAST #( ) expression over ?="
---

# Prefer CAST #( ) over ?=

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CAST" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer modern CAST #( ) expression over ?=.

> **ATC Finding Message:** `Prefer CAST #( ) constructor expression over ?= downcast`

## Rationale

The ?= downcast operator is legacy syntax and cannot be nested inside expressions. CAST #( ) returns a typed reference and can be used directly in call chains or constructor expressions. Use CAST for downcasts and let # infer the target type.

### Non-Compliant

```abap
lo_invoice ?= lo_document.
```

### Compliant

```abap
lo_invoice = CAST #( lo_document ).
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
... "#EC PREF_CAST

" SAP CI_ prefix format:
... "#EC CI_PREF_CAST
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CAST`
* **Implementation File:** [zcl_skylint_pref_cast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_cast.clas.abap)
