# Avoid CLIENT SPECIFIED / USING CLIENT in Cloud

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: CLIENT_SPE" />
</div>

## 📖 Description

Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL.

> **ATC Finding Message:** `Avoid explicit client specification in ABAP SQL`

## 🧠 Rationale & Best Practices

Explicit client switching bypasses automatic multi-tenant client isolation and is strictly prohibited in ABAP Cloud environment standards.

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer USING CLIENT '100' INTO TABLE @lt_customers.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-client-specified:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLIENT_SPEC
" Or with SAP CI_ prefix:
... "#EC CI_CLIENT_SPEC

" Using pragma:
... ##CLIENT_SPEC.
" Or with SAP CI_ prefix:
... ##CI_CLIENT_SPEC.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CLIENT_SPEC`
* **Finding Code:** `CLIENT_SPE`
* **Implementation File:** [zcl_skylint_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_client_spec.clas.abap)
