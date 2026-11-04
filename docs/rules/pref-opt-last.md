---
title: "Declare Optional and Default Parameters Last in Methods"
description: "Improve method readability in ABAP by placing optional and default parameters after mandatory parameters."
keywords: "Clean ABAP Parameters, OPTIONAL Parameter Order, DEFAULT Parameter, Method Signature Hygiene"
category: "clean-abap"
ruleId: "pref-opt-last"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5688"
---

# Declare Optional and Default Parameters Last in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_OPTIONAL_LAST" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5688" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Declare optional and default parameters last in methods.

> **ATC Finding Message:** `Declare mandatory parameters before OPTIONAL and DEFAULT parameters`

## Rationale

In Clean ABAP, mandatory parameters must appear before optional (`OPTIONAL`) and default (`DEFAULT`) parameters in method signatures. Mixing optional and required parameters makes caller invocation confusing and error-prone.

**Standard:** Place required parameters first, followed by optional parameters at the end of the parameter list.

### Non-Compliant

```abap
METHODS process_data
  IMPORTING
    iv_opt TYPE i OPTIONAL
    iv_req TYPE i.
```

### Compliant

```abap
METHODS process_data
  IMPORTING
    iv_req TYPE i
    iv_opt TYPE i OPTIONAL.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_OPTIONAL_LAST

" SAP CI_ prefix format:
... "#EC CI_PREF_OPTIONAL_LAST
```


## Related Rules

* [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Single Parameter or Field Per Line](/rules/pref-param-1line) — <code>#EC PREF_PARAM_1LINE</code>
* [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_OPT_LAST`
* **ABAP Implementation:** [/skyl/cl_pref_opt_last.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_opt_last.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5688)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5688)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_OPT_LAST&title=%5BBug%5D%3A%20Issue%20in%20pref-opt-last)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-opt-last)**
