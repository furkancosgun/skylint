---
description: "Check sy-subrc immediately after AUTHORITY-CHECK"
---

# Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="danger" text="Error" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC AUTH_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Check sy-subrc immediately after AUTHORITY-CHECK.

> **ATC Finding Message:** `AUTHORITY-CHECK sy-subrc must be checked immediately; failing to check bypasses authorization`

## Rationale

Executing an AUTHORITY-CHECK statement without immediately evaluating sy-subrc completely defeats the authorization check, allowing unauthorized actors to perform privileged actions. Immediate evaluation of sy-subrc with an authorization rejection response is mandatory.

### Non-Compliant

```abap
AUTHORITY-CHECK OBJECT 'S_DEVELOP' ID 'ACTVT' FIELD '03'.
perform_action( ).
```

### Compliant

```abap
AUTHORITY-CHECK OBJECT 'S_DEVELOP' ID 'ACTVT' FIELD '03'.
IF sy-subrc <> 0.
  RAISE EXCEPTION NEW cx_no_auth( ).
ENDIF.
perform_action( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC AUTH_SUBRC

" SAP CI_ prefix format:
... "#EC CI_AUTH_SUBRC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_AUTH_SUBRC`
* **Implementation File:** [zcl_skylint_pref_auth_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_auth_subrc.clas.abap)
