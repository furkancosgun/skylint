---
title: "Declare Constants with an Explicit TYPE and LENGTH"
description: "Require explicit TYPE and LENGTH on CONSTANTS declarations so literal-inferred types cannot silently truncate values in ABAP Cloud."
keywords: "pref-full-typed, fully typed constants, CONSTANTS TYPE, Clean ABAP, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-full-typed"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1666"
---

# Declare Constants with an Explicit TYPE and LENGTH

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_FULL_TYPED" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1666" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Enforce fully typed constant declarations.

> **ATC Finding Message:** `Constant declaration should explicitly specify TYPE`

## Rationale

A CONSTANTS statement without TYPE derives its type from the literal, so 'CARD' silently becomes a four-character c field and 42 becomes an integer whose range nobody declared. A later change to the literal then alters the constant's type, its comparisons, and every interface that consumes it. Adding TYPE (and LENGTH where relevant) documents the contract, lets the compiler check it, and makes the ADD_TYPE QuickFix deterministic because the type is inferred from the literal.

### Non-Compliant

```abap
CONSTANTS c_payment_method VALUE 'CARD'.
```

### Compliant

```abap
CONSTANTS c_payment_method TYPE string VALUE 'CARD'.
CONSTANTS c_max_retry_count  TYPE i      VALUE 3.
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
... "#EC PREF_FULL_TYPED

" SAP CI_ prefix format:
... "#EC CI_PREF_FULL_TYPED
```

### Scope and inferred types

- Only `CONSTANTS` statements that use `VALUE` are inspected; constants already declared with `TYPE`/`LIKE` or as `BEGIN OF ... END OF` structures are ignored.
- The `ADD_TYPE` QuickFix infers `string` for quoted literals, `i` for integer literals and `abap_bool` for `ABAP_TRUE` / `ABAP_FALSE`. Other literal forms still get the `PREF_TYPED` finding, just without a QuickFix.
- Local `DATA` declarations are intentionally out of scope here: this check guards the published constant contract, not local variable typing.


## Related Rules

* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Avoid Hungarian Notation and Legacy Type Prefixes in Names](/rules/no-hungarian) — <code>#EC NO_HUNGARIAN</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_FULL_TYPED`
* **ABAP Implementation:** [/skyl/cl_pref_full_typed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_full_typed.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1666)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1666)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_FULL_TYPED&title=%5BBug%5D%3A%20Issue%20in%20pref-full-typed)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-full-typed)**
