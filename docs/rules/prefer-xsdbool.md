# Prefer xsdbool( ) for Boolean Assignments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PREFERXSDB" />
</div>

## 📖 Description

Prefer xsdbool( ) expression over manual IF-ELSE assignment.

> **ATC Finding Message:** `Prefer xsdbool( ) over manual IF-ELSE assignment`

## 🧠 Rationale & Best Practices

Writing `IF cond. lv_flag = abap_true. ELSE. lv_flag = abap_false. ENDIF.` is 5 lines of boilerplate. `lv_flag = xsdbool( cond )` expresses the same logic cleanly in one readable line.

## ❌ Non-Compliant Code

```abap
IF lv_count > 0.
  lv_has_items = abap_true.
ELSE.
  lv_has_items = abap_false.
ENDIF.
```

## ✅ Compliant Code

```abap
lv_has_items = xsdbool( lv_count > 0 ).
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-xsdbool:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC XSDBOOL
" Or with SAP CI_ prefix:
... "#EC CI_XSDBOOL

" Using pragma:
... ##XSDBOOL.
" Or with SAP CI_ prefix:
... ##CI_XSDBOOL.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_XSDBOOL`
* **Finding Code:** `PREFERXSDB`
* **Implementation File:** [zcl_skylint_pref_xsdbool.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_xsdbool.clas.abap)
