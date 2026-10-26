---
title: "Anti-Patterns & Bad Practices (54 Rules)"
description: "Discouraged language constructs, legacy statements, and redundant syntax. Comprehensive reference, finding codes, and Clean ABAP examples for Anti-Patterns & Bad Practices."
category: "anti-patterns"
keywords: "Clean ABAP, ABAP Cloud, SAP ATC, Anti-Patterns & Bad Practices, S/4HANA Readiness, SAP BTP, Steampunk"
---

# Anti-Patterns & Bad Practices (54 Rules)

Discouraged language constructs, legacy statements, and redundant syntax.

::: tip Category Overview
This category enforces **54 native ATC rules** adhering to SAP Clean ABAP and ABAP Cloud standards. Each check executes natively inside Eclipse ADT and SAP GUI.
:::

## Rules in this Category

| Rule Name | Native ATC Class | Suppression Tag | Automated QuickFix |
|---|---|:---:|:---:|
| [Disallow Configured Custom Regex Patterns](/rules/no-custom-pattern) | `ZCL_SKYLINT_NO_CUSTOM_PATTERN` | <code>#EC NO_CUSTOM_PATTERN</code> | - |
| [Avoid Loops That Execute At Most Once](/rules/no-single-iter) | `ZCL_SKYLINT_NO_SINGLE_ITER` | <code>#EC NO_SINGLE_ITER</code> | - |
| [Avoid Obsolete CALL METHOD](/rules/no-call-method) | `ZCL_SKYLINT_NO_CALL_METHOD` | <code>#EC NO_CALL_METHOD</code> | ⚡ Ready |
| [Avoid WITH DEFAULT KEY](/rules/no-default-key) | `ZCL_SKYLINT_NO_DEFAULT_KEY` | <code>#EC NO_DEFAULT_KEY</code> | ⚡ Ready |
| [Avoid Redundant ME-> Self Reference](/rules/no-me-reference) | `ZCL_SKYLINT_NO_ME_REFERENCE` | <code>#EC NO_ME_REFERENCE</code> | ⚡ Ready |
| [Omit RECEIVING in Method Invocations](/rules/no-call-receiving) | `ZCL_SKYLINT_NO_CALL_RECEIVING` | <code>#EC NO_CALL_RECEIVING</code> | ⚡ Ready |
| [Omit Redundant EXPORTING in Method Calls](/rules/no-call-exporting) | `ZCL_SKYLINT_NO_CALL_EXPORTING` | <code>#EC NO_CALL_EXPORTING</code> | ⚡ Ready |
| [Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)](/rules/no-chained-decl) | `ZCL_SKYLINT_NO_CHAINED_DECL` | <code>#EC NO_CHAINED_DECL</code> | ⚡ Ready |
| [Avoid Chained Assignments (a = b = c = 1)](/rules/no-chained-assign) | `ZCL_SKYLINT_NO_CHAINED_ASSIGN` | <code>#EC NO_CHAINED_ASSIGN</code> | ⚡ Ready |
| [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) | `ZCL_SKYLINT_NO_BOOL_COMPARE` | <code>#EC NO_BOOL_COMPARE</code> | ⚡ Ready |
| [Avoid CHECK Statements](/rules/no-check-stmt) | `ZCL_SKYLINT_NO_CHECK_STMT` | <code>#EC NO_CHECK_IN_LOOP</code> | ⚡ Ready |
| [Avoid Empty Control Blocks](/rules/no-empty-block) | `ZCL_SKYLINT_NO_EMPTY_BLOCK` | <code>#EC NO_EMPTY_BLOCK</code> | ⚡ Ready |
| [Avoid Identical Statements in IF Branches](/rules/no-ident-cont) | `ZCL_SKYLINT_NO_IDENT_CONT` | <code>#EC NO_IDENT_CONT</code> | - |
| [Avoid Duplicate Branch Conditions](/rules/no-dup-cond) | `ZCL_SKYLINT_NO_DUP_COND` | <code>#EC NO_DUP_COND</code> | - |
| [Avoid Dead / Unreachable Code](/rules/no-unreachable) | `ZCL_SKYLINT_NO_UNREACHABLE` | <code>#EC NO_UNREACHABLE</code> | ⚡ Ready |
| [Avoid CASE with a Single WHEN Branch](/rules/no-single-when) | `ZCL_SKYLINT_NO_SINGLE_WHEN` | <code>#EC NO_SINGLE_WHEN</code> | - |
| [Avoid Yoda Conditions](/rules/no-yoda-cond) | `ZCL_SKYLINT_NO_YODA_COND` | <code>#EC NO_YODA_COND</code> | ⚡ Ready |
| [Avoid Calling Static Methods via Instance References (->)](/rules/no-static-arrow) | `ZCL_SKYLINT_NO_STATIC_ARROW` | <code>#EC NO_STATIC_ARROW</code> | ⚡ Ready |
| [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) | `ZCL_SKYLINT_NO_EXPOSED_DATA` | <code>#EC PUBLIC_ATTR</code> | - |
| [Avoid Obsolete Arithmetic and Assignment Statements](/rules/no-obs-arith) | `ZCL_SKYLINT_NO_OBS_ARITH` | <code>#EC NO_OBS_ARITH</code> | ⚡ Ready |
| [Avoid Obsolete Declarations and Table Headers](/rules/no-obs-decl) | `ZCL_SKYLINT_NO_OBS_DECL` | <code>#EC NO_OBS_DECL</code> | ⚡ Ready |
| [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) | `ZCL_SKYLINT_NO_OBS_CONTROL` | <code>#EC NO_OBS_CONTROL</code> | ⚡ Ready |
| [Avoid Obsolete ABAP Memory and Context Statements](/rules/no-obs-memory) | `ZCL_SKYLINT_NO_OBS_MEMORY` | <code>#EC NO_OBS_MEMORY</code> | - |
| [Avoid Obsolete String and POSIX Regex Statements](/rules/no-obs-strings) | `ZCL_SKYLINT_NO_OBS_STRINGS` | <code>#EC NO_OBS_STRINGS</code> | - |
| [Avoid Classic List Processing Statements](/rules/no-list-proc) | `ZCL_SKYLINT_NO_LIST_PROC` | <code>#EC NO_LIST_PROC</code> | - |
| [Avoid Variable Scope Leaking from Inner Blocks](/rules/no-scope-leak) | `ZCL_SKYLINT_NO_SCOPE_LEAK` | <code>#EC NO_SCOPE_LEAK</code> | - |
| [Remove Redundant Self-Assignments and Identity Moves](/rules/no-redun-assign) | `ZCL_SKYLINT_NO_REDUN_ASSIGN` | <code>#EC NO_IDENTICAL_MOVE</code> | ⚡ Ready |
| [Avoid Local Variables Shadowing Class Attributes](/rules/no-shadow) | `ZCL_SKYLINT_NO_SHADOW` | <code>#EC NO_SHADOW</code> | - |
| [Avoid Concatenating Adjacent String Literals](/rules/no-useless-concat) | `ZCL_SKYLINT_NO_USELESS_CONCAT` | <code>#EC NO_USELESS_CONCAT</code> | ⚡ Ready |
| [Avoid Magic Numbers; Use Named Constants](/rules/no-magic-numbers) | `ZCL_SKYLINT_NO_MAGIC_NUMBERS` | <code>#EC NO_MAGIC_NUMBERS</code> | - |
| [Avoid LIKE Typing on Global Dictionary Objects](/rules/no-like-objects) | `ZCL_SKYLINT_NO_LIKE_OBJECTS` | <code>#EC NO_LIKE_OBJECTS</code> | - |
| [Avoid Purely Static Utility Classes](/rules/no-static-cls) | `ZCL_SKYLINT_NO_STATIC_CLS` | <code>#EC NO_STATIC_CLS</code> | - |
| [Avoid Obsolete MESSAGE ... RAISING in Methods](/rules/no-msg-raising) | `ZCL_SKYLINT_NO_MSG_RAISING` | <code>#EC NO_MSG_RAISING</code> | - |
| [Avoid Deeply Nested TRY ... CATCH Blocks](/rules/no-nested-try) | `ZCL_SKYLINT_NO_NESTED_TRY` | <code>#EC NO_NESTED_TRY</code> | - |
| [Eliminate Unused Local Variables and Symbols](/rules/no-unused-vars) | `ZCL_SKYLINT_NO_UNUSED_VARS` | <code>#EC NO_UNUSED_VARS</code> | - |
| [Avoid Obsolete ! Escape Prefix in Parameter Names](/rules/no-param-escape) | `ZCL_SKYLINT_NO_PARAM_ESCAPE` | <code>#EC NO_PARAM_ESCAPE</code> | ⚡ Ready |
| [Avoid Obsolete Inline Length Specifications (var(len))](/rules/no-inline-len) | `ZCL_SKYLINT_NO_INLINE_LEN` | <code>#EC NO_INLINE_LEN</code> | ⚡ Ready |
| [Avoid Obsolete Dash (-) in Form Names](/rules/no-dash-in-form) | `ZCL_SKYLINT_NO_DASH_IN_FORM` | <code>#EC NO_DASH_IN_FORM</code> | ⚡ Ready |
| [Avoid FRIENDS in class definitions](/rules/no-friends) | `ZCL_SKYLINT_NO_FRIENDS` | <code>#EC NO_FRIENDS</code> | - |
| [Classic EXCEPTIONS must not map two errors to the same number](/rules/no-exc-overlap) | `ZCL_SKYLINT_NO_EXC_OVERLAP` | <code>#EC NO_EXC_OVERLAP</code> | - |
| [Remove redundant parentheses](/rules/no-many-parens) | `ZCL_SKYLINT_NO_MANY_PARENS` | <code>#EC NO_MANY_PARENS</code> | ⚡ Ready |
| [Omit Unnecessary RETURN Statement](/rules/no-unnec-return) | `ZCL_SKYLINT_NO_UNNEC_RETURN` | <code>#EC NO_UNNEC_RETURN</code> | ⚡ Ready |
| [Do Not Mix RETURNING with EXPORTING or CHANGING](/rules/no-mix-returning) | `ZCL_SKYLINT_NO_MIX_RETURNING` | <code>#EC NO_MIX_RETURNING</code> | - |
| [Avoid Method Names That Overwrite Built-in Functions](/rules/no-overw-builtin) | `ZCL_SKYLINT_NO_OVERW_BUILTIN` | <code>#EC NO_OVERW_BUILTIN</code> | - |
| [Do Not Ignore Return Value of Functional Methods](/rules/no-ignored-return) | `ZCL_SKYLINT_NO_IGNORED_RETURN` | <code>#EC NO_IGNORED_RETURN</code> | - |
| [Expand Macro Calls into Explicit Statements](/rules/pref-expand-macro) | `ZCL_SKYLINT_PREF_EXPAND_MACRO` | <code>#EC PREF_EXPAND_MACRO</code> | ⚡ Ready |
| [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) | `ZCL_SKYLINT_NO_DEAD_CODE` | <code>#EC NO_DEAD_CODE</code> | ⚡ Ready |
| [Avoid Using ABAP Keywords as Identifier Names](/rules/no-keyword-name) | `ZCL_SKYLINT_NO_KEYWORD_NAME` | <code>#EC NO_KEYWORD_NAME</code> | - |
| [Avoid Repeating the Same String Literal](/rules/no-dup-literals) | `ZCL_SKYLINT_NO_DUP_LITERALS` | <code>#EC NO_DUP_LITERALS</code> | - |
| [Avoid Late Access to sy-tabix or sy-index Outside Loops](/rules/no-late-sys-idx) | `ZCL_SKYLINT_NO_LATE_SYS_IDX` | <code>#EC NO_LATE_SYS_IDX</code> | - |
| [Avoid Method Override That Only Delegates to Super](/rules/no-empty-override) | `ZCL_SKYLINT_NO_EMPTY_OVERRIDE` | <code>#EC NO_EMPTY_OVERRIDE</code> | - |
| [Avoid Comparisons and Arithmetic with Identical Operands](/rules/no-self-compare) | `ZCL_SKYLINT_NO_SELF_COMPARE` | <code>#EC NO_SELF_COMPARE</code> | - |
| [Avoid CATCH Blocks That Only Re-raise the Same Exception](/rules/no-catch-reraise) | `ZCL_SKYLINT_NO_CATCH_RERAISE` | <code>#EC NO_CATCH_RERAISE</code> | - |
| [Preserve the Original Exception with PREVIOUS](/rules/no-exc-chain) | `ZCL_SKYLINT_NO_EXC_CHAIN` | <code>#EC NO_EXC_CHAIN</code> | - |

---

[← Back to All Rules Catalog](/rules/)
