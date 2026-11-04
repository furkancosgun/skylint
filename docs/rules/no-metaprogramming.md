---
title: "Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)"
description: "Mitigate CWE-94 code injection vulnerabilities in SAP ABAP by avoiding GENERATE SUBROUTINE POOL and dynamic code execution."
keywords: "CWE-94 ABAP, GENERATE SUBROUTINE POOL vulnerability, Code Injection SAP, ABAP Cloud Security"
category: "security"
ruleId: "no-metaprogramming"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1905"
---

# Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_METAPROGRAMMING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1905" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Metaprogramming and Dynamic Code Generation.

> **ATC Finding Message:** `Avoid dynamic code generation and metaprogramming constructs`

## Rationale

Statements like `GENERATE SUBROUTINE POOL`, `INSERT REPORT`, and dynamic `SYNTAX-CHECK` create and execute uncompiled ABAP code at runtime. Metaprogramming introduces severe **Remote Code Execution (RCE)** vulnerabilities (CWE-94), defeats static analysis in ATC, and is completely blocked in ABAP Cloud and SAP BTP.

**Cloud Standard:** Use object-oriented polymorphism, strategy design patterns, or BAdIs instead of generating code dynamically.

### Non-Compliant

```abap
" Critical Security Vulnerability: Dynamic code execution from string buffer
GENERATE SUBROUTINE POOL lt_source_code NAME DATA(lv_prog).
PERFORM execute IN PROGRAM (lv_prog).
```

### Compliant

```abap
" Clean ABAP Cloud: Object-oriented strategy pattern
DATA(lo_calculator) = zcl_calculator_factory=>get_strategy( iv_calc_type ).
DATA(lv_result) = lo_calculator->compute( it_data ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_METAPROGRAMMING

" SAP CI_ prefix format:
... "#EC CI_NO_METAPROGRAMMING
```


## Related Rules

* [Handle System and Communication Failures in Remote Function Calls (RFC)](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>
* [Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>
* [Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_METAPROGRAMMING`
* **ABAP Implementation:** [/skyl/cl_no_metaprogramming.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_metaprogramming.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1905)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1905)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_METAPROGRAMMING&title=%5BBug%5D%3A%20Issue%20in%20no-metaprogramming)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-metaprogramming)**
