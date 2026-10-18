# Prefer CAST #( ) over ?=

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PREFCAST" />
</div>

## Overview

Prefer modern CAST #( ) expression over ?=.

> **ATC Finding Message:** `Prefer CAST #( ) constructor expression over ?= downcast`

## Rationale

`?=` is legacy downcast syntax from early ABAP Objects. Modern ABAP exclusively uses `CAST #( )` constructor expressions, which can be inlined directly into method call chains and expressions.

### Non-Compliant

```abap
lo_child ?= lo_parent.
```

### Compliant

```abap
lo_child = CAST #( lo_parent ).
```

## Transformation

```diff
- lo_child ?= lo_parent.
+ lo_child = CAST #( lo_parent ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-cast:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CAST

" SAP CI_ prefix format:
... "#EC CI_PREF_CAST
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CAST`
* **Finding Code:** `PREFCAST`
* **Implementation File:** [zcl_skylint_pref_cast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_cast.clas.abap)
