# Prefer Calculation Assignment Operators (+=, -=, *=)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC CALC_ASSIGN" />
</div>

## Overview

Prefer calculation assignment operators (+=, -=, *=, /=).

> **ATC Finding Message:** `Use calculation assignment operator (+=, -=) or ADD statement replacement`

## Rationale

Modern ABAP supports arithmetic assignment operators (`lv_count += 1.`), which are cleaner and more expressive than verbose legacy assignments (`lv_count = lv_count + 1.`).

### Non-Compliant

```abap
lv_count = lv_count + 1.
lv_total = lv_total * 2.
```

### Compliant

```abap
lv_count += 1.
lv_total *= 2.
```

## Transformation

```diff
- lv_count = lv_count + 1.
- lv_total = lv_total * 2.
+ lv_count += 1.
+ lv_total *= 2.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-calc-assign-op:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CALC_ASSIGN

" SAP CI_ prefix format:
... "#EC CI_CALC_ASSIGN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CALC_OP`
* **Implementation File:** [zcl_skylint_pref_calc_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_calc_op.clas.abap)
