---
description: "Prefer RETURN over EXIT outside loop constructs"
---

# Prefer RETURN over EXIT in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC RETURN" />
</div>

## Overview

Prefer RETURN over EXIT outside loop constructs.

> **ATC Finding Message:** `Use RETURN instead of EXIT when leaving a procedure`

## Rationale

In method contexts, `EXIT` can be ambiguous when placed near loops. `RETURN` explicitly indicates an immediate exit from the current processing block or method.

### Non-Compliant

```abap
METHOD execute.
  IF is_invalid( ).
    EXIT.
  ENDIF.
  process( ).
ENDMETHOD.
```

### Compliant

```abap
METHOD execute.
  IF is_invalid( ).
    RETURN.
  ENDIF.
  process( ).
ENDMETHOD.
```

## Transformation

```diff
- METHOD execute.
-   IF is_invalid( ).
-     EXIT.
-   ENDIF.
-   process( ).
- ENDMETHOD.
+ METHOD execute.
+   IF is_invalid( ).
+     RETURN.
+   ENDIF.
+   process( ).
+ ENDMETHOD.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-return:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC RETURN

" SAP CI_ prefix format:
... "#EC CI_RETURN
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURN`
* **Implementation File:** [zcl_skylint_pref_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_return.clas.abap)
