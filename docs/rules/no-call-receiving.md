---
title: "Omit RECEIVING in Method Invocations"
description: "Omit RECEIVING in Method Invocations - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-call-receiving, anti-patterns"
---

# Omit RECEIVING in Method Invocations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CALL_RECEIVING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Omit RECEIVING in Method Invocations.

> **ATC Finding Message:** `Omit RECEIVING keyword; use functional call or omit parameter`

## Rationale

The RECEIVING clause in a method call is legacy syntax that forces a functional call into a statement format. In modern ABAP, capture the return value directly on the left-hand side of an assignment (e.g. result = obj->meth( )) to enable clean nesting and expression-oriented programming.

### Non-Compliant

```abap
lo_order->calculate_total( RECEIVING rv_total = lv_total ).
```

### Compliant

```abap
lv_total = lo_order->calculate_total( ).
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
... "#EC NO_CALL_RECEIVING

" SAP CI_ prefix format:
... "#EC CI_NO_CALL_RECEIVING
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CALL_RECEIVING`
* **Implementation File:** [zcl_skylint_no_call_receiving.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_call_receiving.clas.abap)
