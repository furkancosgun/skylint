---
title: "Fold Adjacent Static String Literals Concatenated with &&"
description: "Fold adjacent string literals concatenated with && into a single literal in ABAP Cloud."
keywords: "no-useless-concat, string concatenation, literal folding, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-useless-concat"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1638"
---

# Fold Adjacent Static String Literals Concatenated with &&

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="info" text="Note" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_USELESS_CONCAT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1638" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid concatenating string literals.

> **ATC Finding Message:** `Fold literal string concatenation into one literal`

## Rationale

Concatenating multiple static character or string literals with the chaining operator && (such as 'api/v1/' && 'orders') computes at runtime a value that is fully known at design time. Pointless literal concatenation adds runtime overhead, fragments text into confusing segments, and increases cognitive load during code reviews. Clean ABAP rules recommend combining adjacent static literals into a single string literal, reserving the && operator strictly for dynamic expressions, variables, and string functions.

### Non-Compliant

```abap
lv_endpoint_url = 'https://api.gateway.internal' && '/v1/orders/' && 'status'.
```

### Compliant

```abap
lv_endpoint_url = 'https://api.gateway.internal/v1/orders/status'.
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
... "#EC NO_USELESS_CONCAT

" SAP CI_ prefix format:
... "#EC CI_NO_USELESS_CONCAT
```

### Literal Folding Mechanics

The `FOLDLIT` QuickFix combines consecutive static literals into a single folded literal:

- Text field literals (`'...'`) under 250 characters are combined into a single-quoted literal.
- Text string literals (``` `...` ```) or strings exceeding 250 characters are combined into a backtick text string literal.
- String templates without embedded expressions (`|...|`) are recognized as static literals.

Suppress findings with `"#EC NO_USELESS_CONCAT`.


## Related Rules

* [Replace Obsolete String Statements and POSIX Regular Expressions](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Extract Repeated String Literals into Named Constants](/rules/no-dup-literals) — <code>#EC NO_DUP_LITERALS</code>
* [Compose Messages with String Templates Instead of CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_USELESS_CONCAT`
* **ABAP Implementation:** [/skyl/cl_no_useless_concat.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_useless_concat.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1638)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1638)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_USELESS_CONCAT&title=%5BBug%5D%3A%20Issue%20in%20no-useless-concat)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-useless-concat)**
