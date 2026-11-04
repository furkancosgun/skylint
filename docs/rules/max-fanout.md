---
title: "Limit Distinct Class and Interface Coupling per Procedure"
description: "Limit architectural class and interface fan-out coupling per ABAP procedure to keep unit tests maintainable and services decoupled."
keywords: "max-fanout, coupling fan-out ABAP, class dependencies metric, Clean ABAP architecture, SAP ATC metrics"
category: "metrics"
ruleId: "max-fanout"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4478"
---

# Limit Distinct Class and Interface Coupling per Procedure

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_FANOUT" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4478" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit type fan-out per procedure.

> **ATC Finding Message:** `Procedure depends on too many distinct classes or interfaces`

## Rationale

Coupling fan-out measures the number of distinct external classes and interfaces that a single procedure depends on. Referencing more than 15 distinct collaborator types signals a God method or over-centralized mediator that is tightly coupled to wide swaths of the system architecture. Such excessive coupling makes unit testing almost impossible, as setting up test doubles and mocks for 15+ collaborators is brittle and labor-intensive. In Clean ABAP and modern SAP enterprise design, procedures with high fan-out should be decomposed using design patterns like Facade, Mediator, or Domain Services.

### Non-Compliant

```abap
DATA lo_cust_svc TYPE REF TO zcl_customer_service.
DATA lo_inv_svc  TYPE REF TO zcl_invoice_service.
DATA lo_tax_svc  TYPE REF TO zcl_tax_calculation_svc.
DATA lo_pay_svc  TYPE REF TO zcl_payment_gateway_svc.
DATA lo_gl_svc   TYPE REF TO zcl_general_ledger_svc.
DATA lo_ar_svc   TYPE REF TO zcl_accounts_receivable.
DATA lo_fx_svc   TYPE REF TO zcl_foreign_exchange_svc.
DATA lo_disc_svc TYPE REF TO zcl_discount_engine.
DATA lo_notif    TYPE REF TO zcl_notification_service.
DATA lo_audit    TYPE REF TO zcl_compliance_audit_svc.
DATA lo_archive  TYPE REF TO zcl_document_archive_svc.
DATA lo_workflow TYPE REF TO zcl_approval_workflow.
DATA lo_credit   TYPE REF TO zcl_credit_check_engine.
DATA lo_shipment TYPE REF TO zcl_shipment_tracking_svc.
DATA lo_pricing  TYPE REF TO zcl_pricing_condition_svc.
DATA lo_partner  TYPE REF TO zcl_business_partner_mgr.
execute_settlement( ).
```

### Compliant

```abap
DATA lo_settlement_facade TYPE REF TO zif_settlement_facade.

lo_settlement_facade = mo_facade_factory->get_settlement_facade( ).
lo_settlement_facade->execute_full_settlement( is_settlement_context ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_FANOUT` | `Integer` | <code>15</code> | Maximum allowed number of distinct collaborator classes or interfaces referenced by a single procedure (default: 15). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_FANOUT

" SAP CI_ prefix format:
... "#EC CI_MAX_FANOUT
```

## Analysis and RTTI Mechanics

The check analyzes compiler references attached to each statement in the procedure body:

- **Type Resolution**: Inspects compiler references of kind `type` and `method` and resolves them via ABAP RTTI (`cl_abap_objectdescr`).
- **Unique Counting**: Deduplicates referenced classes and interfaces by their relative object name into a hashed set.
- **Local Execution Only**: Because this rule utilizes ABAP Run-Time Type Identification (RTTI) to resolve class descriptors, `remote_enablement = abap_false` is enforced. This check runs locally on the SAP ATC system.
- **Reporting**: If the number of distinct object types exceeds `MAX_FANOUT` (default `15`), finding `MAX_FANOUT` is reported on the first procedure statement.

## Suppression

Suppress the check with the pseudo-comment `"#EC MAX_FANOUT` on the opening `METHOD` statement.


## Related Rules

* [Limit Class Inheritance Depth and Favor Object Composition](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Limit Class Member Attribute Count to Prevent God Objects](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_FANOUT`
* **ABAP Implementation:** [/skyl/cl_max_fanout.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_fanout.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4478)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4478)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_FANOUT&title=%5BBug%5D%3A%20Issue%20in%20max-fanout)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-fanout)**
