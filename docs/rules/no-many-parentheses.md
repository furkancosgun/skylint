---
description: "Remove redundant parentheses"
---

# Remove redundant parentheses

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC MANY_PARENS" />
</div>

## Overview

Remove redundant parentheses.

> **ATC Finding Message:** `Parentheses wrap a complete expression and can be removed`

## Rationale

Parentheses that only wrap a complete condition or expression add noise and can be removed without changing semantics.

### Non-Compliant

```abap
IF ( destination IS INITIAL ).
ENDIF.
```

### Compliant

```abap
IF destination IS INITIAL.
ENDIF.
```

## Transformation

```diff
- IF ( destination IS INITIAL ).
- ENDIF.
+ IF destination IS INITIAL.
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
  no-many-parentheses:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MANY_PARENS

" SAP CI_ prefix format:
... "#EC CI_MANY_PARENS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MANY_PARENS`
* **Implementation File:** [zcl_skylint_no_many_parens.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_many_parens.clas.abap)
