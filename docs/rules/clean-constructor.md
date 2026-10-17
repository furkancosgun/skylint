# Keep Constructors Clean & Lightweight

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: CTOR_LOGIC" />
</div>

## 📖 Description

Keep constructors clean; avoid heavy business logic/loops/DB access.

> **ATC Finding Message:** `Avoid heavy business logic/loops in constructor; use injection only`

## 🧠 Rationale & Best Practices

Constructors should only initialize state and inject dependencies. Heavy business logic, database queries, or network I/O in constructors make test mocking and instantiation brittle.

## ❌ Non-Compliant Code

```abap
METHOD constructor.
  super->constructor( ).
  " 15+ statements initializing complex states and reading DB...
ENDMETHOD.
```

## ✅ Compliant Code

```abap
METHOD constructor.
  super->constructor( ).
  mo_gateway = io_gateway. " Simple dependency assignment only
ENDMETHOD.
```

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MAX_STATEMENTS` | `Integer / String` | `10` | Configurable attribute for clean-constructor |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  clean-constructor:
    enabled: true
    severity: warning
    attributes:
      MAX_STATEMENTS: 10
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLEAN_CTOR
" Or with SAP CI_ prefix:
... "#EC CI_CLEAN_CTOR

" Using pragma:
... ##CLEAN_CTOR.
" Or with SAP CI_ prefix:
... ##CI_CLEAN_CTOR.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_CLEAN_CTOR`
* **Finding Code:** `CTOR_LOGIC`
* **Implementation File:** [zcl_skylint_clean_ctor.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_clean_ctor.clas.abap)
