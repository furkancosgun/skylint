# Avoid Dangerous & Dynamic Native Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: DANGER_STM" />
</div>

## Overview

Dangerous Statements (abaplint dangerous_statement).

> **ATC Finding Message:** `Dangerous statement detected; avoid dynamic/unmanaged language construct`

## Rationale

Dynamic code generation (`GENERATE SUBROUTINE POOL`, `INSERT REPORT`), kernel calls (`SYSTEM-CALL`), and production `ASSERT` or `RAISE SHORTDUMP` jeopardize cloud compliance, security, and stability.

## Transformation

```diff
- EXEC SQL.
-   SELECT * FROM /dmo/customer INTO :wa
- ENDEXEC.
+ SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

### ✕ Non-Compliant

```abap
EXEC SQL.
  SELECT * FROM /dmo/customer INTO :wa
ENDEXEC.
```

### ✓ Compliant

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_EXEC_SQL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_KERNEL_CALL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_SYSTEM_CALL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_SYNTAX_CHECK` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_INSERT_REPORT` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_GENERATE_DYNPRO` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_GENERATE_REPORT` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_GENERATE_SUBROUTINE` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_DELETE_REPORT` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_DELETE_TEXTPOOL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_INSERT_TEXTPOOL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_DELETE_DYNPRO` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_EXPORT_DYNPRO` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_EDITOR_CALL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_DYNAMIC_SQL` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_RAISE_SHORTDUMP` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `CHECK_PROD_ASSERT` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |
| `IGNORE_RAP_QUERY_PROVIDER` | `Boolean` | `true` | Configurable attribute for no-dangerous-statements |

## CLI & CI/CD Configuration

```yaml
checks:
  no-dangerous-statements:
    enabled: true
    severity: warning
    attributes:
      CHECK_EXEC_SQL: true
      CHECK_KERNEL_CALL: true
      CHECK_SYSTEM_CALL: true
      CHECK_SYNTAX_CHECK: true
      CHECK_INSERT_REPORT: true
      CHECK_GENERATE_DYNPRO: true
      CHECK_GENERATE_REPORT: true
      CHECK_GENERATE_SUBROUTINE: true
      CHECK_DELETE_REPORT: true
      CHECK_DELETE_TEXTPOOL: true
      CHECK_INSERT_TEXTPOOL: true
      CHECK_DELETE_DYNPRO: true
      CHECK_EXPORT_DYNPRO: true
      CHECK_EDITOR_CALL: true
      CHECK_DYNAMIC_SQL: true
      CHECK_RAISE_SHORTDUMP: true
      CHECK_PROD_ASSERT: true
      IGNORE_RAP_QUERY_PROVIDER: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DANGEROUS_STMT
" Or with SAP CI_ prefix:
... "#EC CI_DANGEROUS_STMT

" Using pragma:
... ##DANGEROUS_STMT.
" Or with SAP CI_ prefix:
... ##CI_DANGEROUS_STMT.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DANGEROUS_STMT`
* **Finding Code:** `DANGER_STM`
* **Implementation File:** [zcl_skylint_no_dangerous_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dangerous_stmt.clas.abap)
