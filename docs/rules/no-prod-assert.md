---
description: "Native ASSERT in Production Logic"
---

# Avoid Native ASSERT in Production Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC PROD_ASSERT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Native ASSERT in Production Logic.

> **ATC Finding Message:** `Avoid native ASSERT in production logic; raise an exception instead`

## Rationale

Native ASSERT statements terminate execution immediately with a runtime error when their condition evaluates to false. In production environments, unhandled assertion failures cause system short dumps, corrupting end-user sessions and transaction consistency. Always use structured class-based exceptions (CX_*) or logging mechanisms to handle unexpected conditions gracefully.

### Non-Compliant

```abap
ASSERT lv_amount > 0.
```

### Compliant

```abap
IF lv_amount <= 0.
  RAISE EXCEPTION TYPE cx_invalid_amount.
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PROD_ASSERT

" SAP CI_ prefix format:
... "#EC CI_PROD_ASSERT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PROD_ASSERT`
* **Implementation File:** [zcl_skylint_no_prod_assert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_prod_assert.clas.abap)
