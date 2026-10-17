# Avoid Obsolete Dash (-) in Program Identifiers

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: NO_DASH" />
</div>

## 📖 Description

No Dashes in Variable and Form Names.

> **ATC Finding Message:** `Avoid dashes in variable, constant, and field-symbol names`

## 🧠 Rationale & Best Practices

Using a hyphen/dash in structure component references is archaic. Modern ABAP standardizes on the arrow notation `->` or hyphen only where mandatory.

## ❌ Non-Compliant Code

```abap
DATA foo-bar TYPE i.
```

## ✅ Compliant Code

```abap
DATA foobar TYPE i.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  names-no-dash:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_DASH
" Or with SAP CI_ prefix:
... "#EC CI_NO_DASH

" Using pragma:
... ##NO_DASH.
" Or with SAP CI_ prefix:
... ##CI_NO_DASH.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NAMES_NO_DASH`
* **Finding Code:** `NO_DASH`
* **Implementation File:** [zcl_skylint_names_no_dash.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_names_no_dash.clas.abap)
