---
description: "Disallow ignoring the return value of functional methods"
---

# Do Not Ignore Return Value of Functional Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IGNORED_RET" />
</div>

## Overview

Disallow ignoring the return value of functional methods.

> **ATC Finding Message:** `Do not ignore return value of functional method; assign or use result`

## Rationale

Functional methods that declare a `RETURNING` parameter are designed to compute and return a value. Calling such methods without assigning or consuming their result indicates a bug, dead code, or an improper command-query violation where side effects were bundled into a query.

### Non-Compliant

```abap
lo_calc->get_total( ).
```

### Compliant

```abap
lv_total = lo_calc->get_total( ).
```

## Transformation

```diff
- lo_calc->get_total( ).
+ lv_total = lo_calc->get_total( ).
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-ignored-return-value:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IGNORED_RET

" SAP CI_ prefix format:
... "#EC CI_NO_IGNORED_RET
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_IGNORED_RETURN`
* **Implementation File:** [zcl_skylint_no_ignored_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_ignored_return.clas.abap)
