# Avoid Obsolete & Forbidden Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: OBSOLETE" />
</div>

## Overview

Avoid obsolete statements (MOVE, REFRESH, FORM, etc.).

> **ATC Finding Message:** `Avoid obsolete or deprecated statement; use modern Clean ABAP construct`

## Rationale

Legacy statements such as `MOVE`, `COMPUTE`, `REFRESH`, `TABLES`, `STATICS`, `FORM`, and `LEAVE` are prohibited in ABAP Cloud and discouraged in Clean ABAP. Replace them with modern value assignments and object-oriented constructs.

### Non-Compliant

```abap
MOVE lv_src TO lv_dst.
```

### Compliant

```abap
lv_dst = lv_src.
```

## Transformation

```diff
- MOVE lv_src TO lv_dst.
+ lv_dst = lv_src.
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
| `CHECK_ADD` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_ADD_CORR` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_TYPE_POOLS` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_RANGES` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_HEADER_LINE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_LOAD` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_PACK` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_UNPACK` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_EXTRACT` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_COMMON_PART` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_FREE_MEMORY` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_PROVIDE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_CONTEXTS` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_INITIAL_SIZE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_CATCH_SYSTEM` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_GET_REFERENCE` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_INFOTYPES` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_COMMUNICATION` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |
| `CHECK_SET_EXT_CHECK` | `Boolean` | `true` | Configurable attribute for no-obsolete-statements |

## CLI & CI/CD Configuration

```yaml
checks:
  no-obsolete-statements:
    enabled: true
    severity: warning
    attributes:
      checkMove: true
      checkRefresh: true
      checkCompute: true
      checkTables: true
      checkFieldGroups: true
      checkTestSeams: true
      checkBreak: true
      checkStatics: true
      checkDefine: true
      checkExportMemory: true
      checkForm: true
      checkLoopCtl: true
      checkAdd: true
      checkAddCorr: true
      checkTypePools: true
      checkRanges: true
      checkHeaderLine: true
      checkLoad: true
      checkPack: true
      checkUnpack: true
      checkExtract: true
      checkCommonPart: true
      checkFreeMemory: true
      checkProvide: true
      checkContexts: true
      checkInitialSize: true
      checkCatchSystem: true
      checkGetReference: true
      checkInfotypes: true
      checkCommunication: true
      checkSetExtCheck: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC OBSOLETE

" SAP CI_ prefix format:
... "#EC CI_OBSOLETE
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBSOLETE`
* **Finding Code:** `OBSOLETE`
* **Implementation File:** [zcl_skylint_no_obsolete.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obsolete.clas.abap)
