---
description: "Avoid MODIFY itab in LOOP without TRANSPORTING clause"
---

# Specify TRANSPORTING in MODIFY / READ TABLE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC TRANSPORTING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid MODIFY itab in LOOP without TRANSPORTING clause.

> **ATC Finding Message:** `Specify TRANSPORTING fields in MODIFY itab inside loop for performance`

## Rationale

MODIFY without TRANSPORTING copies the entire table line from the work area, even when only one field changed. On wide tables this costs extra memory and CPU for every row. Name the changed fields in TRANSPORTING so only the relevant data is written.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item TRANSPORTING status.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC TRANSPORTING

" SAP CI_ prefix format:
... "#EC CI_TRANSPORTING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TRANSPORT`
* **Implementation File:** [zcl_skylint_pref_transport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_transport.clas.abap)
