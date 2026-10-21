---
description: "Prefer INSERT ... INTO TABLE over APPEND for table safety"
---

# Prefer INSERT ... INTO TABLE over APPEND

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="#EC INSERT_INTO" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer INSERT ... INTO TABLE over APPEND for table safety.

> **ATC Finding Message:** `Prefer INSERT ... INTO TABLE over APPEND`

## Rationale

`APPEND` implies indexed, sequential appending and fails on hashed or sorted tables. `INSERT ... INTO TABLE` works polymorphically across all internal table categories.

### Non-Compliant

```abap
APPEND ls_item TO lt_items.
```

### Compliant

```abap
INSERT ls_item INTO TABLE lt_items.
```

## Transformation

```diff
- APPEND ls_item TO lt_items.
+ INSERT ls_item INTO TABLE lt_items.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-insert-into:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC INSERT_INTO

" SAP CI_ prefix format:
... "#EC CI_INSERT_INTO
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INSERT`
* **Implementation File:** [zcl_skylint_pref_insert.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_insert.clas.abap)
