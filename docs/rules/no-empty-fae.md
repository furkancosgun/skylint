# `no-empty-fae`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FAENOCHECK` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Unsecure FOR ALL ENTRIES (Missing empty itab check).

## ❌ Non-Compliant Code

```abap
DATA s TYPE tt_entry.
DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
```

## ✅ Compliant Code

```abap
DATA s TYPE tt_entry.
DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
IF s IS NOT INITIAL.
  SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EMPTY_FAE

" Using pragma:
... ##EMPTY_FAE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-empty-fae:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_FAE`
* **Implementation File:** [zcl_skylint_no_empty_fae.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_fae.clas.abap)
