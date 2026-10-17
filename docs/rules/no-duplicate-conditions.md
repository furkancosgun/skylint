# Avoid Duplicate Branch Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: DUPCOND" />
</div>

## Overview

Detect identical branch conditions in IF/ELSEIF and CASE/WHEN.

> **ATC Finding Message:** `Identical condition in branch; duplicate branch is unreachable`

## Rationale

Repeating the exact same condition across `IF / ELSEIF` or `WHEN` branches means subsequent duplicate branches can never be reached, indicating a copy-paste error or broken logic.

## Transformation

```diff
- IF lv_type = 'A' OR lv_type = 'A'.
-   process( ).
- ENDIF.
+ IF lv_type = 'A'.
+   process( ).
+ ENDIF.
```

### ✕ Non-Compliant

```abap
IF lv_type = 'A' OR lv_type = 'A'.
  process( ).
ENDIF.
```

### ✓ Compliant

```abap
IF lv_type = 'A'.
  process( ).
ENDIF.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-duplicate-conditions:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DUP_COND
" Or with SAP CI_ prefix:
... "#EC CI_DUP_COND

" Using pragma:
... ##DUP_COND.
" Or with SAP CI_ prefix:
... ##CI_DUP_COND.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_COND`
* **Finding Code:** `DUPCOND`
* **Implementation File:** [zcl_skylint_no_dup_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_cond.clas.abap)
