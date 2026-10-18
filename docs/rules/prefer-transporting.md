# Specify TRANSPORTING in MODIFY / READ TABLE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="Finding: FULL_MODIF" />
</div>

## Overview

Avoid MODIFY itab in LOOP without TRANSPORTING clause.

> **ATC Finding Message:** `Specify TRANSPORTING fields in MODIFY itab inside loop for performance`

## Rationale

Modifying internal tables without specifying `TRANSPORTING` copies all table fields across the buffer. Specify only the modified fields to optimize execution speed.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item. " Full line copy without specifying TRANSPORTING
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items INTO ls_item.
  ls_item-status = 'DONE'.
  MODIFY lt_items FROM ls_item TRANSPORTING status.
ENDLOOP.
```

## Transformation

```diff
- LOOP AT lt_items INTO ls_item.
-   ls_item-status = 'DONE'.
-   MODIFY lt_items FROM ls_item. " Full line copy without specifying TRANSPORTING
- ENDLOOP.
+ LOOP AT lt_items INTO ls_item.
+   ls_item-status = 'DONE'.
+   MODIFY lt_items FROM ls_item TRANSPORTING status.
+ ENDLOOP.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-transporting:
    enabled: true
    severity: warning
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
* **Finding Code:** `FULL_MODIF`
* **Implementation File:** [zcl_skylint_pref_transport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_transport.clas.abap)
