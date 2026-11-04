---
title: "Avoid Magic Numbers; Use Named Constants"
description: "Avoid Magic Numbers; Use Named Constants - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-magic-numbers, anti-patterns"
category: "anti-patterns"
ruleId: "no-magic-numbers"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2100"
---

# Avoid Magic Numbers; Use Named Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MAGIC_NUMBERS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2100" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid magic numbers in code; use named constants.

> **ATC Finding Message:** `Avoid hardcoded magic numbers; declare a named constant`

## Rationale

A numeric literal in logic does not explain what it represents, and the same value repeated in several places must be changed consistently. Named constants turn business rules into readable intent and give the value a single source of truth. Declare typed constants and reuse them instead of scattering numbers through the code.

### Non-Compliant

```abap
IF lv_retry_count >= 3.
  process( ).
ENDIF.
```

### Compliant

```abap
CONSTANTS c_max_retries TYPE i VALUE 3.
IF lv_retry_count >= c_max_retries.
  process( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MAGIC_NUMBERS

" SAP CI_ prefix format:
... "#EC CI_NO_MAGIC_NUMBERS
```


## Related Rules

* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Dead / Unreachable Code](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MAGIC_NUMBERS`
* **ABAP Implementation:** [/skyl/cl_no_magic_numbers.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_magic_numbers.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2100)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2100)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MAGIC_NUMBERS&title=%5BBug%5D%3A%20Issue%20in%20no-magic-numbers)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-magic-numbers)**
