---
description: "Avoid identical code in IF and ELSE branches"
---

# Avoid Identical Statements in IF Branches

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IDENT_CONT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid identical code in IF and ELSE branches.

> **ATC Finding Message:** `Identical statement in IF and ELSE branches; extract common code`

## Rationale

Statements repeated in every branch of an IF/ELSEIF/ELSE carry no branch-specific meaning and duplicate maintenance. If the same statement starts or ends every branch, extract it before or after the IF so it is written once and stays in sync.

### Non-Compliant

```abap
IF lv_is_active = abap_true.
  process( ).
ELSE.
  process( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_active = abap_true.
  process_active( ).
ELSE.
  process_inactive( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IDENT_CONT

" SAP CI_ prefix format:
... "#EC CI_NO_IDENT_CONT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_IDENT_CONT`
* **Implementation File:** [zcl_skylint_no_ident_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_ident_cont.clas.abap)
