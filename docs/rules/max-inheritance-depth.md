# Limit Inheritance Depth

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: DEEP_INHRT" />
</div>

## 📖 Description

Avoid deep class inheritance hierarchies.

> **ATC Finding Message:** `Avoid deep class inheritance; prefer composition over inheritance`

## 🧠 Rationale & Best Practices

Deep class inheritance hierarchies create the fragile base class problem and tight coupling. Favor composition over inheritance (`HAS-A` instead of `IS-A`).

## ❌ Non-Compliant Code

```abap
CLASS lcl_child DEFINITION INHERITING FROM lcl_sub_parent. " Depth > 3
ENDCLASS.
```

## ✅ Compliant Code

```abap
" Favor composition over deep class inheritance hierarchies
CLASS lcl_worker DEFINITION.
  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO if_engine.
ENDCLASS.
```

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_DEPTH` | `Integer / String` | `1` | Configurable attribute for max-inheritance-depth |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  max-inheritance-depth:
    enabled: true
    severity: warning
    attributes:
      MAX_DEPTH: 1
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC INHERIT_DEPTH
" Or with SAP CI_ prefix:
... "#EC CI_INHERIT_DEPTH

" Using pragma:
... ##INHERIT_DEPTH.
" Or with SAP CI_ prefix:
... ##CI_INHERIT_DEPTH.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_INHERIT`
* **Finding Code:** `DEEP_INHRT`
* **Implementation File:** [zcl_skylint_max_inherit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_inherit.clas.abap)
