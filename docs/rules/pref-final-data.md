---
title: "Declare Single-Assignment Local Variables with FINAL( )"
description: "Enforce immutable local declarations in ABAP Cloud by replacing single-assignment DATA inline statements with FINAL to improve readability and safety."
keywords: "pref-final-data, FINAL(), inline declaration, Clean ABAP, immutability"
category: "clean-abap"
ruleId: "pref-final-data"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2842"
---

# Declare Single-Assignment Local Variables with FINAL( )

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FINAL_DATA" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2842" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Declare inline variables as FINAL when never written again.

> **ATC Finding Message:** `Inline variable is never written again; declare it with FINAL( )`

## Rationale

Declaring inline variables with FINAL( ) ensures immutability across the remainder of the method body, preventing accidental reassignment and lowering cognitive load during maintenance. When the ABAP compiler enforces single-assignment semantics, readers immediately recognize that the variable represents a constant calculation or fixed object reference. The check inspects procedure statements, verifies via ATC compiler references that no write usage occurs after initial definition, and reports PREF_FNDAT with the TOFINAL quickfix.

### Non-Compliant

```abap
DATA(lv_discount_rate) = calculate_discount( iv_customer_tier = 'GOLD' ).
apply_discount( lv_discount_rate ).
```

### Compliant

```abap
FINAL(lv_discount_rate) = calculate_discount( iv_customer_tier = 'GOLD' ).
apply_discount( lv_discount_rate ).
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
... "#EC PREF_FINAL_DATA

" SAP CI_ prefix format:
... "#EC CI_PREF_FINAL_DATA
```

## Detection and Quickfix Details

The check scans procedure statements for inline `DATA(var)` declarations. Using compiler reference tracking (`usage_modes-write`), it verifies whether `var` is subsequently modified anywhere in the procedure. If no write references exist, ATC finding `PREF_FNDAT` is reported. The `TOFINAL` quickfix automatically substitutes `DATA(` with `FINAL(` while preserving surrounding expressions.

Suppress individual findings using the pseudo comment `"#EC PREF_FINAL_DATA`.


## Related Rules

* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Single-Letter Identifiers in Declarations](/rules/no-single-letter) — <code>#EC NO_SINGLE_LETTER</code>
* [Avoid Chained Declarations for Variables, Types, and Constants](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_FINAL_DATA`
* **ABAP Implementation:** [/skyl/cl_pref_final_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_final_data.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2842)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2842)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_FINAL_DATA&title=%5BBug%5D%3A%20Issue%20in%20pref-final-data)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-final-data)**
