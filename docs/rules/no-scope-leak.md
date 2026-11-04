---
title: "Prevent Variable Scope Leakage Outside Control Blocks"
description: "Prevent variable scope leaking where variables declared inside control blocks are used outside in ABAP Cloud."
keywords: "no-scope-leak, variable scoping, inline declaration, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-scope-leak"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1553"
---

# Prevent Variable Scope Leakage Outside Control Blocks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SCOPE_LEAK" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1553" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid variable usage outside its declaring control block.

> **ATC Finding Message:** `Variable declared in inner block is referenced outside its scope`

## Rationale

Unlike languages with block-level lexical scoping, ABAP variables declared inside an IF, LOOP, or TRY block remain visible throughout the remainder of the procedure. Referencing a variable outside the block in which it was declared creates an implicit temporal coupling on whether that specific branch executed, frequently causing uninitialized data defects or race conditions. Clean ABAP rules mandate declaring variables in the outer enclosing scope and assigning them explicitly inside inner control blocks.

### Non-Compliant

```abap
IF lv_is_verified = abap_true.
  DATA(lv_token_value) = get_authorization_token( ).
ENDIF.
transmit_payload( lv_token_value ).
```

### Compliant

```abap
DATA lv_token_value TYPE string.
IF lv_is_verified = abap_true.
  lv_token_value = get_authorization_token( ).
ENDIF.
transmit_payload( lv_token_value ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SCOPE_LEAK

" SAP CI_ prefix format:
... "#EC CI_NO_SCOPE_LEAK
```

### Block Stack Analysis

The check tracks nesting depth across all major control structures:

- Blocks tracked: `IF`, `LOOP`, `DO`, `WHILE`, `CASE`, and `TRY` (including branch statements `ELSE`, `ELSEIF`, `WHEN`, `CATCH`, `CLEANUP`).
- Any variable defined inside an active block that is subsequently consumed after that block terminates raises finding code `NO_SCP_LEK`.
- To resolve the finding, declare the variable explicitly above the control structure and assign its value inside the conditional branch.

Suppress findings with `"#EC NO_SCOPE_LEAK`.


## Related Rules

* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Avoid Single-Letter Identifiers in Declarations](/rules/no-single-letter) — <code>#EC NO_SINGLE_LETTER</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SCOPE_LEAK`
* **ABAP Implementation:** [/skyl/cl_no_scope_leak.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_scope_leak.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1553)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1553)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SCOPE_LEAK&title=%5BBug%5D%3A%20Issue%20in%20no-scope-leak)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-scope-leak)**
