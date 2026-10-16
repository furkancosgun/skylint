# `no-client-specified`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CLIENT_SPE` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
SELECT * FROM zskylint_dummy USING CLIENT '100' INTO TABLE @lt_tab.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
SELECT * FROM zskylint_dummy INTO TABLE @lt_tab.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLIENT_SPEC

" Using pragma:
... ##CLIENT_SPEC.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-client-specified:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CLIENT_SPEC`
* **Implementation File:** [zcl_skylint_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_client_spec.clas.abap)
