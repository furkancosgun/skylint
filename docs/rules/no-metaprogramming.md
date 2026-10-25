---
description: "Metaprogramming and Dynamic Code Generation"
---

# Avoid Metaprogramming and Dynamic Code Generation

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC METAPROGRAM" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Metaprogramming and Dynamic Code Generation.

> **ATC Finding Message:** `Avoid dynamic code generation and metaprogramming constructs`

## Rationale

Statements such as SYNTAX-CHECK, GENERATE REPORT/SUBROUTINE, INSERT/DELETE REPORT or TEXTPOOL, and EDITOR-CALL perform dynamic code manipulation at runtime. They introduce major security risks (code injection), bypass static ATC analysis, are completely forbidden in ABAP Cloud, and compromise system auditability.

### Non-Compliant

```abap
SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.
DELETE REPORT 'ZTEMP_PROG'.
```

### Compliant

```abap
" Refactor to statically compiled classes, interfaces, or standard factory patterns.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC METAPROGRAM

" SAP CI_ prefix format:
... "#EC CI_METAPROGRAM
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_METAPROGRAMMING`
* **Implementation File:** [zcl_skylint_no_metaprogramming.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_metaprogramming.clas.abap)
