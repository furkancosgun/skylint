---
title: "Avoid Duplicate Branch Conditions"
description: "Avoid Duplicate Branch Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-dup-cond, anti-patterns"
---

# Avoid Duplicate Branch Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DUP_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid duplicate branch conditions in IF and CASE.

> **ATC Finding Messages:**
> - `Identical condition in branch; duplicate branch is unreachable`
> - `Identical operand in condition; remove the duplicate comparison`

## Rationale

A repeated IF/ELSEIF or WHEN condition can never be reached because the earlier branch already handles it. This is usually a copy-paste error and can leave the intended branch permanently dead. Remove the duplicate or correct the condition so every branch has a distinct purpose.

### Non-Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ELSEIF lv_status = 'A'.
  process_b( ).
ENDIF.
```

### Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ELSEIF lv_status = 'B'.
  process_b( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_COND

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_COND
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_COND`
* **Implementation File:** [zcl_skylint_no_dup_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_cond.clas.abap)
