---
title: "Avoid Negated IF Conditions with ELSE"
description: "Avoid Negated IF Conditions with ELSE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-neg-cond, clean-abap"
---

# Avoid Negated IF Conditions with ELSE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_NEG_COND" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid negated IF conditions with ELSE.

> **ATC Finding Message:** `Invert the condition and swap the branches`

## Rationale

A negated condition with an ELSE branch forces readers to negate the expression mentally before understanding the main path. Invert the condition and swap the branches, so the positive case comes first. This rule ignores ELSEIF chains and IS NOT predicates handled by the dedicated rule.

### Non-Compliant

```abap
IF NOT lv_is_valid.
  handle_error( ).
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_valid.
  process( ).
ELSE.
  handle_error( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_NEG_COND

" SAP CI_ prefix format:
... "#EC CI_NO_NEG_COND
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_NEG_COND`
* **Implementation File:** [zcl_skylint_no_neg_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_neg_cond.clas.abap)
