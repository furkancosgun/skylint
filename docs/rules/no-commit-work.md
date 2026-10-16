# `no-commit-work`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NO_COMMIT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations.

## ❌ Non-Compliant Code

```abap
" Inside a RAP behavior implementation (CL_ABAP_BEHAVIOR_HANDLER)
METHOD update.
  MODIFY ENTITIES OF ...
  COMMIT WORK.
ENDMETHOD.
```

## ✅ Compliant Code

```abap
" In RAP, commits are managed automatically by the framework save sequence
METHOD update.
  MODIFY ENTITIES OF ...
ENDMETHOD.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC COMMIT_WORK
" Or with SAP CI_ prefix:
... "#EC CI_COMMIT_WORK

" Using pragma:
... ##COMMIT_WORK.
" Or with SAP CI_ prefix:
... ##CI_COMMIT_WORK.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-commit-work:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_COMMIT_WORK`
* **Implementation File:** [zcl_skylint_no_commit_work.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_commit_work.clas.abap)
