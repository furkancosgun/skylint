---
title: "Enforce Configured Naming Conventions for Local Variables and Field-Symbols"
description: "Enforce standard naming conventions for ABAP local variables, constants, and field-symbols using configurable regex checks in SAP ATC."
keywords: "pref-naming-vars, naming conventions, local variables, field-symbols, Clean ABAP"
category: "clean-abap"
ruleId: "pref-naming-vars"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3455"
---

# Enforce Configured Naming Conventions for Local Variables and Field-Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAMING_VARS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3455" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Local Variable and Field-Symbol Naming Conventions.

> **ATC Finding Message:** `Local variable or field-symbol name does not match configured pattern`

## Rationale

Consistent variable prefixes (such as `lv_` for local variables, `lc_` for constants, `<ls_>` or `<lv_>` for field-symbols, and `sv_` for static variables) provide clear scope boundaries, clarify data types, and prevent accidental shadowing of member attributes or global structures. Adhering to predictable naming rules speeds up code reviews and improves maintainability across teams. Skylint validates all local declarations and inline declarations against configurable regex patterns, reporting PREF_NAMVR upon violation.

### Non-Compliant

```abap
DATA customer_account TYPE string.
FIELD-SYMBOLS <billing_item> TYPE any.
```

### Compliant

```abap
DATA lv_customer_account TYPE string.
FIELD-SYMBOLS <ls_billing_item> TYPE any.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `LOCAL_DATA` | `String` | <code>^L._.+$</code> | Regex pattern for local variable declarations (DATA and inline DATA), defaulting to `^L._.+$`. |
| `LOCAL_CONST` | `String` | <code>^LC_.+$</code> | Regex pattern for local constant declarations, defaulting to `^LC_.+$`. |
| `LOCAL_FS` | `String` | <code>^&lt;L._.+&gt;$</code> | Regex pattern for local field-symbols (FIELD-SYMBOLS and inline FIELD-SYMBOL), defaulting to `^<L._.+>$`. |
| `LOCAL_STATICS` | `String` | <code>^S._.+$</code> | Regex pattern for local static variable declarations (STATICS), defaulting to `^S._.+$`. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NAMING_VARS

" SAP CI_ prefix format:
... "#EC CI_PREF_NAMING_VARS
```

## Configured Regex Patterns

Declarations in procedure bodies are validated against the following default regex rules:

| Construct | Configuration Key | Default Pattern | Example Match |
|---|---|---|---|
| Local Variable | `LOCAL_DATA` | `^L._.+$` | `lv_amount`, `lt_items`, `ls_header` |
| Local Constant | `LOCAL_CONST` | `^LC_.+$` | `lc_vat_rate`, `lc_max_retries` |
| Field Symbol | `LOCAL_FS` | `^<L._.+>$` | `<ls_item>`, `<lv_value>` |
| Local Static | `LOCAL_STATICS` | `^S._.+$` | `sv_counter`, `st_cache` |

Both explicit statements (`DATA`, `STATICS`, `CONSTANTS`, `FIELD-SYMBOLS`) and inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`) are verified.

Suppress individual findings with `"#EC PREF_NAMING_VARS` or `##PREF_NAMING_VARS`.


## Related Rules

* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_NAMING_VARS`
* **ABAP Implementation:** [/skyl/cl_pref_naming_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_naming_vars.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3455)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3455)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_NAMING_VARS&title=%5BBug%5D%3A%20Issue%20in%20pref-naming-vars)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-naming-vars)**
