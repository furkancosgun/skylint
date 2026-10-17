# Prefer String Templates over CONCATENATE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: CONCATSTR" />
</div>

## 📖 Description

Prefer string templates over CONCATENATE.

> **ATC Finding Message:** `Use string template |...| instead of CONCATENATE`

## 🧠 Rationale & Best Practices

String templates (`|Hello { lv_name }|`) provide type-safe, readable string interpolation with built-in formatting options. They eliminate procedural `CONCATENATE` and `SEPARATED BY` statements.

## ❌ Non-Compliant Code

```abap
CONCATENATE 'Hello' iv_name INTO lv_greeting SEPARATED BY space.
```

## ✅ Compliant Code

```abap
lv_greeting = |Hello { iv_name }|.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `ALLOW_IN_BYTE_MODE` | `Boolean` | `false` | Configurable attribute for prefer-string-template |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-string-template:
    enabled: true
    severity: warning
    attributes:
      ALLOW_IN_BYTE_MODE: false
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STR_TMPL
" Or with SAP CI_ prefix:
... "#EC CI_STR_TMPL

" Using pragma:
... ##STR_TMPL.
" Or with SAP CI_ prefix:
... ##CI_STR_TMPL.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_TMPL`
* **Finding Code:** `CONCATSTR`
* **Implementation File:** [zcl_skylint_pref_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_tmpl.clas.abap)
