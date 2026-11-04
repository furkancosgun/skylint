---
title: "Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW"
description: "Modernize object creation: replace CREATE OBJECT with the NEW #( ) expression and RAISE EXCEPTION TYPE with RAISE EXCEPTION NEW in ABAP Cloud."
keywords: "pref-new-op, CREATE OBJECT, NEW operator, RAISE EXCEPTION NEW, Clean ABAP"
category: "clean-abap"
ruleId: "pref-new-op"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1032"
---

# Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_NEW_OPERATOR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1032" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION.

> **ATC Finding Messages:**
> - `Prefer NEW #( ) expression over CREATE OBJECT`
> - `Prefer RAISE EXCEPTION NEW cx_name( ) over RAISE EXCEPTION TYPE`

## Rationale

CREATE OBJECT is a procedural statement that cannot appear inside an expression, and RAISE EXCEPTION TYPE needs a separate class reference plus EXPORTING. NEW #( ) and RAISE EXCEPTION NEW ... ( ) infer the class from the context, can be nested in constructor expressions, method arguments and RETURNING values, and remove the uninitialized-reference window between declaration and creation. The check reports PREF_NEW and PREF_RSNEW and offers a drop-in replacement line as QuickFix whenever the parameter passing is simple enough to rewrite mechanically.

### Non-Compliant

```abap
DATA lo_invoice_service TYPE REF TO zcl_invoice_service.
CREATE OBJECT lo_invoice_service EXPORTING iv_company_code = lv_company_code.
```

### Compliant

```abap
DATA(lo_invoice_service) = NEW zcl_invoice_service( iv_company_code = lv_company_code ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CREATE_OBJECT` | `Boolean` | <code>true</code> | Report CREATE OBJECT statements that can be replaced by a NEW #( ) expression. Disable only for legacy frameworks that insist on CREATE OBJECT. |
| `CHECK_RAISE_EXCEPTION` | `Boolean` | <code>true</code> | Report RAISE EXCEPTION TYPE statements that can be rewritten as RAISE EXCEPTION NEW zcx_error( ... ). Disable when exception classes are created dynamically. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NEW_OPERATOR

" SAP CI_ prefix format:
... "#EC CI_PREF_NEW_OPERATOR
```

### Finding codes

| Code | Trigger | QuickFix |
| --- | --- | --- |
| `PREF_NEW` | `CREATE OBJECT lo_ref EXPORTING ...` | `TONEW` rewrites it to `lo_ref = NEW #( ... )` |
| `PREF_RSNEW` | `RAISE EXCEPTION TYPE zcx_error EXPORTING ...` | `RAISENEW` rewrites it to `RAISE EXCEPTION NEW zcx_error( ... )` |

The rewrite is only produced for a static class name and a flat `EXPORTING name = value` list. `CREATE OBJECT ... TYPE (lv_class)`, `PARAMETER-TABLE`, `EXCEPTIONS`, `MESSAGE`, `MESSAGE-ID` and `FOR TESTING` are left untouched, so inherited or dynamic creation keeps reporting nothing but the finding. The two checks are switched independently through `CHECK_CREATE_OBJECT` and `CHECK_RAISE_EXCEPTION`, and can be suppressed with `"#EC PREF_NEW_OPERATOR` / `"#EC PREF_RAISE_EXC_NEW`.


## Related Rules

* [Declare Instance Constructor in PUBLIC SECTION Regardless of Instantiation Scope](/rules/pref-pub-ctor) — <code>#EC PREF_PUB_CTOR</code>
* [Name Static Factory Methods CREATE_* When They Return Their Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Design for Inheritance or Prohibit It with FINAL](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_NEW_OP`
* **ABAP Implementation:** [/skyl/cl_pref_new_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_new_op.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1032)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1032)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_NEW_OP&title=%5BBug%5D%3A%20Issue%20in%20pref-new-op)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-new-op)**
