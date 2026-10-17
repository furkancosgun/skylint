# Limit One Statement per Source Code Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: ONE_STMT" />
</div>

## 📖 Description

Max One Statement Per Line.

> **ATC Finding Message:** `Only one statement is allowed per line`

## 🧠 Rationale & Best Practices

Placing multiple statements on a single line hinders debugger stepping, breaks Git line diffs, and hurts overall code scannability.

## ❌ Non-Compliant Code

```abap
lv_a = 1. lv_b = 2.
```

## ✅ Compliant Code

```abap
lv_a = 1.
lv_b = 2.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  max-one-statement:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ONE_STMT
" Or with SAP CI_ prefix:
... "#EC CI_ONE_STMT

" Using pragma:
... ##ONE_STMT.
" Or with SAP CI_ prefix:
... ##CI_ONE_STMT.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ONE_STMT`
* **Finding Code:** `ONE_STMT`
* **Implementation File:** [zcl_skylint_max_one_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_one_stmt.clas.abap)
