---
description: "Avoid magic numbers in code; use named constants"
---

# Avoid Magic Numbers; Use Named Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC MAGIC_NUMBERS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid magic numbers in code; use named constants.

> **ATC Finding Message:** `Avoid hardcoded magic numbers; declare a named constant`

## Rationale

A numeric literal in logic does not explain what it represents, and the same value repeated in several places must be changed consistently. Named constants turn business rules into readable intent and give the value a single source of truth. Declare typed constants and reuse them instead of scattering numbers through the code.

### Non-Compliant

```abap
IF lv_retry_count >= 3.
  process( ).
ENDIF.
```

### Compliant

```abap
CONSTANTS c_max_retries TYPE i VALUE 3.
IF lv_retry_count >= c_max_retries.
  process( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAGIC_NUMBERS

" SAP CI_ prefix format:
... "#EC CI_MAGIC_NUMBERS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MAGIC_NUMBERS`
* **Implementation File:** [zcl_skylint_no_magic_numbers.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_magic_numbers.clas.abap)
