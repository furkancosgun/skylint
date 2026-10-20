# Avoid Classic List Processing Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: LIST_PROC" />
</div>

## Overview

Prohibit classic list processing statements.

> **ATC Finding Message:** `List processing statement is forbidden in OO/Cloud ABAP`

## Rationale

Statements such as `WRITE`, `ULINE`, `SKIP`, `NEW-LINE`, `FORMAT`, `POSITION`, `RESERVE`, `READ LINE`, `MODIFY LINE`, and `SCROLL LIST` are classic list-processing constructs forbidden in OO/Cloud ABAP. Use application logging and modern UI frameworks instead.

### Non-Compliant

```abap
WRITE: / 'Order processed:'.
ULINE.
```

### Compliant

```abap
mo_logger->info( 'Order processed:' ).
```

## Transformation

```diff
- WRITE: / 'Order processed:'.
- ULINE.
+ mo_logger->info( 'Order processed:' ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_WRITE` | `Boolean` | `true` | Configurable attribute for no-list-processing |
| `CHECK_ULINE` | `Boolean` | `true` | Configurable attribute for no-list-processing |
| `CHECK_SKIP` | `Boolean` | `true` | Configurable attribute for no-list-processing |
| `CHECK_OTHER` | `Boolean` | `true` | Configurable attribute for no-list-processing |
| `IGN_WRITE_TO` | `Boolean` | `true` | Configurable attribute for no-list-processing |
| `CHECK_LEAVE` | `Boolean` | `true` | Configurable attribute for no-list-processing |
| `CHECK_REJECT` | `Boolean` | `true` | Configurable attribute for no-list-processing |

## CLI & CI/CD Configuration

```yaml
checks:
  no-list-processing:
    enabled: true
    severity: warning
    attributes:
      checkWrite: true
      checkUline: true
      checkSkip: true
      checkOther: true
      ignWriteTo: true
      checkLeave: true
      checkReject: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC LIST_PROC

" SAP CI_ prefix format:
... "#EC CI_LIST_PROC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LIST_PROC`
* **Finding Code:** `LIST_PROC`
* **Implementation File:** [zcl_skylint_no_list_proc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_list_proc.clas.abap)
