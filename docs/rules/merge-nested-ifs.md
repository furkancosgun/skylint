# Merge Nested IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: NESTEDIF" />
</div>

## Overview

Detect consecutive nested IF blocks that can be merged with AND.

> **ATC Finding Message:** `Nested IF block can be merged with outer IF using AND`

## Rationale

Consecutive nested `IF` statements without intermediate statements can be combined with `AND`. This reduces nesting depth, flattens control flow, and simplifies cyclomatic complexity.

## Transformation

```diff
- IF is_connected( ).
-   IF has_permission( ).
-     execute( ).
-   ENDIF.
- ENDIF.
+ IF is_connected( ) AND has_permission( ).
+   execute( ).
+ ENDIF.
```

### ✕ Non-Compliant

```abap
IF is_connected( ).
  IF has_permission( ).
    execute( ).
  ENDIF.
ENDIF.
```

### ✓ Compliant

```abap
IF is_connected( ) AND has_permission( ).
  execute( ).
ENDIF.
```

## CLI & CI/CD Configuration

```yaml
checks:
  merge-nested-ifs:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MERGE_IFS
" Or with SAP CI_ prefix:
... "#EC CI_MERGE_IFS

" Using pragma:
... ##MERGE_IFS.
" Or with SAP CI_ prefix:
... ##CI_MERGE_IFS.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_MERGE_IFS`
* **Finding Code:** `NESTEDIF`
* **Implementation File:** [zcl_skylint_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_merge_ifs.clas.abap)
