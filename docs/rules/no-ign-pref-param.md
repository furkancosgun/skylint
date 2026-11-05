---
title: "Report Ignored PREFERRED PARAMETER When Non-Optional Parameters Exist"
description: "Detect ignored PREFERRED PARAMETER clauses in ABAP methods when mandatory parameters are present."
keywords: "no-ign-pref-param, PREFERRED PARAMETER, ABAP method parameters, optional parameters"
category: "clean-abap"
ruleId: "no-ign-pref-param"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5989"
---

# Report Ignored PREFERRED PARAMETER When Non-Optional Parameters Exist

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_IGN_PREF_PARAM" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5989" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Report ignored PREFERRED PARAMETER addition.

> **ATC Finding Message:** `PREFERRED PARAMETER is ignored when mandatory parameters exist`

## Rationale

In ABAP methods, PREFERRED PARAMETER specifies the default importing parameter for positional calls. However, according to SAP ABAP rules, PREFERRED PARAMETER is ignored if there are any mandatory (non-optional) importing parameters in the signature. Such declarations mislead developers into assuming positional calls will work when in fact they are invalid or ignored.

### Non-Compliant

```abap
METHODS get_data
  IMPORTING
    iv_req TYPE i
    iv_opt TYPE i OPTIONAL
  PREFERRED PARAMETER iv_req.
```

### Compliant

```abap
METHODS get_data
  IMPORTING
    iv_req TYPE i
    iv_opt TYPE i OPTIONAL.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IGN_PREF_PARAM

" SAP CI_ prefix format:
... "#EC CI_NO_IGN_PREF_PARAM
```


## Related Rules

* [Declare OPTIONAL and DEFAULT Parameters Last](/rules/pref-opt-last) — <code>#EC PREF_OPTIONAL_LAST</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IGN_PREF_PARAM`
* **ABAP Implementation:** [/skyl/cl_no_ign_pref_param.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ign_pref_param.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5989)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5989)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IGN_PREF_PARAM&title=%5BBug%5D%3A%20Issue%20in%20no-ign-pref-param)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ign-pref-param)**
