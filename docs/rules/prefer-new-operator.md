# Prefer NEW #( ) over CREATE OBJECT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PREFERNEW" />
</div>

## Overview

Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION.

> **ATC Finding Message:** `Prefer NEW #( ) expression over CREATE OBJECT`

## Rationale

The constructor expression `NEW #( )` is type-inferred, expression-capable, and avoids the archaic procedural `CREATE OBJECT` statement.

### Non-Compliant

```abap
DATA lo_customer TYPE REF TO cl_customer.
CREATE OBJECT lo_customer.
```

### Compliant

```abap
DATA lo_customer TYPE REF TO cl_customer.
lo_customer = NEW #( ).
```

## Transformation

```diff
- DATA lo_customer TYPE REF TO cl_customer.
- CREATE OBJECT lo_customer.
+ DATA lo_customer TYPE REF TO cl_customer.
+ lo_customer = NEW #( ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_CREATE_OBJECT` | `Boolean` | `true` | Configurable attribute for prefer-new-operator |
| `CHECK_RAISE_EXCEPTION` | `Boolean` | `true` | Configurable attribute for prefer-new-operator |

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-new-operator:
    enabled: true
    severity: warning
    attributes:
      checkCreateObject: true
      checkRaiseException: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NEW_OP

" SAP CI_ prefix format:
... "#EC CI_NEW_OP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NEW_OP`
* **Finding Code:** `PREFERNEW`
* **Implementation File:** [zcl_skylint_pref_new_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_new_op.clas.abap)
