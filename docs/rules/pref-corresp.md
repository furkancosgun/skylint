---
title: "Replace MOVE-CORRESPONDING with CORRESPONDING #( )"
description: "Replace MOVE-CORRESPONDING with the CORRESPONDING #( ) constructor expression and control field mapping with MAPPING, EXCEPT or DISCARDING."
keywords: "pref-corresp, MOVE-CORRESPONDING, CORRESPONDING operator, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-corresp"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1694"
---

# Replace MOVE-CORRESPONDING with CORRESPONDING #( )

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CORRESP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1694" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer CORRESPONDING Expression over MOVE-CORRESPONDING.

> **ATC Finding Message:** `Prefer functional CORRESPONDING #( ... ) over MOVE-CORRESPONDING`

## Rationale

MOVE-CORRESPONDING is a statement, so it cannot be used inside an expression and it hides which fields are actually copied. The CORRESPONDING #( ) constructor expression is expression-capable and accepts MAPPING, EXCEPT and DISCARDING to make the field mapping explicit and reviewable. It also combines with inline declarations and BASE ( ... ), which keeps source and target structure visible in one line instead of a hidden implicit copy.

### Non-Compliant

```abap
MOVE-CORRESPONDING ls_business_partner_api TO ls_business_partner_db.
```

### Compliant

```abap
ls_business_partner_db = CORRESPONDING #( ls_business_partner_api ).
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
... "#EC PREF_CORRESP

" SAP CI_ prefix format:
... "#EC CI_PREF_CORRESP
```

### Controlled mappings

`CORRESPONDING #( )` covers everything the statement does, plus explicit control over the copy:

```abap
ls_business_partner_db = CORRESPONDING #( ls_business_partner_api
                                          MAPPING street_name = street
                                          EXCEPT last_changed_at ).
```

The check skips `MOVE-CORRESPONDING ... EXPANDING` and `... KEEPING`, because those additions change the target structure and have no one-to-one expression equivalent. The `CORRESP` QuickFix is produced only for the plain `MOVE-CORRESPONDING source TO target.` form; suppress other findings with `"#EC PREF_CORRESP`.


## Related Rules

* [Enforce Routine Declaration Hierarchy and Top-of-Block Placement](/rules/pref-declarations) — <code>#EC DEF_TOP</code>
* [Prefer Inline Declarations over Separate DATA and Assignment](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CORRESP`
* **ABAP Implementation:** [/skyl/cl_pref_corresp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_corresp.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1694)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1694)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CORRESP&title=%5BBug%5D%3A%20Issue%20in%20pref-corresp)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-corresp)**
