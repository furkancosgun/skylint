---
description: "Prefer line_exists( ) over READ TABLE with NO FIELDS"
---

# Prefer line_exists( ) over READ TABLE TRANSPORTING NO FIELDS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC LINE_EXISTS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer line_exists( ) over READ TABLE with NO FIELDS.

> **ATC Finding Message:** `Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS`

## Rationale

READ TABLE TRANSPORTING NO FIELDS followed by a sy-subrc check is a procedural way to ask whether a row exists. line_exists( ) expresses membership in one expression and can be used directly in a condition. It also removes the risk of checking a sy-subrc that was overwritten by an unrelated statement.

### Non-Compliant

```abap
READ TABLE lt_customers TRANSPORTING NO FIELDS WITH KEY customer_id = lv_id.
IF sy-subrc = 0.
  process_customer( lv_id ).
ENDIF.
```

### Compliant

```abap
IF line_exists( lt_customers[ customer_id = lv_id ] ).
  process_customer( lv_id ).
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
