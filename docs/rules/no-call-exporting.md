---
description: "Omit Redundant EXPORTING in Method Calls"
---

# Omit Redundant EXPORTING in Method Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC EXPORTING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Omit Redundant EXPORTING in Method Calls.

> **ATC Finding Message:** `Omit explicit EXPORTING keyword in method invocation`

## Rationale

In functional ABAP method calls, the EXPORTING keyword is redundant when no other clauses (such as IMPORTING, CHANGING, or EXCEPTIONS) are present. Removing EXPORTING reduces syntax noise and simplifies signature reading.

### Non-Compliant

```abap
lo_pricing->apply_discount( EXPORTING iv_percent = 10 ).
```

### Compliant

```abap
lo_pricing->apply_discount( iv_percent = 10 ).
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
... "#EC EXPORTING

" SAP CI_ prefix format:
... "#EC CI_EXPORTING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CALL_EXPORTING`
* **Implementation File:** [zcl_skylint_no_call_exporting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_call_exporting.clas.abap)
