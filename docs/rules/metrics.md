---
title: "Metrics & Complexity Limits (14 Rules)"
description: "Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity. Comprehensive reference, finding codes, and Clean ABAP examples for Metrics & Complexity Limits."
category: "metrics"
keywords: "Clean ABAP, ABAP Cloud, SAP ATC, Metrics & Complexity Limits, S/4HANA Readiness, SAP BTP, Steampunk"
---

# Metrics & Complexity Limits (14 Rules)

Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.

::: tip Category Overview
This category enforces **14 native ATC rules** adhering to SAP Clean ABAP and ABAP Cloud standards. Each check executes natively inside Eclipse ADT and SAP GUI.
:::

## Rules in this Category

| Rule Name | Native ATC Class | Suppression Tag | Automated QuickFix |
|---|---|:---:|:---:|
| [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) | `ZCL_SKYLINT_MAX_PARAMS` | <code>#EC MAX_PARAMS_COUNT</code> | - |
| [Limit Method and Constructor Statement Length](/rules/max-method-len) | `ZCL_SKYLINT_MAX_METHOD_LEN` | <code>#EC MAX_METHOD_LEN</code> | - |
| [Limit Control Flow Nesting Depth (Guard Clause Enforcement)](/rules/max-nesting) | `ZCL_SKYLINT_MAX_NESTING` | <code>#EC MAX_NESTING</code> | - |
| [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) | `ZCL_SKYLINT_MAX_CYCLO_COMP` | <code>#EC MAX_CYCLO_COMP</code> | - |
| [Limit NPath Complexity per Method](/rules/max-npath) | `ZCL_SKYLINT_MAX_NPATH` | <code>#EC MAX_NPATH</code> | - |
| [Limit Class Inheritance Depth (Favor Composition over Inheritance)](/rules/max-inherit) | `ZCL_SKYLINT_MAX_INHERIT` | <code>#EC MAX_INHERIT</code> | - |
| [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) | `ZCL_SKYLINT_MAX_ATTRIBUTES` | <code>#EC MAX_ATTRIBUTES</code> | - |
| [Limit One Statement per Source Code Line (No Inline Colon Chains)](/rules/max-one-stmt) | `ZCL_SKYLINT_MAX_ONE_STMT` | <code>#EC MAX_ONE_STMT</code> | - |
| [Limit Source Code Line Length (Avoid Horizontal Scrolling)](/rules/max-line-len) | `ZCL_SKYLINT_MAX_LINE_LEN` | <code>#EC MAX_LINE_LEN</code> | - |
| [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) | `ZCL_SKYLINT_MAX_BOOL_EXPR` | <code>#EC MAX_BOOL_EXPR</code> | - |
| [Limit Multiple Return Statements per Method Body](/rules/max-returns) | `ZCL_SKYLINT_MAX_RETURNS` | <code>#EC MAX_RETURNS</code> | - |
| [Limit Cognitive Complexity per Method](/rules/max-cognitive) | `ZCL_SKYLINT_MAX_COGNITIVE` | <code>#EC MAX_COGNITIVE</code> | - |
| [Limit Local Variable Count per Method](/rules/max-locals) | `ZCL_SKYLINT_MAX_LOCALS` | <code>#EC MAX_LOCALS</code> | - |
| [Limit Type Fan-Out per Procedure](/rules/max-fanout) | `ZCL_SKYLINT_MAX_FANOUT` | <code>#EC MAX_FANOUT</code> | - |

---

[← Back to All Rules Catalog](/rules/)
