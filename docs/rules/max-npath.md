---
title: "Limit NPath Execution Path Complexity per Method"
description: "Limit NPath path complexity in ABAP procedures to prevent combinatorial branch explosion and guarantee unit test coverage."
keywords: "max-npath, NPath complexity, acyclic paths, Clean ABAP, SAP ATC"
category: "metrics"
ruleId: "max-npath"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2068"
---

# Limit NPath Execution Path Complexity per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_NPATH" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2068" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit NPath complexity per procedure.

> **ATC Finding Message:** `Procedure NPath complexity exceeds threshold`

## Rationale

NPath complexity quantifies the total number of acyclic execution paths through a procedure. While cyclomatic complexity increases additively with each decision point, NPath complexity grows multiplicatively across consecutive and nested conditional statements. A method with an NPath score in the hundreds or thousands represents an untestable combinatorial explosion where full branch path testing in ABAP Unit is practically impossible. Keeping NPath complexity low ensures that all business paths are predictable, auditable, and fully exercisable in automated test suites.

### Non-Compliant

```abap
METHOD evaluate_customer_profile.
  IF is_customer_profile-is_email_verified = abap_true.
    enable_email_notifications( ).
  ENDIF.
  IF is_customer_profile-is_phone_verified = abap_true.
    enable_sms_alerts( ).
  ENDIF.
  IF is_customer_profile-is_corporate_account = abap_true.
    assign_business_tier( ).
  ENDIF.
  IF is_customer_profile-has_tax_exemption = abap_true.
    apply_tax_exemption_certificate( ).
  ENDIF.
  IF is_customer_profile-has_credit_limit = abap_true.
    validate_revolving_credit( ).
  ENDIF.
  IF is_customer_profile-is_newsletter_subscriber = abap_true.
    enroll_marketing_campaign( ).
  ENDIF.
  IF is_customer_profile-is_premium_member = abap_true.
    grant_loyalty_reward_points( ).
  ENDIF.
  IF is_customer_profile-requires_two_factor_auth = abap_true.
    enforce_security_challenge( ).
  ENDIF.
ENDMETHOD.
```

### Compliant

```abap
METHOD evaluate_customer_profile.
  configure_contact_channels( is_customer_profile ).
  configure_commercial_terms( is_customer_profile ).
  configure_security_policy( is_customer_profile ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_NPATH` | `Integer` | <code>200</code> | Maximum allowed acyclic execution paths per procedure before reporting combinatorial explosion (default: 200). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_NPATH

" SAP CI_ prefix format:
... "#EC CI_MAX_NPATH
```

## NPath Multiplicative Formula

NPath evaluates control structures by calculating branch sums and multiplying sequential blocks:

- **IF / ELSEIF / ELSE:** The sum of paths in each branch. If `ELSE` is absent, an implicit empty branch (+1) is included.
- **CASE / WHEN / ENDCASE:** The sum of paths across all `WHEN` blocks. If `WHEN OTHERS` is missing, an extra path (+1) is added.
- **LOOP / WHILE / DO:** Path count within the body + 1 + any boolean operators.
- **TRY / CATCH / CLEANUP:** Sum of paths across guarded and recovery blocks.

| Finding Code | Severity | Trigger | Suppression |
|---|---|---|---|
| `MAX_NPATH` | Warning | Procedure NPath score exceeds `MAX_NPATH` (default 200) | `##MAX_NPATH` or `"#EC MAX_NPATH` |


## Related Rules

* [Limit McCabe Cyclomatic Complexity per Procedure](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>
* [Enforce Cognitive Complexity Thresholds per Procedure](/rules/max-cognitive) — <code>#EC MAX_COGNITIVE</code>
* [Limit Control Flow Block Nesting Depth](/rules/max-nesting) — <code>#EC MAX_NESTING</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_NPATH`
* **ABAP Implementation:** [/skyl/cl_max_npath.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_npath.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2068)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2068)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_NPATH&title=%5BBug%5D%3A%20Issue%20in%20max-npath)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-npath)**
