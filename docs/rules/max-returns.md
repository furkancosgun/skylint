---
title: "Limit Multiple Return Statements per Method Body"
description: "Balance guard clauses with predictable method exits in ABAP. Prevent scattered return statements across large procedures."
keywords: "Multiple return statements ABAP, Guard Clauses vs Single Exit, Clean ABAP Control Flow, ATC Metrics"
category: "metrics"
ruleId: "max-returns"
---

# Limit Multiple Return Statements per Method Body

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_RETURNS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Limit number of RETURN statements (PLR0911).

> **ATC Finding Message:** `Method has too many RETURN statements; consider refactoring`

## Rationale

While early return guard clauses at the top of a method are encouraged by Clean ABAP, scattering a dozen `RETURN` or `EXIT` statements throughout the middle and end of a long procedure makes control flow unpredictable. It becomes difficult to ensure that cleanup logic or post-conditions are reliably reached.

**Clean ABAP Guideline:** Use early returns strictly for parameter and state validation guards at the entry point of the method. Keep the core execution flow to a single, predictable exit point.

### Non-Compliant

```abap
" Anti-pattern: 8 scattered return points throughout 100 lines of logic
METHOD calculate_tax.
  ...
  IF condition_a. RETURN. ENDIF.
  ...
  IF condition_b. RETURN. ENDIF.
  ...
  IF condition_c. RETURN. ENDIF.
  ...
ENDMETHOD.
```

### Compliant

```abap
" Clean ABAP: Grouped guard clauses at top, single deterministic computation exit
METHOD calculate_tax.
  IF is_tax_exempt( is_customer ).
    rv_tax = 0.
    RETURN.
  ENDIF.

  rv_tax = compute_standard_rate( is_customer ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_RETURNS` | `Integer` | <code>6</code> | Maximum allowed total return points (RETURN, EXIT) within a single method |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_RETURNS

" SAP CI_ prefix format:
... "#EC CI_MAX_RETURNS
```


## Related Rules

* [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit One Statement per Source Code Line (No Inline Colon Chains)](/rules/max-one-stmt) — <code>#EC MAX_ONE_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_RETURNS`
* **Implementation File:** [#skyl#cl_max_returns.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_returns.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_RETURNS&title=%5BBug%5D%3A%20Issue%20in%20max-returns)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-returns)**
