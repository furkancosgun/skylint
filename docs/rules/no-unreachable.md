---
title: "Avoid Dead / Unreachable Code"
description: "Avoid Dead / Unreachable Code - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-unreachable, anti-patterns"
category: "anti-patterns"
ruleId: "no-unreachable"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L920"
---

# Avoid Dead / Unreachable Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNREACHABLE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L920" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect unreachable code after jump or exit statements.

> **ATC Finding Message:** `Statement is unreachable`

## Rationale

Statements after an unconditional RETURN, RAISE EXCEPTION, or EXIT can never execute and often remain from debugging or an earlier design. They mislead maintainers and inflate apparent method size and coverage. Remove the statements or move them before the terminating statement if they are still needed.

### Non-Compliant

```abap
RETURN.
lv_count = lv_count + 1.
```

### Compliant

```abap
lv_count = lv_count + 1.
RETURN.
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
... "#EC NO_UNREACHABLE

" SAP CI_ prefix format:
... "#EC CI_NO_UNREACHABLE
```


## Related Rules

* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Magic Numbers; Use Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNREACHABLE`
* **ABAP Implementation:** [/skyl/cl_no_unreachable.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unreachable.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 920)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L920)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNREACHABLE&title=%5BBug%5D%3A%20Issue%20in%20no-unreachable)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unreachable)**
