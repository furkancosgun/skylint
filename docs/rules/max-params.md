# Limit Method Parameter Count

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: PARAMCOUNT" />
</div>

## 📖 Description

Method signature cleanliness (excessive parameter count).

> **ATC Finding Message:** `Method signature has too many parameters; consider grouping into structures`

## 🧠 Rationale & Best Practices

Methods with excessive parameters are difficult to comprehend, call, and test. When a method needs more than 5-8 parameters, bundle related fields into a structured type or parameter object.

## ❌ Non-Compliant Code

```abap
METHODS execute
  IMPORTING p1 TYPE i p2 TYPE i p3 TYPE i p4 TYPE i p5 TYPE i p6 TYPE i.
```

## ✅ Compliant Code

```abap
METHODS execute
  IMPORTING is_options TYPE ty_options.
```

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_PARAMETERS` | `Integer / String` | `8` | Configurable attribute for max-params |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  max-params:
    enabled: true
    severity: warning
    attributes:
      MAX_PARAMETERS: 8
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MAX_PARAMS
" Or with SAP CI_ prefix:
... "#EC CI_MAX_PARAMS

" Using pragma:
... ##MAX_PARAMS.
" Or with SAP CI_ prefix:
... ##CI_MAX_PARAMS.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Finding Code:** `PARAMCOUNT`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
