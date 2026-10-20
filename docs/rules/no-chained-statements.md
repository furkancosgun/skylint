# Avoid Chained Declarations & Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: CHAINDECL" />
</div>

## Overview

Avoid chained declarations and chained assignments.

> **ATC Finding Message:** `Avoid chained declarations; declare each entity individually`

## Rationale

Chained statements (`DATA: ... , ... .`) create formatting headaches, merge conflicts in Git diffs, and frequently confuse developers regarding where a type or modifier applies. Each statement should stand independently on its own line.

### Non-Compliant

```abap
DATA: lv_id   TYPE string,
      lv_name TYPE string.
```

### Compliant

```abap
DATA lv_id   TYPE string.
DATA lv_name TYPE string.
```

## Transformation

```diff
- DATA: lv_id   TYPE string,
-       lv_name TYPE string.
+ DATA lv_id   TYPE string.
+ DATA lv_name TYPE string.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `ALLOW_STRUCTURE_CHAINS` | `Boolean` | `true` |
| `CHECK_CHAINED_DECL` | `Boolean` | `true` |
| `CHECK_CHAINED_ASSIGN` | `Boolean` | `true` |

## CLI & CI/CD Configuration

```yaml
checks:
  no-chained-statements:
    enabled: true
    severity: warning
    attributes:
      allowStructureChains: true
      checkChainedDecl: true
      checkChainedAssign: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CHAIN_DECL

" SAP CI_ prefix format:
... "#EC CI_CHAIN_DECL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAINED_STMT`
* **Finding Code:** `CHAINDECL`
* **Implementation File:** [zcl_skylint_no_chained_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chained_stmt.clas.abap)
