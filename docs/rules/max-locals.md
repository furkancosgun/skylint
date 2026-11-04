---
title: "Limit Local Variable and Field-Symbol Declarations"
description: "Limit the number of local variable and inline declarations per ABAP method to reduce mutable state and enforce Clean ABAP modularity."
keywords: "max-locals, local variable limit ABAP, Clean ABAP state, inline declaration count, SAP ATC metrics"
category: "metrics"
ruleId: "max-locals"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4447"
---

# Limit Local Variable and Field-Symbol Declarations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_LOCALS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4447" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit local variable count per procedure.

> **ATC Finding Message:** `Procedure declares too many local symbols`

## Rationale

A procedure declaring dozens of local variables and field symbols invariably indicates an overloaded method with multiple conflicting responsibilities. Tracking extensive mutable state inside a single method increases the cognitive load of code reviews, leads to unintended side effects from variable reuse, and complicates unit test isolation. Clean ABAP recommends keeping methods focused on a single task with minimal local state. Excess declarations should be refactored by introducing cohesive parameter structures, dedicated value objects, or by delegating distinct subtasks to helper methods.

### Non-Compliant

```abap
DATA lv_net_amount TYPE p LENGTH 8 DECIMALS 2.
DATA lv_tax_amount TYPE p LENGTH 8 DECIMALS 2.
DATA lv_gross_amount TYPE p LENGTH 8 DECIMALS 2.
DATA lv_discount_rate TYPE p LENGTH 4 DECIMALS 2.
DATA lv_discount_amount TYPE p LENGTH 8 DECIMALS 2.
DATA lv_freight_charges TYPE p LENGTH 8 DECIMALS 2.
DATA lv_customs_duty TYPE p LENGTH 8 DECIMALS 2.
DATA lv_handling_fee TYPE p LENGTH 8 DECIMALS 2.
DATA lv_insurance_fee TYPE p LENGTH 8 DECIMALS 2.
DATA lv_surcharge_amount TYPE p LENGTH 8 DECIMALS 2.
DATA lv_currency_code TYPE c LENGTH 3.
DATA lv_exchange_rate TYPE p LENGTH 6 DECIMALS 4.
DATA lv_customer_id TYPE c LENGTH 10.
DATA lv_billing_date TYPE d.
DATA lv_payment_terms TYPE c LENGTH 4.
DATA lv_is_tax_exempt TYPE abap_bool.
calculate_totals( ).
```

### Compliant

```abap
DATA ls_financial_summary TYPE ty_financial_summary.
DATA ls_customer_context  TYPE ty_customer_context.

ls_financial_summary = calculate_financials( ls_customer_context ).
persist_billing_summary( ls_financial_summary ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_LOCALS` | `Integer` | <code>15</code> | Maximum allowed number of local data, field-symbol, and inline declarations per procedure (default: 15). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_LOCALS

" SAP CI_ prefix format:
... "#EC CI_MAX_LOCALS
```

## Evaluation Criteria

The check inspects the procedure body and counts local symbols as follows:

- **Explicit Declarations**: Each statement with keyword `DATA` or `FIELD-SYMBOLS` increments the count by 1. Note that colon-chained declarations are normalized by the parser into individual statements.
- **Inline Declarations**: Any inline declarations (`DATA(...)` and `FIELD-SYMBOL(...)`) inside other statements (such as `SELECT`, `LOOP AT`, `READ TABLE`, or method calls) are counted via AST inspection.
- **Excluded Statements**: `CONSTANTS`, `STATICS`, and `TYPES` statements do not count towards the local declaration limit unless they contain inline declarations.
- **Reporting**: When the total count exceeds `MAX_LOCALS` (default `15`), finding `MAX_LOCALS` is reported on the opening procedure statement.

## Suppression

Suppress the finding with the pseudo-comment `"#EC MAX_LOCALS` on the opening `METHOD` statement.


## Related Rules

* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Limit Class Member Attribute Count to Prevent God Objects](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_LOCALS`
* **ABAP Implementation:** [/skyl/cl_max_locals.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_locals.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4447)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4447)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_LOCALS&title=%5BBug%5D%3A%20Issue%20in%20max-locals)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-locals)**
