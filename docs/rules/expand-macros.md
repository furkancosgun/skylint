---
description: "Expand Macro Calls"
---

# Expand Macro Calls into Explicit Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC EXPAND_MACROS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Expand Macro Calls.

> **ATC Finding Message:** `Macro call should be expanded into explicit statements`

## Rationale

Macros defined via DEFINE ... END-OF-DEFINITION are obsolete, difficult to debug, and unsupported in ABAP Cloud. Macro invocations should be expanded into explicit statements.

### Non-Compliant

```abap
DEFINE _set_val.
  lv_val = &1.
END-OF-DEFINITION.
_set_val 10.
```

### Compliant

```abap
lv_val = 10.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC EXPAND_MACROS

" SAP CI_ prefix format:
... "#EC CI_EXPAND_MACROS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EXPAND_MACRO`
* **Implementation File:** [zcl_skylint_pref_expand_macro.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_expand_macro.clas.abap)
