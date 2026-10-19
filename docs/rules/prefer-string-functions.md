# Prefer Built-in String Functions over SEARCH/SHIFT

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: CONDENSE_S" />
</div>

## Overview

Detect obsolete string statements; prefer built-in functions.

> **ATC Finding Message:** `Use modern built-in string function condense( ... ) instead`

## Rationale

Procedural string statements (`SEARCH`, `SHIFT`, `TRANSLATE`) are legacy ABAP. Replace them with functional built-in string functions (`find`, `to_upper`, `substring`, `shift_left`).

### Non-Compliant

```abap
CONDENSE lv_text.
TRANSLATE lv_code TO UPPER CASE.
```

### Compliant

```abap
lv_text = condense( lv_text ).
lv_code = to_upper( lv_code ).
```

## Transformation

```diff
- CONDENSE lv_text.
- TRANSLATE lv_code TO UPPER CASE.
+ lv_text = condense( lv_text ).
+ lv_code = to_upper( lv_code ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_CONDENSE` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |
| `CHECK_TRANSLATE` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |
| `CHECK_SHIFT` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |
| `CHECK_SEARCH` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |
| `CHECK_OVERLAY` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |
| `CHECK_REPLACE` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |
| `CHECK_DESCRIBE` | `Boolean` | `true` | Configurable attribute for prefer-string-functions |

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-string-functions:
    enabled: true
    severity: warning
    attributes:
      checkCondense: true
      checkTranslate: true
      checkShift: true
      checkSearch: true
      checkOverlay: true
      checkReplace: true
      checkDescribe: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC STR_FUNC

" SAP CI_ prefix format:
... "#EC CI_STR_FUNC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_FUNC`
* **Finding Code:** `CONDENSE_S`
* **Implementation File:** [zcl_skylint_pref_str_func.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_func.clas.abap)
