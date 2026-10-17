# Avoid Explicit COMMIT WORK in Business Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: NO_COMMIT" />
</div>

## 📖 Description

Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations.

> **ATC Finding Message:** `Avoid COMMIT/ROLLBACK WORK; transactional control belongs to framework`

## 🧠 Rationale & Best Practices

Transactional business logic should rely on the persistence framework or framework save sequence (e.g. RAP) rather than triggering premature or uncoordinated database commits.

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

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-commit-work:
    enabled: true
    severity: warning
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

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_COMMIT_WORK`
* **Finding Code:** `NO_COMMIT`
* **Implementation File:** [zcl_skylint_no_commit_work.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_commit_work.clas.abap)
