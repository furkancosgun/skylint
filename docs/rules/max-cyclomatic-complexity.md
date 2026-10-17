# Limit Cyclomatic Complexity

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="Finding: CYCLO_COMP" />
</div>

## 📖 Description

Cyclomatic Complexity Threshold.

> **ATC Finding Message:** `Procedure cyclomatic complexity exceeds threshold`

## 🧠 Rationale & Best Practices

High cyclomatic complexity means a method contains too many decision points (branches, loops, catches), making comprehensive unit test branch coverage nearly impossible.

## ❌ Non-Compliant Code

```abap
" Complex method containing excessive branches (> 10 cyclomatic complexity)
METHOD compute.
  IF c1. ... ELSEIF c2. ... ELSEIF c3. ...
ENDMETHOD.
```

## ✅ Compliant Code

```abap
" Decompose into strategy classes or cohesive helper methods
METHOD compute.
  ro_strategy = mo_factory->get_strategy( mv_type ).
  ro_strategy->execute( ).
ENDMETHOD.
```

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_COMPLEXITY` | `Integer / String` | `5` | Configurable attribute for max-cyclomatic-complexity |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  max-cyclomatic-complexity:
    enabled: true
    severity: warning
    attributes:
      MAX_COMPLEXITY: 5
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CYCLO_COMP
" Or with SAP CI_ prefix:
... "#EC CI_CYCLO_COMP

" Using pragma:
... ##CYCLO_COMP.
" Or with SAP CI_ prefix:
... ##CI_CYCLO_COMP.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_CYCLO_COMP`
* **Finding Code:** `CYCLO_COMP`
* **Implementation File:** [zcl_skylint_max_cyclo_comp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_cyclo_comp.clas.abap)
