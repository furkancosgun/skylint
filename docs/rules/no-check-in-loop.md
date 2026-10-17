# Avoid CHECK in Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: CHKINLOOP" />
</div>

## Overview

Avoid CHECK in loops; prefer IF with CONTINUE.

> **ATC Finding Message:** `Avoid CHECK inside loop; use IF ... CONTINUE instead`

## Rationale

`CHECK` inside a loop behaves like a `CONTINUE`, but `CHECK` outside a loop exits the entire procedure like `RETURN`. This dual behavior leads to subtle bugs during refactoring. Use `IF ... CONTINUE` inside loops.

## Transformation

```diff
- LOOP AT lt_items INTO ls_item.
-   CHECK ls_item-status = 'ACTIVE'.
-   process( ls_item ).
- ENDLOOP.
+ LOOP AT lt_items INTO ls_item.
+   IF ls_item-status <> 'ACTIVE'.
+     CONTINUE.
+   ENDIF.
+   process( ls_item ).
+ ENDLOOP.
```

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  CHECK ls_item-status = 'ACTIVE'.
  process( ls_item ).
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items INTO ls_item.
  IF ls_item-status <> 'ACTIVE'.
    CONTINUE.
  ENDIF.
  process( ls_item ).
ENDLOOP.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-check-in-loop:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CHECK_IN_LOOP

" SAP CI_ prefix format:
... "#EC CI_CHECK_IN_LOOP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHECK_IN_LOOP`
* **Finding Code:** `CHKINLOOP`
* **Implementation File:** [zcl_skylint_no_check_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_check_in_loop.clas.abap)
