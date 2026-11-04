---
title: "Replace Obsolete IS REQUESTED with Modern IS SUPPLIED Predicate"
description: "Replace obsolete IS REQUESTED predicates with modern IS SUPPLIED across method parameter checks in ABAP Cloud."
keywords: "pref-is-supplied, IS SUPPLIED, IS REQUESTED, parameter validation, Clean ABAP"
category: "clean-abap"
ruleId: "pref-is-supplied"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3721"
---

# Replace Obsolete IS REQUESTED with Modern IS SUPPLIED Predicate

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_SUPPLIED" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3721" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer IS SUPPLIED over the obsolete IS REQUESTED.

> **ATC Finding Message:** `Use IS SUPPLIED instead of IS REQUESTED`

## Rationale

The predicate IS REQUESTED is an obsolete language construct that only checks whether an output parameter was requested by a caller, whereas IS SUPPLIED is a universal predicate verifying whether any importing, exporting, changing, or returning parameter was passed at invocation. Using IS SUPPLIED ensures consistent parameter interrogation across all parameter kinds and aligns with ABAP Cloud syntax rules. Skylint detects IS REQUESTED and IS NOT REQUESTED, raising PREF_ISSUP with the USE_SUPPLD quickfix.

### Non-Compliant

```abap
IF iv_discount_percent IS REQUESTED.
  apply_discount( iv_discount_percent ).
ENDIF.
```

### Compliant

```abap
IF iv_discount_percent IS SUPPLIED.
  apply_discount( iv_discount_percent ).
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
... "#EC PREF_IS_SUPPLIED

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_SUPPLIED
```

## Detection and Quickfix Details

The check examines control conditions for occurrences of `IS REQUESTED` and `IS NOT REQUESTED`. The `USE_SUPPLD` quickfix replaces the token `REQUESTED` with `SUPPLIED` in-place while keeping negation and condition formatting intact.

Suppress findings using pseudo comment `"#EC PREF_IS_SUPPLIED`.


## Related Rules

* [Use RETURNING Instead of a Single EXPORTING Parameter](/rules/pref-returning) — <code>#EC PREF_RETURNING</code>
* [Omit or Require Parameter Names in Method Calls](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Use RETURN Instead of EXIT Outside Loops](/rules/pref-return) — <code>#EC PREF_RETURN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_IS_SUPPLIED`
* **ABAP Implementation:** [/skyl/cl_pref_is_supplied.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_is_supplied.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3721)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3721)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_IS_SUPPLIED&title=%5BBug%5D%3A%20Issue%20in%20pref-is-supplied)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-is-supplied)**
