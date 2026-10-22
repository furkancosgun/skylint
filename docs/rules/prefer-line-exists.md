---
description: "Prefer line_exists( ) over READ TABLE with NO FIELDS"
---

# Prefer line_exists( ) over READ TABLE TRANSPORTING NO FIELDS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC LINE_EXISTS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer line_exists( ) over READ TABLE with NO FIELDS.

> **ATC Finding Message:** `Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS`

## Rationale

`line_exists( )` clearly communicates the intent of checking table membership in a single functional expression, eliminating the boilerplate of `READ TABLE ... TRANSPORTING NO FIELDS` followed by `sy-subrc = 0`.

### Non-Compliant

```abap
READ TABLE lt_items TRANSPORTING NO FIELDS WITH KEY id = lv_id.
IF sy-subrc = 0.
  process( ).
ENDIF.
```

### Compliant

```abap
IF line_exists( lt_items[ id = lv_id ] ).
  process( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC LINE_EXISTS

" SAP CI_ prefix format:
... "#EC CI_LINE_EXISTS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINE_EXISTS`
* **Implementation File:** [zcl_skylint_pref_line_exists.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_line_exists.clas.abap)
