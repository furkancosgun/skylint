# Avoid Obsolete CALL METHOD

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: CALLMETHOD" />
</div>

## Overview

Avoid static CALL METHOD statements.

> **ATC Finding Message:** `Avoid static CALL METHOD; use functional method call instead`

## Rationale

Procedural `CALL METHOD` is legacy syntax from early ABAP Objects. Modern ABAP exclusively uses functional call syntax (`ref->method( )` or `class=>method( )`), which reduces visual clutter and enables functional expression chaining.

### Non-Compliant

```abap
CALL METHOD lo_service->calculate_tax(
  EXPORTING
    iv_amount = lv_amount ).
```

### Compliant

```abap
lo_service->calculate_tax( iv_amount = lv_amount ).
```

## Transformation

```diff
- CALL METHOD lo_service->calculate_tax(
-   EXPORTING
-     iv_amount = lv_amount ).
+ lo_service->calculate_tax( iv_amount = lv_amount ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-call-method:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CALL_METH

" SAP CI_ prefix format:
... "#EC CI_CALL_METH
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CALL_METHOD`
* **Finding Code:** `CALLMETHOD`
* **Implementation File:** [zcl_skylint_no_call_method.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_call_method.clas.abap)
