# Avoid Dead / Unreachable Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: UNREACHCD" />
</div>

## Overview

Detect unreachable code following unconditional jump statements.

> **ATC Finding Message:** `Statement is unreachable`

## Rationale

Statements appearing immediately after an unconditional `RETURN`, `RAISE EXCEPTION`, `EXIT`, or `LEAVE PROGRAM` can never execute, cluttering the codebase and misleading maintainers.

## Transformation

```diff
- RETURN.
- lv_count = lv_count + 1. " Unreachable statement
+ lv_count = lv_count + 1.
+ RETURN.
```

### ✕ Non-Compliant

```abap
RETURN.
lv_count = lv_count + 1. " Unreachable statement
```

### ✓ Compliant

```abap
lv_count = lv_count + 1.
RETURN.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-unreachable-code:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC UNREACHABLE
" Or with SAP CI_ prefix:
... "#EC CI_UNREACHABLE

" Using pragma:
... ##UNREACHABLE.
" Or with SAP CI_ prefix:
... ##CI_UNREACHABLE.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNREACHABLE`
* **Finding Code:** `UNREACHCD`
* **Implementation File:** [zcl_skylint_no_unreachable.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unreachable.clas.abap)
