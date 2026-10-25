---
title: "Clean ABAP & Modern Syntax (50 Rules)"
description: "Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices. Comprehensive reference, finding codes, and Clean ABAP examples for Clean ABAP & Modern Syntax."
category: "clean-abap"
keywords: "Clean ABAP, ABAP Cloud, SAP ATC, Clean ABAP & Modern Syntax, S/4HANA Readiness, SAP BTP, Steampunk"
---

# Clean ABAP & Modern Syntax (50 Rules)

Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.

::: tip Category Overview
This category enforces **50 native ATC rules** adhering to SAP Clean ABAP and ABAP Cloud standards. Each check executes natively inside Eclipse ADT and SAP GUI.
:::

## Rules in this Category

| Rule Name | Native ATC Class | Suppression Tag | Automated QuickFix |
|---|---|:---:|:---:|
| [Avoid Nested COND or SWITCH Expressions](/rules/no-nested-cond) | `ZCL_SKYLINT_NO_NESTED_COND` | <code>#EC NO_NESTED_COND</code> | - |
| [Check Downport Compatibility (7.40+ Modern Constructs)](/rules/pref-downport) | `ZCL_SKYLINT_PREF_DOWNPORT` | <code>#EC PREF_DOWNPORT</code> | - |
| [Prefer REDUCE #( ) Expression over Simple Aggregation LOOP](/rules/pref-reduce) | `ZCL_SKYLINT_PREF_REDUCE` | <code>#EC PREF_REDUCE</code> | ⚡ Ready |
| [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) | `ZCL_SKYLINT_PREF_READ_TABLE` | <code>#EC PREF_TAB_EXPR</code> | ⚡ Ready |
| [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) | `ZCL_SKYLINT_PREF_COND` | <code>#EC PREF_COND</code> | ⚡ Ready |
| [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) | `ZCL_SKYLINT_PREF_SWITCH` | <code>#EC PREF_SWITCH</code> | ⚡ Ready |
| [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) | `ZCL_SKYLINT_PREF_LINES` | <code>#EC PREF_LINES</code> | ⚡ Ready |
| [Prefer IS NOT over NOT ... IS](/rules/pref-is-not) | `ZCL_SKYLINT_PREF_IS_NOT` | <code>#EC PREF_IS_NOT</code> | ⚡ Ready |
| [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) | `ZCL_SKYLINT_PREF_PARAM_NAME` | <code>#EC PREF_PARAM_NAME</code> | ⚡ Ready |
| [Prefer String Templates over CONCATENATE](/rules/pref-str-tmpl) | `ZCL_SKYLINT_PREF_STR_TMPL` | <code>#EC PREF_STR_TMPL</code> | ⚡ Ready |
| [Prefer RETURN over EXIT in Methods](/rules/pref-return) | `ZCL_SKYLINT_PREF_RETURN` | <code>#EC PREF_RETURN</code> | ⚡ Ready |
| [Merge Nested IF Statements](/rules/pref-merge-ifs) | `ZCL_SKYLINT_PREF_MERGE_IFS` | <code>#EC PREF_MERGE_IFS</code> | ⚡ Ready |
| [Prefer Symbol Comparison Operators (=, <>, <, >)](/rules/pref-symbol-op) | `ZCL_SKYLINT_PREF_SYMBOL_OP` | <code>#EC PREF_SYMBOL_OP</code> | ⚡ Ready |
| [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) | `ZCL_SKYLINT_PREF_NEW_OP` | <code>#EC PREF_NEW_OPERATOR</code> | ⚡ Ready |
| [Prefer xsdbool( ) for Boolean Assignments](/rules/pref-xsdbool) | `ZCL_SKYLINT_PREF_XSDBOOL` | <code>#EC PREF_XSDBOOL</code> | ⚡ Ready |
| [Require Fully Typed Variables and Parameters](/rules/pref-full-typed) | `ZCL_SKYLINT_PREF_FULL_TYPED` | <code>#EC PREF_FULL_TYPED</code> | - |
| [Prefer CORRESPONDING #( ) Operator](/rules/pref-corresp) | `ZCL_SKYLINT_PREF_CORRESP` | <code>#EC PREF_CORRESP</code> | ⚡ Ready |
| [Prefer Functional RETURNING Parameters](/rules/pref-returning) | `ZCL_SKYLINT_PREF_RETURNING` | <code>#EC PREF_RETURNING</code> | - |
| [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) | `ZCL_SKYLINT_PREF_CLASS_EXC` | <code>#EC PREF_CLASS_EXC</code> | - |
| [Design for Inheritance or Prohibit It (FINAL)](/rules/pref-final-cls) | `ZCL_SKYLINT_PREF_FINAL_CLS` | <code>#EC PREF_FINAL_CLASS</code> | ⚡ Ready |
| [Prefer INSERT ... INTO TABLE over APPEND](/rules/pref-insert) | `ZCL_SKYLINT_PREF_INSERT` | <code>#EC PREF_INSERT</code> | ⚡ Ready |
| [Use Predicate Naming for Boolean Methods (is_, has_, can_)](/rules/pref-pred-name) | `ZCL_SKYLINT_PREF_PRED_NAME` | <code>#EC PREF_PRED_NAME</code> | - |
| [Verify sy-subrc Promptly After Data Retrieval and Search](/rules/pref-check-subrc) | `ZCL_SKYLINT_PREF_CHECK_SUBRC` | <code>#EC PREF_CHECK_SUBRC</code> | - |
| [Prefer Built-in String Functions over SEARCH/SHIFT](/rules/pref-str-func) | `ZCL_SKYLINT_PREF_STR_FUNC` | <code>#EC PREF_STR_FUNC</code> | ⚡ Ready |
| [Prefer Calculation Assignment Operators (+=, -=, *=)](/rules/pref-calc-op) | `ZCL_SKYLINT_PREF_CALC_OP` | <code>#EC PREF_CALC_OP</code> | ⚡ Ready |
| [Prefer Early Return to Reduce Nesting (Guard Clauses)](/rules/pref-early-ret) | `ZCL_SKYLINT_PREF_EARLY_RET` | <code>#EC PREF_GUARD_METHOD</code> | - |
| [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) | `ZCL_SKYLINT_PREF_CASE` | <code>#EC PREF_CASE</code> | - |
| [Prefer Modern Inline Declarations in ABAP 7.40+](/rules/pref-inline) | `ZCL_SKYLINT_PREF_INLINE` | <code>#EC PREF_INLINE</code> | - |
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
| [Prefer FILTER for a Simple LOOP with IF and APPEND](/rules/pref-filter) | `ZCL_SKYLINT_PREF_FILTER` | <code>#EC PREF_FILTER</code> | - |
| [Avoid Negated IF Conditions with ELSE](/rules/no-neg-cond) | `ZCL_SKYLINT_NO_NEG_COND` | <code>#EC NO_NEG_COND</code> | - |
| [Prefer Composition over Inheritance](/rules/pref-composition) | `ZCL_SKYLINT_PREF_COMPOSITION` | <code>#EC PREF_COMPOSITION</code> | - |
| [Prefer Interface Segregation (Small, Focused Interfaces)](/rules/pref-intf-segreg) | `ZCL_SKYLINT_PREF_INTF_SEGREG` | <code>#EC PREF_INTF_SEGREG</code> | - |
| [Avoid Single-Letter Variable Names](/rules/no-single-letter) | `ZCL_SKYLINT_NO_SINGLE_LETTER` | <code>#EC NO_SINGLE_LETTER</code> | - |
| [Prefer CREATE_* Prefix for Factory Methods Returning Own Class](/rules/pref-factory-name) | `ZCL_SKYLINT_PREF_FACTORY_NAME` | <code>#EC PREF_FACTORY_NAME</code> | - |
| [Avoid Hungarian Notation and Type Prefixes](/rules/no-hungarian) | `ZCL_SKYLINT_NO_HUNGARIAN` | <code>#EC NO_HUNGARIAN</code> | - |
| [Avoid IS INSTANCE OF and CASE TYPE OF Type Tests](/rules/no-instance-of) | `ZCL_SKYLINT_NO_INSTANCE_OF` | <code>#EC NO_INSTANCE_OF</code> | - |

---

[← Back to All Rules Catalog](/rules/)
