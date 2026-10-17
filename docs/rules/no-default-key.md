# Avoid WITH DEFAULT KEY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: DEFAULTKEY" />
</div>

## Overview

Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys.

> **ATC Finding Message:** `Avoid WITH DEFAULT KEY; specify EMPTY KEY or explicit key`

## Rationale

`WITH DEFAULT KEY` is dangerous and unpredictable because it includes all non-numeric fields as table keys, causing unexpected sorting and duplicate record bugs. Always prefer `WITH EMPTY KEY` or explicitly specified table keys.

## Transformation

```diff
- DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH DEFAULT KEY.
+ DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH EMPTY KEY.
```

### ✕ Non-Compliant

```abap
DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH DEFAULT KEY.
```

### ✓ Compliant

```abap
DATA lt_customers TYPE STANDARD TABLE OF ty_customer WITH EMPTY KEY.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  no-default-key:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DEFAULT_KEY
" Or with SAP CI_ prefix:
... "#EC CI_DEFAULT_KEY

" Using pragma:
... ##DEFAULT_KEY.
" Or with SAP CI_ prefix:
... ##CI_DEFAULT_KEY.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DEFAULT_KEY`
* **Finding Code:** `DEFAULTKEY`
* **Implementation File:** [zcl_skylint_no_default_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_default_key.clas.abap)
