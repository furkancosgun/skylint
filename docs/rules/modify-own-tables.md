# Only Modify Tables Defined in Your Own Package/Component

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: NOT_OWN_TB" />
</div>

## 📖 Description

Modify Only Own Database Tables.

> **ATC Finding Message:** `Modify only customer-owned (Z/Y or /.../) database tables`

## 🧠 Rationale & Best Practices

Directly inserting, updating, or deleting tables belonging to another application component bypasses business validation logic and violates modular architecture.

## ❌ Non-Compliant Code

```abap
DELETE FROM mara WHERE matnr = '100'.
```

## ✅ Compliant Code

```abap
DELETE FROM zmara WHERE matnr = '100'.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  modify-own-tables:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC OWN_TABLES
" Or with SAP CI_ prefix:
... "#EC CI_OWN_TABLES

" Using pragma:
... ##OWN_TABLES.
" Or with SAP CI_ prefix:
... ##CI_OWN_TABLES.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_MODIFY_OWN_TAB`
* **Finding Code:** `NOT_OWN_TB`
* **Implementation File:** [zcl_skylint_modify_own_tab.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_modify_own_tab.clas.abap)
