---
title: "Unsafe COND or SWITCH Inferred Type Truncates Values"
description: "Report COND and SWITCH expressions with inferred types that cause silent character truncation."
keywords: "no-cond-trunc, COND #( ), SWITCH #( ), ABAP string truncation, inferred type truncation"
category: "anti-patterns"
ruleId: "no-cond-trunc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6064"
---

# Unsafe COND or SWITCH Inferred Type Truncates Values

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_COND_TRUNC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6064" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Unsafe COND or SWITCH inferred type truncates values.

> **ATC Finding Message:** `COND/SWITCH #( ) infers short C type and truncates longer branches`

## Rationale

When using COND #( ... ) or SWITCH #( ... ) with string literals, ABAP derives the result type from the first THEN branch operand. If the first operand is a short text literal (e.g. 'OK' with type C LENGTH 2), subsequent longer branch values (such as 'PENDING') are silently truncated to match the first length. Specify the target type explicitly, e.g. COND string( ... ), or ensure the type accommodates all branches.

### Non-Compliant

```abap
DATA(lv_status) = COND #( WHEN lv_ok = abap_true THEN 'OK' ELSE 'PROCESSING' ).
```

### Compliant

```abap
DATA(lv_status) = COND string( WHEN lv_ok = abap_true THEN 'OK' ELSE 'PROCESSING' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_COND_TRUNC

" SAP CI_ prefix format:
... "#EC CI_NO_COND_TRUNC
```


## Related Rules

* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_COND_TRUNC`
* **ABAP Implementation:** [/skyl/cl_no_cond_trunc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_cond_trunc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 6064)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L6064)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_COND_TRUNC&title=%5BBug%5D%3A%20Issue%20in%20no-cond-trunc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-cond-trunc)**
