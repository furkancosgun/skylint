---
title: "Avoid Dynamic Metaprogramming and Runtime Code Generation"
description: "Prevent CWE-94 code injection vulnerabilities in SAP systems by replacing GENERATE SUBROUTINE POOL and dynamic metaprogramming with OOP strategies."
keywords: "no-metaprogramming, GENERATE SUBROUTINE POOL, CWE-94, ABAP code injection, ABAP Cloud"
category: "security"
ruleId: "no-metaprogramming"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1925"
---

# Avoid Dynamic Metaprogramming and Runtime Code Generation

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_METAPROGRAMMING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1925" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Metaprogramming and Dynamic Code Generation.

> **ATC Finding Message:** `Avoid dynamic code generation and metaprogramming constructs`

## Rationale

Dynamic code generation statements including GENERATE SUBROUTINE POOL, INSERT REPORT, SYNTAX-CHECK, and EDITOR-CALL FOR REPORT assemble and execute uncompiled ABAP code at runtime. Metaprogramming introduces critical Remote Code Execution (RCE) and code injection vulnerabilities (CWE-94), circumvents static code analysis and ATC security inspection, and is completely blocked in ABAP Cloud (Contract C1). Modern enterprise architectures should instead employ object-oriented design patterns, strategy factories, interfaces, or standard Business Add-Ins (BAdIs) to achieve runtime extensibility safely.

### Non-Compliant

```abap
GENERATE SUBROUTINE POOL lt_source_lines NAME DATA(lv_program_name).
```

### Compliant

```abap
DATA(lo_tax_calculator) = zcl_tax_factory=>get_strategy( 'DE' ).
DATA(lv_calculated_tax) = lo_tax_calculator->compute( '100.00' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_METAPROGRAMMING

" SAP CI_ prefix format:
... "#EC CI_NO_METAPROGRAMMING
```

### Detected Metaprogramming Statements

The check scans procedure bodies for obsolete and high-risk dynamic code manipulation keywords:

| Keyword / Statement | Scope |
|---|---|
| `SYNTAX-CHECK` | Dynamic syntax checking of arbitrary source code buffers. |
| `GENERATE SUBROUTINE POOL` / `REPORT` / `DYNPRO` | Runtime compilation of temporary or permanent ABAP programs. |
| `INSERT REPORT` / `TEXTPOOL` | Direct database insertion of ABAP source code or text symbols. |
| `DELETE REPORT` / `TEXTPOOL` / `DYNPRO` | Deletion of repository program and screen artifacts at runtime. |
| `EXPORT DYNPRO` | Binary export or manipulation of classic screen definitions. |
| `EDITOR-CALL FOR REPORT` | Interactive editor invocation for source code modification. |

All occurrences report finding code `NO_METAPRG`. Suppress individual statements if required using pseudo-comment `"#EC NO_METAPROGRAMMING`.


## Related Rules

* [Handle System and Communication Failures in Remote RFC Calls](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>
* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>
* [Avoid Dynamic OpenSQL and Metaprogramming Language Constructs](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_METAPROGRAMMING`
* **ABAP Implementation:** [/skyl/cl_no_metaprogramming.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_metaprogramming.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1925)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1925)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_METAPROGRAMMING&title=%5BBug%5D%3A%20Issue%20in%20no-metaprogramming)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-metaprogramming)**
