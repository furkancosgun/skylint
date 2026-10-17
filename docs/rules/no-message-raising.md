# Avoid Obsolete MESSAGE ... RAISING in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: MSG_RAISE" />
</div>

## 📖 Description

Avoid obsolete MESSAGE ... RAISING; use class-based exceptions.

> **ATC Finding Message:** `Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions`

## 🧠 Rationale & Best Practices

`MESSAGE ... RAISING` combines procedural exception handling with UI messaging, preventing proper separation of concerns. Raise modern class-based exceptions instead.

## ❌ Non-Compliant Code

```abap
MESSAGE e001(zmsg) RAISING not_found.
```

## ✅ Compliant Code

```abap
RAISE EXCEPTION NEW cx_not_found( textid = cx_not_found=>c_item_missing ).
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-message-raising:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MSG_RAISING
" Or with SAP CI_ prefix:
... "#EC CI_MSG_RAISING

" Using pragma:
... ##MSG_RAISING.
" Or with SAP CI_ prefix:
... ##CI_MSG_RAISING.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_MSG_RAISING`
* **Finding Code:** `MSG_RAISE`
* **Implementation File:** [zcl_skylint_no_msg_raising.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_msg_raising.clas.abap)
