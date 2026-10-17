# Avoid Magic Numbers; Use Named Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: MAGIC_NUM" />
</div>

## Overview

Avoid magic numbers in code; use named constants.

> **ATC Finding Message:** `Avoid hardcoded magic numbers; declare a named constant`

## Rationale

Hardcoded numeric literals scattered in logic obscure business rules and make updates error-prone. Give numbers meaningful names by declaring structured constants.

## Transformation

```diff
- IF lv_status = 3.
-   process( ).
- ENDIF.
+ CONSTANTS c_status_completed TYPE i VALUE 3.
+ IF lv_status = c_status_completed.
+   process( ).
+ ENDIF.
```

### ✕ Non-Compliant

```abap
IF lv_status = 3.
  process( ).
ENDIF.
```

### ✓ Compliant

```abap
CONSTANTS c_status_completed TYPE i VALUE 3.
IF lv_status = c_status_completed.
  process( ).
ENDIF.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-magic-numbers:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MAGIC_NUMBERS
" Or with SAP CI_ prefix:
... "#EC CI_MAGIC_NUMBERS

" Using pragma:
... ##MAGIC_NUMBERS.
" Or with SAP CI_ prefix:
... ##CI_MAGIC_NUMBERS.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MAGIC_NUMBERS`
* **Finding Code:** `MAGIC_NUM`
* **Implementation File:** [zcl_skylint_no_magic_numbers.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_magic_numbers.clas.abap)
