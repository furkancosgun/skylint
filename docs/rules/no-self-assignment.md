# Avoid Redundant Self-Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: IDENTMOVE" />
</div>

## Overview

Detect Identical Self Assignments.

> **ATC Finding Message:** `Identical assignment has no effect; remove redundant statement`

## Rationale

Assigning a variable or structure field to itself (`lv_x = lv_x`) is a redundant no-op and frequently hides a typo where another source field was intended.

### Non-Compliant

```abap
lv_name = lv_name.
```

### Compliant

```abap
lv_name = iv_new_name.
```

## Transformation

```diff
- lv_name = lv_name.
+ lv_name = iv_new_name.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-self-assignment:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SELF_ASSIGN

" SAP CI_ prefix format:
... "#EC CI_SELF_ASSIGN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELF_ASSIGN`
* **Finding Code:** `IDENTMOVE`
* **Implementation File:** [zcl_skylint_no_self_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_self_assign.clas.abap)
