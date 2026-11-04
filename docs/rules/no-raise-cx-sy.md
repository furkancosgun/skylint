---
title: "Avoid Raising System Exceptions Directly (cx_sy_*)"
description: "Maintain clean error boundaries in SAP ABAP by creating domain-specific exceptions instead of raising internal CX_SY_* system exceptions."
keywords: "no-raise-cx-sy, CX_SY_*, custom exceptions, Clean ABAP, ABAP error handling"
category: "security"
ruleId: "no-raise-cx-sy"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2422"
---

# Avoid Raising System Exceptions Directly (cx_sy_*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAISE_CX_SY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2422" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid raising SAP internal system exceptions (cx_sy_*).

> **ATC Finding Message:** `Avoid raising SAP internal system exceptions; use application exceptions`

## Rationale

Classes in the CX_SY_* namespace (such as CX_SY_ZERODIVIDE, CX_SY_ITAB_LINE_NOT_FOUND, or CX_SY_REF_IS_INITIAL) are reserved for and raised exclusively by the SAP ABAP runtime kernel. Raising system exceptions manually in business application logic confuses callers, pollutes system logs, and obscures whether an error originated from a kernel runtime defect or from a business validation check. Application programs must define dedicated custom exception classes inheriting from CX_STATIC_CHECK, CX_DYNAMIC_CHECK, or CX_NO_CHECK that clearly articulate domain failure reasons.

### Non-Compliant

```abap
DATA lv_discount_percentage TYPE i VALUE 150.
IF lv_discount_percentage > 100.
  " Anti-pattern: Raising kernel exception for business validation failure
  RAISE EXCEPTION TYPE cx_sy_zerodivide.
ENDIF.
```

### Compliant

```abap
DATA lv_discount_percentage TYPE i VALUE 150.
IF lv_discount_percentage > 100.
  RAISE EXCEPTION NEW cx_static_check( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAISE_CX_SY

" SAP CI_ prefix format:
... "#EC CI_NO_RAISE_CX_SY
```

### Scope and Detection

The rule monitors `RAISE EXCEPTION` statements where the target exception class type reference matches the pattern `\TY:CX_SY_*`.

- **Finding Code:** `NO_RAIS_SY`
- **Pseudo-Comment:** `"#EC NO_RAISE_CX_SY`

Always define a domain exception class (e.g., `ZCX_PURCHASE_ORDER_INVALID`) that encapsulates relevant business error messages, parameters, and symptom descriptions rather than re-using runtime kernel exceptions.


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Explicit RAISE SHORTDUMP in Application Logic](/rules/no-raise-shortdump) — <code>#EC NO_RAISE_SHORTDUMP</code>
* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAISE_CX_SY`
* **ABAP Implementation:** [/skyl/cl_no_raise_cx_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raise_cx_sy.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2422)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2422)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RAISE_CX_SY&title=%5BBug%5D%3A%20Issue%20in%20no-raise-cx-sy)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-raise-cx-sy)**
