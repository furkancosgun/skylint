---
title: "Avoid Dead Code with Constant Conditions"
description: "Avoid Dead Code with Constant Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-dead-code, anti-patterns"
category: "anti-patterns"
ruleId: "no-dead-code"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3524"
---

# Avoid Dead Code with Constant Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DEAD_CODE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3524" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect Dead Code with Constant Condition.

> **ATC Finding Message:** `Condition is always false, creating dead code`

## Rationale

A condition that is always false, such as 1 = 2 or abap_false, makes the branch impossible to reach. Dead branches hide unfinished logic and can contain declarations that confuse scope analysis. Remove the branch or replace the constant with the real runtime condition.

### Non-Compliant

```abap
IF 1 = 2.
  process( ).
ENDIF.
```

### Compliant

```abap
IF is_enabled( ).
  process( ).
ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DEAD_CODE

" SAP CI_ prefix format:
... "#EC CI_NO_DEAD_CODE
```


## Related Rules

* [Avoid Dead / Unreachable Code](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>
* [Avoid Magic Numbers; Use Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEAD_CODE`
* **ABAP Implementation:** [/skyl/cl_no_dead_code.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dead_code.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3524)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3524)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEAD_CODE&title=%5BBug%5D%3A%20Issue%20in%20no-dead-code)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dead-code)**
