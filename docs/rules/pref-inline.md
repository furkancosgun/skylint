---
title: "Prefer Modern Inline Declarations in ABAP 7.40+"
description: "Prefer Modern Inline Declarations in ABAP 7.40+ - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-inline, clean-abap"
category: "clean-abap"
ruleId: "pref-inline"
---

# Prefer Modern Inline Declarations in ABAP 7.40+

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_INLINE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer Inline Declarations.

> **ATC Finding Message:** `Prefer inline declaration over separate DATA and assignment`

## Rationale

Declaring a variable at the top and assigning it in the very next statement separates the declaration from its first use. Inline DATA( ) keeps the variable close to where it is needed and shortens its lifetime in the reader mind. Use inline declarations when the type is obvious from the initial value.

### Non-Compliant

```abap
DATA lv_name TYPE string.
lv_name = |Order { lv_id }|.
```

### Compliant

```abap
DATA(lv_name) = |Order { lv_id }|.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_INLINE

" SAP CI_ prefix format:
... "#EC CI_PREF_INLINE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INLINE`
* **Implementation File:** [zcl_skylint_pref_inline.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_inline.clas.abap)
