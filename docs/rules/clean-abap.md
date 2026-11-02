---
title: "Clean ABAP & Modern Syntax (79 Rules)"
description: "Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices. Comprehensive reference, finding codes, and Clean ABAP examples for Clean ABAP & Modern Syntax."
category: "clean-abap"
keywords: "Clean ABAP, ABAP Cloud, SAP ATC, Clean ABAP & Modern Syntax, S/4HANA Readiness, SAP BTP, Steampunk"
---

# Clean ABAP & Modern Syntax (79 Rules)

Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.

::: tip Category Overview
This category enforces **79 native ATC rules** adhering to SAP Clean ABAP and ABAP Cloud standards. Each check executes natively inside Eclipse ADT and SAP GUI.
:::

## Rules in this Category

| Rule Name | Native ATC Class | Suppression Tag | Automated QuickFix |
|---|---|:---:|:---:|
| [Prefer Modern Class-Based APIs over Obsolete Function Modules](/rules/pref-func-module) | `ZCL_SKYLINT_PREF_FUNC_MODULE` | <code>#EC PREF_FUNC_MOD</code> | - |
| [Parenthesize Combinations of AND and OR](/rules/pref-paren-and-or) | `ZCL_SKYLINT_PREF_PAREN_AND_OR` | <code>#EC PREF_PAREN_AND_OR</code> | ⚡ Ready |
| [Avoid Redundant CONTINUE at End of Loop](/rules/no-useless-cont) | `ZCL_SKYLINT_NO_USELESS_CONT` | <code>#EC NO_USELESS_CONT</code> | ⚡ Ready |
| [Avoid Nested COND or SWITCH Expressions](/rules/no-nested-cond) | `ZCL_SKYLINT_NO_NESTED_COND` | <code>#EC NO_NESTED_COND</code> | - |
| [Check Downport Compatibility (7.40+ Modern Constructs)](/rules/pref-downport) | `ZCL_SKYLINT_PREF_DOWNPORT` | <code>#EC PREF_DOWNPORT</code> | - |
| [Prefer REDUCE #( ) Expression over Simple Aggregation LOOP](/rules/pref-reduce) | `ZCL_SKYLINT_PREF_REDUCE` | <code>#EC PREF_REDUCE</code> | - |
| [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) | `ZCL_SKYLINT_PREF_READ_TABLE` | <code>#EC PREF_TAB_EXPR</code> | - |
| [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) | `ZCL_SKYLINT_PREF_COND` | <code>#EC PREF_COND</code> | ⚡ Ready |
| [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) | `ZCL_SKYLINT_PREF_SWITCH` | <code>#EC PREF_SWITCH</code> | ⚡ Ready |
| [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) | `ZCL_SKYLINT_PREF_LINES` | <code>#EC PREF_LINES</code> | ⚡ Ready |
| [Prefer IS NOT over NOT ... IS](/rules/pref-is-not) | `ZCL_SKYLINT_PREF_IS_NOT` | <code>#EC PREF_IS_NOT</code> | ⚡ Ready |
| [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) | `ZCL_SKYLINT_PREF_PARAM_NAME` | <code>#EC PREF_PARAM_NAME</code> | ⚡ Ready |
| [Avoid Unused Parameters in Procedures](/rules/no-unused-param) | `ZCL_SKYLINT_NO_UNUSED_PARAM` | <code>#EC NO_UNUSED_PARAM</code> | - |
| [Prefer String Templates over CONCATENATE](/rules/pref-str-tmpl) | `ZCL_SKYLINT_PREF_STR_TMPL` | <code>#EC PREF_STR_TMPL</code> | ⚡ Ready |
| [Prefer RETURN over EXIT in Methods](/rules/pref-return) | `ZCL_SKYLINT_PREF_RETURN` | <code>#EC PREF_RETURN</code> | ⚡ Ready |
| [Merge Nested IF Statements](/rules/pref-merge-ifs) | `ZCL_SKYLINT_PREF_MERGE_IFS` | <code>#EC PREF_MERGE_IFS</code> | ⚡ Ready |
| [Prefer Symbol Comparison Operators (=, <>, <, >)](/rules/pref-symbol-op) | `ZCL_SKYLINT_PREF_SYMBOL_OP` | <code>#EC PREF_SYMBOL_OP</code> | ⚡ Ready |
| [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) | `ZCL_SKYLINT_PREF_NEW_OP` | <code>#EC PREF_NEW_OPERATOR</code> | ⚡ Ready |
| [Prefer xsdbool( ) for Boolean Assignments](/rules/pref-xsdbool) | `ZCL_SKYLINT_PREF_XSDBOOL` | <code>#EC PREF_XSDBOOL</code> | ⚡ Ready |
| [Require Fully Typed Variables and Parameters](/rules/pref-full-typed) | `ZCL_SKYLINT_PREF_FULL_TYPED` | <code>#EC PREF_FULL_TYPED</code> | ⚡ Ready |
| [Prefer CORRESPONDING #( ) Operator](/rules/pref-corresp) | `ZCL_SKYLINT_PREF_CORRESP` | <code>#EC PREF_CORRESP</code> | ⚡ Ready |
| [Prefer Functional RETURNING Parameters](/rules/pref-returning) | `ZCL_SKYLINT_PREF_RETURNING` | <code>#EC PREF_RETURNING</code> | - |
| [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) | `ZCL_SKYLINT_PREF_CLASS_EXC` | <code>#EC PREF_CLASS_EXC</code> | - |
| [Design for Inheritance or Prohibit It (FINAL)](/rules/pref-final-cls) | `ZCL_SKYLINT_PREF_FINAL_CLS` | <code>#EC PREF_FINAL_CLASS</code> | ⚡ Ready |
| [Prefer INSERT ... INTO TABLE over APPEND](/rules/pref-insert) | `ZCL_SKYLINT_PREF_INSERT` | <code>#EC PREF_INSERT</code> | ⚡ Ready |
| [Use Predicate Naming for Boolean Methods (is_, has_, can_)](/rules/pref-pred-name) | `ZCL_SKYLINT_PREF_PRED_NAME` | <code>#EC PREF_PRED_NAME</code> | - |
| [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) | `ZCL_SKYLINT_PREF_CHECK_SUBRC` | <code>#EC PREF_CHECK_SUBRC</code> | - |
| [Prefer Built-in String Functions over SEARCH/SHIFT](/rules/pref-str-func) | `ZCL_SKYLINT_PREF_STR_FUNC` | <code>#EC PREF_STR_FUNC</code> | ⚡ Ready |
| [Prefer Calculation Assignment Operators (+=, -=, *=)](/rules/pref-calc-op) | `ZCL_SKYLINT_PREF_CALC_OP` | <code>#EC PREF_CALC_OP</code> | ⚡ Ready |
| [Prefer Early Return to Reduce Nesting (Guard Clauses)](/rules/pref-early-ret) | `ZCL_SKYLINT_PREF_EARLY_RET` | <code>#EC PREF_GUARD_METHOD</code> | ⚡ Ready |
| [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) | `ZCL_SKYLINT_PREF_CASE` | <code>#EC PREF_CASE</code> | ⚡ Ready |
| [Prefer Modern Inline Declarations in ABAP 7.40+](/rules/pref-inline) | `ZCL_SKYLINT_PREF_INLINE` | <code>#EC PREF_INLINE</code> | ⚡ Ready |
| [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) | `ZCL_SKYLINT_PREF_FINAL_DATA` | <code>#EC PREF_FINAL_DATA</code> | ⚡ Ready |
| [Use a message class (SE91) instead of inline message text](/rules/pref-msg-cls) | `ZCL_SKYLINT_PREF_MSG_CLS` | <code>#EC PREF_MSG_CLS</code> | - |
| [Declare Constructor in PUBLIC SECTION](/rules/pref-pub-ctor) | `ZCL_SKYLINT_PREF_PUB_CTOR` | <code>#EC PREF_PUB_CTOR</code> | - |
| [Routine Declaration Hygiene (Top Placement & Order)](/rules/pref-declarations) | `ZCL_SKYLINT_PREF_DECLARATIONS` | <code>#EC DEF_TOP</code> | - |
| [Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons](/rules/pref-is-initial) | `ZCL_SKYLINT_PREF_IS_INITIAL` | <code>#EC PREF_IS_INITIAL</code> | ⚡ Ready |
| [Modernize Downcasting (CAST #( ) Expression & Inlining)](/rules/pref-downcast) | `ZCL_SKYLINT_PREF_DOWNCAST` | <code>#EC PREF_CAST</code> | ⚡ Ready |
| [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) | `ZCL_SKYLINT_PREF_NAMING_VARS` | <code>#EC PREF_NAMING_VARS</code> | - |
| [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) | `ZCL_SKYLINT_PREF_NAME_MEMBERS` | <code>#EC PREF_NAME_MEMBERS</code> | - |
| [Enforce Class, Interface, Type and Object Naming Conventions](/rules/pref-name-objects) | `ZCL_SKYLINT_PREF_NAME_OBJECTS` | <code>#EC PREF_NAME_OBJECTS</code> | - |
| [Statement Indentation Must Match Block Nesting](/rules/no-bad-indent) | `ZCL_SKYLINT_NO_BAD_INDENT` | <code>#EC NO_BAD_INDENT</code> | ⚡ Ready |
| [Prefer an Explicit JOIN Type](/rules/pref-join-type) | `ZCL_SKYLINT_PREF_JOIN_TYPE` | <code>#EC PREF_JOIN_TYPE</code> | ⚡ Ready |
| [Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF](/rules/pref-std-table) | `ZCL_SKYLINT_PREF_STD_TABLE` | <code>#EC PREF_STD_TABLE</code> | ⚡ Ready |
| [Prefer IS SUPPLIED over IS REQUESTED](/rules/pref-is-supplied) | `ZCL_SKYLINT_PREF_IS_SUPPLIED` | <code>#EC PREF_IS_SUPPLIED</code> | ⚡ Ready |
| [Prefer the Short System Field Alias SY over SYST](/rules/pref-sy) | `ZCL_SKYLINT_PREF_SY` | <code>#EC PREF_SY</code> | ⚡ Ready |
| [Avoid Negated IF Conditions with ELSE](/rules/no-neg-cond) | `ZCL_SKYLINT_NO_NEG_COND` | <code>#EC NO_NEG_COND</code> | - |
| [Prefer Composition over Inheritance](/rules/pref-composition) | `ZCL_SKYLINT_PREF_COMPOSITION` | <code>#EC PREF_COMPOSITION</code> | - |
| [Prefer Interface Segregation (Small, Focused Interfaces)](/rules/pref-intf-segreg) | `ZCL_SKYLINT_PREF_INTF_SEGREG` | <code>#EC PREF_INTF_SEGREG</code> | - |
| [Avoid Single-Letter Variable Names](/rules/no-single-letter) | `ZCL_SKYLINT_NO_SINGLE_LETTER` | <code>#EC NO_SINGLE_LETTER</code> | - |
| [Prefer CREATE_* Prefix for Factory Methods Returning Own Class](/rules/pref-factory-name) | `ZCL_SKYLINT_PREF_FACTORY_NAME` | <code>#EC PREF_FACTORY_NAME</code> | - |
| [Avoid Hungarian Notation and Type Prefixes](/rules/no-hungarian) | `ZCL_SKYLINT_NO_HUNGARIAN` | <code>#EC NO_HUNGARIAN</code> | - |
| [Avoid IS INSTANCE OF and CASE TYPE OF Type Tests](/rules/no-instance-of) | `ZCL_SKYLINT_NO_INSTANCE_OF` | <code>#EC NO_INSTANCE_OF</code> | - |
| [Require WHEN OTHERS as the Last Branch of CASE](/rules/pref-when-others) | `ZCL_SKYLINT_PREF_WHEN_OTHERS` | <code>#EC PREF_WHEN_OTHERS</code> | ⚡ Ready |
| [Prefer BETWEEN for Inclusive Range Checks](/rules/pref-between) | `ZCL_SKYLINT_PREF_BETWEEN` | <code>#EC PREF_BETWEEN</code> | ⚡ Ready |
| [Avoid Boolean Flag Importing Parameters](/rules/no-bool-blindness) | `ZCL_SKYLINT_NO_BOOL_BLINDNESS` | <code>#EC NO_BOOL_BLINDNESS</code> | - |
| [Explicitly Specify SORT Order](/rules/pref-sort-order) | `ZCL_SKYLINT_PREF_SORT_ORDER` | <code>#EC PREF_SORT_ORDER</code> | - |
| [Prefer ICON_ Constants over Hardcoded Icon Codes](/rules/pref-icon-const) | `ZCL_SKYLINT_PREF_ICON_CONST` | <code>#EC PREF_ICON_CONST</code> | - |
| [Avoid Unused Parameters in Procedures](/rules/no-unused-param) | `ZCL_SKYLINT_NO_UNUSED_PARAM` | <code>#EC NO_UNUSED_PARAM</code> | - |
| [Avoid Ambiguous Statements](/rules/no-ambiguous-stmt) | `ZCL_SKYLINT_NO_AMBIGUOUS_STMT` | <code>#EC NO_AMBIGUOUS_STMT</code> | - |
| [Avoid Empty Procedures](/rules/no-empty-proc) | `ZCL_SKYLINT_NO_EMPTY_PROC` | <code>#EC NO_EMPTY_PROC</code> | - |
| [Avoid Concrete Class References in Interfaces](/rules/no-intf-class-ref) | `ZCL_SKYLINT_NO_INTF_CLASS_REF` | <code>#EC NO_INTF_CLASS_REF</code> | - |
| [Avoid ALIASES in Classes and Interfaces](/rules/no-aliases) | `ZCL_SKYLINT_NO_ALIASES` | <code>#EC NO_ALIASES</code> | - |
| [Avoid Consecutive Whitespace Between Tokens](/rules/no-double-space) | `ZCL_SKYLINT_NO_DOUBLE_SPACE` | <code>#EC NO_DOUBLE_SPACE</code> | - |
| [Single Parameter or Field Per Line](/rules/pref-param-1line) | `ZCL_SKYLINT_PREF_PARAM_1LINE` | <code>#EC PREF_PARAM_1LINE</code> | - |
| [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) | `ZCL_SKYLINT_PREF_STRICT_SQL` | <code>#EC PREF_STRICT_SQL</code> | - |
| [Prefer Enumerations over Constants](/rules/pref-enum) | `ZCL_SKYLINT_PREF_ENUM` | <code>#EC PREF_ENUM</code> | - |
| [Avoid Protected Attributes](/rules/no-protected-data) | `ZCL_SKYLINT_NO_PROTECTED_DATA` | <code>#EC NO_PROTECTED_DATA</code> | - |
| [Avoid Excessive Method Chaining](/rules/no-method-chain) | `ZCL_SKYLINT_NO_METHOD_CHAIN` | <code>#EC NO_METHOD_CHAIN</code> | - |
| [Avoid Generic and Implicit ANY Types](/rules/no-implicit-any) | `ZCL_SKYLINT_NO_IMPLICIT_ANY` | <code>#EC NO_IMPLICIT_ANY</code> | - |
| [Require Explicit DURATION and RISK LEVEL Attributes on Test Classes](/rules/pref-test-attributes) | `ZCL_SKYLINT_PREF_TEST_ATTR` | <code>#EC PREF_TEST_ATTR</code> | - |
| [Avoid String Templates Without Embedded Expressions](/rules/no-raw-str-tmpl) | `ZCL_SKYLINT_NO_RAW_STR_TMPL` | <code>#EC NO_RAW_STR_TMPL</code> | - |
| [Prefer LOOP AT WHERE over IF CONTINUE Guards](/rules/pref-loop-where) | `ZCL_SKYLINT_PREF_LOOP_WHERE` | <code>#EC PREF_LOOP_WHERE</code> | - |
| [Prefer Simpler String Functions over Plain Regex](/rules/pref-plain-regex) | `ZCL_SKYLINT_PREF_PLAIN_REGEX` | <code>#EC PREF_PLAIN_REGEX</code> | - |
| [Limit Consecutive Blank Lines](/rules/max-blank-lines) | `ZCL_SKYLINT_MAX_BLANK_LINES` | <code>#EC MAX_BLANK_LINES</code> | - |
| [Raise At Most One Exception Class per Method](/rules/no-multi-exc) | `ZCL_SKYLINT_NO_MULTI_EXC` | <code>#EC NO_MULTI_EXC</code> | - |
| [Avoid Dynamic MESSAGE Statements](/rules/no-dyn-message) | `ZCL_SKYLINT_NO_DYN_MESSAGE` | <code>#EC NO_DYN_MESSAGE</code> | - |
| [Prefer nmin/nmax or clamp Expressions over Manual IF Clamping](/rules/pref-clamp) | `ZCL_SKYLINT_PREF_CLAMP` | <code>#EC PREF_CLAMP</code> | ⚡ Ready |
| [Declare Optional and Default Parameters Last in Methods](/rules/pref-opt-last) | `ZCL_SKYLINT_PREF_OPT_LAST` | <code>#EC PREF_OPTIONAL_LAST</code> | - |

---

[← Back to All Rules Catalog](/rules/)
