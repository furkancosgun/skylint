---
description: "Dangerous Statements (abaplint dangerous_statement)"
---

# Avoid Dangerous & Dynamic Native Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC DANGEROUS_STMT" />
</div>

## Overview

Dangerous Statements (abaplint dangerous_statement).

> **ATC Finding Messages:**
> - `Dangerous statement detected; avoid dynamic/unmanaged language construct`
> - `Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions`
> - `Avoid native ASSERT in production logic; raise an exception instead`

## Rationale

Dynamic code generation (`GENERATE SUBROUTINE POOL`, `INSERT REPORT`), kernel calls (`SYSTEM-CALL`), and production `ASSERT` or `RAISE SHORTDUMP` jeopardize cloud compliance, security, and stability.

### Non-Compliant

```abap
EXEC SQL.
  SELECT * FROM /dmo/customer INTO :wa
ENDEXEC.
```

### Compliant

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## Transformation

```diff
- EXEC SQL.
-   SELECT * FROM /dmo/customer INTO :wa
- ENDEXEC.
+ SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_EXEC_SQL` | `Boolean` | <code>true</code> |
| `CHECK_KERNEL_CALL` | `Boolean` | <code>true</code> |
| `CHECK_SYSTEM_CALL` | `Boolean` | <code>true</code> |
| `CHECK_SYNTAX_CHECK` | `Boolean` | <code>true</code> |
| `CHECK_INSERT_REPORT` | `Boolean` | <code>true</code> |
| `CHECK_GENERATE_DYNPRO` | `Boolean` | <code>true</code> |
| `CHECK_GENERATE_REPORT` | `Boolean` | <code>true</code> |
| `CHECK_GENERATE_SUBROUTINE` | `Boolean` | <code>true</code> |
| `CHECK_DELETE_REPORT` | `Boolean` | <code>true</code> |
| `CHECK_DELETE_TEXTPOOL` | `Boolean` | <code>true</code> |
| `CHECK_INSERT_TEXTPOOL` | `Boolean` | <code>true</code> |
| `CHECK_DELETE_DYNPRO` | `Boolean` | <code>true</code> |
| `CHECK_EXPORT_DYNPRO` | `Boolean` | <code>true</code> |
| `CHECK_EDITOR_CALL` | `Boolean` | <code>true</code> |
| `CHECK_DYNAMIC_SQL` | `Boolean` | <code>true</code> |
| `CHECK_RAISE_SHORTDUMP` | `Boolean` | <code>true</code> |
| `CHECK_PROD_ASSERT` | `Boolean` | <code>true</code> |
| `IGNORE_RAP_QUERY_PROVIDER` | `Boolean` | <code>true</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  no-dangerous-statements:
    enabled: true
    severity: warning
    attributes:
      checkExecSql: true
      checkKernelCall: true
      checkSystemCall: true
      checkSyntaxCheck: true
      checkInsertReport: true
      checkGenerateDynpro: true
      checkGenerateReport: true
      checkGenerateSubroutine: true
      checkDeleteReport: true
      checkDeleteTextpool: true
      checkInsertTextpool: true
      checkDeleteDynpro: true
      checkExportDynpro: true
      checkEditorCall: true
      checkDynamicSql: true
      checkRaiseShortdump: true
      checkProdAssert: true
      ignoreRapQueryProvider: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DANGEROUS_STMT

" SAP CI_ prefix format:
... "#EC CI_DANGEROUS_STMT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DANGEROUS_STMT`
* **Implementation File:** [zcl_skylint_no_dangerous_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dangerous_stmt.clas.abap)
