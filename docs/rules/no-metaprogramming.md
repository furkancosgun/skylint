---
title: "Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)"
description: "Mitigate CWE-94 code injection vulnerabilities in SAP ABAP by avoiding GENERATE SUBROUTINE POOL and dynamic code execution."
keywords: "CWE-94 ABAP, GENERATE SUBROUTINE POOL vulnerability, Code Injection SAP, ABAP Cloud Security"
---

# Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_METAPROGRAMMING" />
  <Badge type="info" text="Remote Enabled" />
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

## References & Standards

* [CWE-94: Improper Control of Generation of Code](https://cwe.mitre.org/data/definitions/94.html)
* [SAP Clean Core Cloud Guidelines](https://help.sap.com)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_METAPROGRAMMING`
* **Implementation File:** [zcl_skylint_no_metaprogramming.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_metaprogramming.clas.abap)
