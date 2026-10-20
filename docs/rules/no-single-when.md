---
description: "Avoid CASE statements with only one WHEN branch"
---

# Avoid CASE with a Single WHEN Branch

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC SINGLE_WHEN" />
</div>

## Overview

Avoid CASE statements with only one WHEN branch.

> **ATC Finding Message:** `CASE statement has <= 1 WHEN branch; prefer IF`

## Rationale

A `CASE` statement containing only one `WHEN` branch is unnecessarily verbose. An `IF ... ENDIF` is more concise and idiomatic.

### Non-Compliant

```abap
CASE lv_status.
  WHEN 'A'.
    process_a( ).
ENDCASE.
```

### Compliant

```abap
IF lv_status = 'A'.
  process_a( ).
ENDIF.
```

## Transformation

```diff
- CASE lv_status.
-   WHEN 'A'.
-     process_a( ).
- ENDCASE.
+ IF lv_status = 'A'.
+   process_a( ).
+ ENDIF.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-single-when:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SINGLE_WHEN

" SAP CI_ prefix format:
... "#EC CI_SINGLE_WHEN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SINGLE_WHEN`
* **Implementation File:** [zcl_skylint_no_single_when.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_single_when.clas.abap)
