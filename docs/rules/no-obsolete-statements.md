# Avoid Obsolete & Forbidden Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: OBSOLETE" />
</div>

## Overview

Avoid obsolete or deprecated statements (MOVE, REFRESH, FORM, AT NEW, etc.).

> **ATC Finding Message:** `Avoid obsolete or deprecated statement; use modern Clean ABAP construct`

## Rationale

Legacy statements such as `MOVE`, `COMPUTE`, `REFRESH`, `TABLES`, `STATICS`, `FORM`, and `LEAVE` are prohibited in ABAP Cloud and discouraged in Clean ABAP. Replace them with modern value assignments and object-oriented constructs.

## Transformation

```diff
- MOVE lv_src TO lv_dst.
+ lv_dst = lv_src.
```

### ✕ Non-Compliant

```abap
MOVE lv_src TO lv_dst.
```

### ✓ Compliant

```abap
lv_dst = lv_src.
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
| `CHECK_MOVE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_REFRESH` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_COMPUTE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_TABLES` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_FIELD_GROUPS` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_TEST_SEAMS` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_BREAK` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_STATICS` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_DEFINE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_EXPORT_MEMORY` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_FORM` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_LOOP_CTL` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |

## CLI & CI/CD Configuration

```yaml
checks:
  no-obsolete-statements:
    enabled: true
    severity: warning
    attributes:
      CHECK_MOVE: true
      CHECK_REFRESH: true
      CHECK_COMPUTE: true
      CHECK_TABLES: true
      CHECK_FIELD_GROUPS: true
      CHECK_TEST_SEAMS: true
      CHECK_BREAK: true
      CHECK_STATICS: true
      CHECK_DEFINE: true
      CHECK_EXPORT_MEMORY: true
      CHECK_FORM: true
      CHECK_LOOP_CTL: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC OBSOLETE
" Or with SAP CI_ prefix:
... "#EC CI_OBSOLETE

" Using pragma:
... ##OBSOLETE.
" Or with SAP CI_ prefix:
... ##CI_OBSOLETE.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBSOLETE`
* **Finding Code:** `OBSOLETE`
* **Implementation File:** [zcl_skylint_no_obsolete.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obsolete.clas.abap)
