---
description: "Merge consecutive nested IF blocks using boolean AND"
---

# Merge Nested IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC MERGE_IFS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Merge consecutive nested IF blocks using boolean AND.

> **ATC Finding Message:** `Nested IF block can be merged with outer IF using AND`

## Rationale

Consecutive nested `IF` statements without intermediate statements can be combined with `AND`. This reduces nesting depth, flattens control flow, and simplifies cyclomatic complexity.

### Non-Compliant

```abap
IF is_connected( ).
  IF has_permission( ).
    execute( ).
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF is_connected( ) AND has_permission( ).
  execute( ).
ENDIF.
```

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

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-merged-ifs:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MERGE_IFS

" SAP CI_ prefix format:
... "#EC CI_MERGE_IFS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_MERGE_IFS`
* **Implementation File:** [zcl_skylint_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_merge_ifs.clas.abap)
