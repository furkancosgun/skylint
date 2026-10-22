---
description: "Avoid Using ABAP Keywords as Identifier Names"
---

# Avoid Using ABAP Keywords as Identifier Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC KEYWORD_NAME" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Using ABAP Keywords as Identifier Names.

> **ATC Finding Message:** `Identifier name matches an ABAP keyword`

## Rationale

Naming variables, parameters, constants, or types after ABAP keywords (such as class, type, data, method) leads to confusion, shadows language constructs, and impairs code readability.

### Non-Compliant

```abap
DATA class TYPE string.
DATA type TYPE i.
```

### Compliant

```abap
DATA lv_class TYPE string.
DATA lv_type TYPE i.
```

## Transformation

```diff
- DATA class TYPE string.
- DATA type TYPE i.
+ DATA lv_class TYPE string.
+ DATA lv_type TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC KEYWORD_NAME

" SAP CI_ prefix format:
... "#EC CI_KEYWORD_NAME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_KEYWORD_NAME`
* **Implementation File:** [zcl_skylint_keyword_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_keyword_name.clas.abap)
