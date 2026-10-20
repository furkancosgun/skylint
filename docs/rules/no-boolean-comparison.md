# Avoid Comparing to abap_true / abap_false

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC BOOL_COMPARE" />
</div>

## Overview

Avoid comparing boolean method calls to boolean literals.

> **ATC Finding Message:** `Avoid boolean comparison for method calls; call method directly`

## Rationale

Predicate methods and boolean expressions evaluate directly to true or false. Comparing them explicitly (`IF is_valid( ) = abap_true`) is redundant, noisy, and unidiomatic.

### Non-Compliant

```abap
IF is_valid( ) = abap_true.
  execute( ).
ENDIF.
```

### Compliant

```abap
IF is_valid( ).
  execute( ).
ENDIF.
```

## Transformation

```diff
- IF is_valid( ) = abap_true.
-   execute( ).
- ENDIF.
+ IF is_valid( ).
+   execute( ).
+ ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-boolean-comparison:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC BOOL_COMPARE

" SAP CI_ prefix format:
... "#EC CI_BOOL_COMPARE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_BOOL_COMPARE`
* **Implementation File:** [zcl_skylint_no_bool_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_bool_compare.clas.abap)
