---
title: "Limit Method and Constructor Statement Length"
description: "Limit method and constructor statement counts in ABAP Cloud to enforce single responsibility and simplify unit testing."
keywords: "max-method-len, Clean ABAP, method length, Single Responsibility, SAP ATC"
category: "metrics"
ruleId: "max-method-len"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1722"
---

# Limit Method and Constructor Statement Length

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_METHOD_LEN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1722" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Method and Constructor Length Limits.

> **ATC Finding Messages:**
> - `Method length exceeds maximum allowed statement limit`
> - `Avoid heavy business logic/loops in constructor; use injection only`

## Rationale

Procedures containing excessive statements violate the Single Responsibility Principle (SRP) by mixing multiple levels of abstraction—such as database reads, domain validations, currency calculations, and log persistence—into an unmaintainable monolithic unit. In ABAP Cloud, long methods degrade testability by requiring elaborate test setups with high mock surface areas. Constructors are particularly critical: placing complex business logic or loops in constructors prevents effective dependency injection and automated unit isolation. Restricting method lengths forces decomposition into focused, single-purpose helper methods and domain services.

### Non-Compliant

```abap
METHOD process_sales_order.
  DATA lv_tax_amount TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_net_amount TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_gross_amount TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_item_count TYPE i.
  DATA lv_is_valid TYPE abap_bool.

  lv_is_valid = validate_header( is_order_header ).
  IF lv_is_valid = abap_false.
    RAISE EXCEPTION NEW cx_bad_argument( ).
  ENDIF.

  lv_net_amount = calculate_net_total( it_order_items ).
  lv_tax_amount = calculate_vat( lv_net_amount ).
  lv_gross_amount = lv_net_amount + lv_tax_amount.
  lv_item_count = lines( it_order_items ).

  persist_sales_order( is_header = is_order_header
                       iv_gross  = lv_gross_amount ).
  update_inventory_allocation( it_order_items ).
  enqueue_billing_job( is_order_header-order_id ).
  dispatch_order_confirmation( is_order_header-order_id ).
  log_order_success( is_order_header-order_id ).
ENDMETHOD.
```

### Compliant

```abap
METHOD process_sales_order.
  validate_header( is_order_header ).
  DATA(ls_pricing) = mo_pricing_engine->calculate_totals( it_order_items ).
  mo_order_repository->save_order( is_header  = is_order_header
                                   is_pricing = ls_pricing ).
  mo_order_notifier->dispatch_confirmation( is_order_header-order_id ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_STATEMENTS` | `Integer` | <code>5</code> | Maximum number of executable ABAP statements allowed in regular method bodies (default: 5). |
| `MAX_CTOR_STATEMENTS` | `Integer` | <code>10</code> | Maximum number of executable ABAP statements allowed in instance CONSTRUCTOR methods to discourage complex initialization (default: 10). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_METHOD_LEN

" SAP CI_ prefix format:
... "#EC CI_MAX_METHOD_LEN
```

## Detection Details

The check evaluates the count of statements within procedure bodies (excluding the opening `METHOD` and closing `ENDMETHOD` statements).

| Finding Code | Target | Default Threshold | Suppression |
|---|---|---|---|
| `MAX_METH_L` | Regular methods | `MAX_STATEMENTS` (5 statements) | `##MAX_METHOD_LEN` or `"#EC MAX_METHOD_LEN` |
| `MAX_CTOR` | `CONSTRUCTOR` methods | `MAX_CTOR_STATEMENTS` (10 statements) | `##MAX_CTOR_LOGIC` or `"#EC MAX_CTOR_LOGIC` |

### Recommendation
Keep methods between 3 and 20 statements. Constructors should strictly assign injected dependencies and initialize private attributes; heavy orchestration, database queries, and iterative loops must be moved to factory methods or dedicated initialization routines.


## Related Rules

* [Limit Source Code Line Length to Avoid Horizontal Scrolling](/rules/max-line-len) — <code>#EC MAX_LINE_LEN</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Limit Number of Return Statements per Procedure](/rules/max-returns) — <code>#EC MAX_RETURNS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_METHOD_LEN`
* **ABAP Implementation:** [/skyl/cl_max_method_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_method_len.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1722)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1722)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_METHOD_LEN&title=%5BBug%5D%3A%20Issue%20in%20max-method-len)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-method-len)**
