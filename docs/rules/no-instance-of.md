---
title: "Replace IS INSTANCE OF and CASE TYPE OF with Polymorphism"
description: "Remove ABAP runtime type checks such as IS INSTANCE OF and CASE TYPE OF in favour of polymorphic interface methods and Open-Closed Principle design."
keywords: "IS INSTANCE OF, CASE TYPE OF, ABAP polymorphism, SAP ATC, no-instance-of"
category: "clean-abap"
ruleId: "no-instance-of"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4207"
---

# Replace IS INSTANCE OF and CASE TYPE OF with Polymorphism

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_INSTANCE_OF" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4207" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid IS INSTANCE OF / CASE TYPE OF checks.

> **ATC Finding Message:** `Avoid runtime type checks via IS INSTANCE OF; use polymorphism`

## Rationale

Runtime type tests turn an open class hierarchy into a growing IF/CASE ladder: every new subtype requires editing this method, which is exactly what the Open-Closed Principle forbids. The branches also depend on concrete classes, so the code cannot be tested with a lightweight test double and the coupling is invisible in the interface. Pushing the behaviour into a method on the common interface lets the runtime dispatch select the implementation and keeps the caller independent of every subtype.

### Non-Compliant

```abap
CASE TYPE OF io_payment.
  WHEN TYPE zcl_credit_card_payment.
    apply_credit_card( io_payment ).
  WHEN TYPE zcl_bank_transfer.
    apply_bank_transfer( io_payment ).
ENDCASE.
```

### Compliant

```abap
" lif_payment->apply is implemented by every payment type
io_payment->apply( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CASE_TYPE` | `Boolean` | <code>true</code> | Also report CASE TYPE OF constructs, not just IS INSTANCE OF (default enabled; disable to allow classic exception mappers). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INSTANCE_OF

" SAP CI_ prefix format:
... "#EC CI_NO_INSTANCE_OF
```

### Both type tests are reported

| Construct | Finding | Replacement |
| --- | --- | --- |
| `IF oref IS INSTANCE OF zcl_class.` | `NO_INST_OF` | add the behaviour to the interface and call it |
| `CASE TYPE OF oref. WHEN TYPE zcl_class.` | `NO_INST_OF` while `CHECK_CASE_TYPE` is on | strategy / visitor dispatched through the interface |
| `IF oref IS BOUND.` | no | - |
| `IF oref IS INITIAL.` | no | - |
| `CAST zcl_class( oref )` / `TRY ... CATCH CX_SY_MOVE_CAST_ERROR` | no | - |

The check matches the token sequences `INSTANCE OF` and `CASE TYPE OF` and does not need the type to be resolvable, so it also works in remote ATC runs.

### When a type test is legitimate

Framework code that reacts to external, non-extensible types sometimes has to inspect the type: deserialisation, RTTI helpers, mapping of arbitrary `CX_ROOT` instances, or adapters around generated proxies. Keep such a branch in one clearly documented place and suppress it with `"#EC NO_INSTANCE_OF`. Setting `CHECK_CASE_TYPE = abap_false` allows `CASE TYPE OF` in classic exception mappers while still banning `IS INSTANCE OF` everywhere else.


## Related Rules

* [Call Static Methods with Class Component Selector (=>)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>
* [Encapsulate Public Class Attributes and Interface Variables](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INSTANCE_OF`
* **ABAP Implementation:** [/skyl/cl_no_instance_of.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_instance_of.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4207)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4207)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INSTANCE_OF&title=%5BBug%5D%3A%20Issue%20in%20no-instance-of)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-instance-of)**
