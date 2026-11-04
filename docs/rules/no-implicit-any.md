---
title: "Declare Concrete Types Instead of Generic ANY"
description: "Flag untyped FIELD-SYMBOLS and generic ANY, DATA, CLIKE or TABLE method parameters in ABAP - enforce concrete types for compile-time safety."
keywords: "ABAP generic types, TYPE any, FIELD-SYMBOLS typing, no-implicit-any, ABAP Cloud"
category: "clean-abap"
ruleId: "no-implicit-any"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5054"
---

# Declare Concrete Types Instead of Generic ANY

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_IMPLICIT_ANY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5054" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Specify concrete types instead of generic or implicit ANY.

> **ATC Finding Message:** `Specify explicit concrete types instead of generic or implicit ANY`

## Rationale

Untyped FIELD-SYMBOLS and generic parameter types such as ANY, DATA, OBJECT, CLIKE, CSEQUENCE, NUMERIC or TABLE postpone every type check to runtime, so misuse is only detected when the assignment dumps with a MOVE-CAST or internal table error in production. Declaring the concrete type, a DDIC structure, a table type or an interface, lets the compiler validate component access, parameter passing and RETURNING types at build time and keeps the code compatible with the stricter ABAP Cloud type checks. The check reports NO_ANY_TYP for FIELD-SYMBOLS without TYPE/LIKE, for FIELD-SYMBOLS with a generic built-in type and for METHODS/CLASS-METHODS parameters whose type is missing or generic. Fully typed declarations make the signature self-documenting and remove the need for runtime DESCRIBE or ASSIGN COMPONENT introspection.

### Non-Compliant

```abap
FIELD-SYMBOLS <ls_order_item>.
ASSIGN lt_order_items[ 1 ] TO <ls_order_item>.
```

### Compliant

```abap
FIELD-SYMBOLS <ls_order_item> TYPE zsales_order_item.
ASSIGN lt_order_items[ 1 ] TO <ls_order_item>.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IMPLICIT_ANY

" SAP CI_ prefix format:
... "#EC CI_NO_IMPLICIT_ANY
```

## Reported forms

| Form | Example |
| --- | --- |
| `FIELD-SYMBOLS` without `TYPE` / `LIKE` | `FIELD-SYMBOLS <ls_order_item>.` |
| Generic `FIELD-SYMBOLS` type | `<ls_order_item> TYPE any`, `TYPE data`, `TYPE clike` |
| Parameter without a type | `IMPORTING iv_count` |
| Generic parameter type | `IMPORTING iv_count TYPE numeric` |

Generic names recognised by the check: `ANY`, `DATA`, `OBJECT`, `CLIKE`, `CSEQUENCE`, `XSEQUENCE`, `NUMERIC`, `DECFLOAT`, `SIMPLE`, `TABLE`, `ANY TABLE`, `INDEX TABLE`.

## Not reported

- `FIELD-SYMBOLS <lo_service> TYPE REF TO zif_service.` - a reference type is concrete.
- `LIKE` declarations that copy the type of a typed data object.
- Inline declarations such as `ASSIGN lt_items[ 1 ] TO FIELD-SYMBOL(<ls_item>)`, which derive the type from the memory area.
- `EXPORTING`, `CHANGING` and `RETURNING` parameters of a type that is not in the generic list.

## Migration tip

Replace `TYPE any` with the structure that is actually moved, and `TYPE standard table` with the concrete table type (`TYPE zsales_order_items`). Where a truly generic container is required, prefer `TYPE REF TO zif_...` or `TYPE REF TO data` behind a dedicated accessor class instead of spreading `ASSIGN COMPONENT` logic.


## Related Rules

* [Declare Constants with an Explicit TYPE and LENGTH](/rules/pref-full-typed) — <code>#EC PREF_FULL_TYPED</code>
* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IMPLICIT_ANY`
* **ABAP Implementation:** [/skyl/cl_no_implicit_any.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_implicit_any.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5054)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5054)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IMPLICIT_ANY&title=%5BBug%5D%3A%20Issue%20in%20no-implicit-any)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-implicit-any)**
