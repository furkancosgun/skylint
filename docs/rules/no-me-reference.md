# Avoid Redundant ME-> Self Reference

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: AVOIDME" />
</div>

## 📖 Description

Avoid self-reference ME->.

> **ATC Finding Message:** `Avoid unnecessary ME-> reference`

## 🧠 Rationale & Best Practices

In ABAP, member variables and methods are automatically accessible within the instance context. Prefixing every member access with `me->` creates visual noise, except when disambiguating parameter shadowing in constructors.

## ❌ Non-Compliant Code

```abap
me->mv_status = c_active.
me->process_order( ).
```

## ✅ Compliant Code

```abap
mv_status = c_active.
process_order( ).
```

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `ALLOW_IN_CONSTRUCTORS` | `Boolean` | `true` | Configurable attribute for no-me-reference |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-me-reference:
    enabled: true
    severity: warning
    attributes:
      ALLOW_IN_CONSTRUCTORS: true
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ME
" Or with SAP CI_ prefix:
... "#EC CI_ME

" Using pragma:
... ##ME.
" Or with SAP CI_ prefix:
... ##CI_ME.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ME_REFERENCE`
* **Finding Code:** `AVOIDME`
* **Implementation File:** [zcl_skylint_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_me_reference.clas.abap)
