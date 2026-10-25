---
title: "Limit One Statement per Source Code Line (No Inline Colon Chains)"
description: "Improve code readability and Git diff clarity in ABAP by requiring exactly one statement per source line."
keywords: "One statement per line ABAP, Colon chaining Clean ABAP, Debugger Line Stepping SAP, Clean Code Formatting"
---

# Limit One Statement per Source Code Line (No Inline Colon Chains)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_ONE_STMT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Max One Statement Per Line.

> **ATC Finding Message:** `Only one statement is allowed per line`

## Rationale

Placing multiple statements on a single line (either via semicolons, colons, or simple chaining like `a = 1. b = 2.`) compromises readability, impairs debugger single-stepping, and destroys Git line-by-line diff precision. When a runtime error occurs, the debugger stops on the line without clarifying which of the statements failed.

**Clean ABAP Guideline:** Write exactly one ABAP statement per source code line.

### Non-Compliant

```abap
" Anti-pattern: Multiple statements on one line
lv_status = 'OPEN'. lv_count = 0. CLEAR ls_header.
```

### Compliant

```abap
" Clean ABAP: Dedicated line for each statement
lv_status = 'OPEN'.
lv_count = 0.
CLEAR ls_header.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_ONE_STMT

" SAP CI_ prefix format:
... "#EC CI_MAX_ONE_STMT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ONE_STMT`
* **Implementation File:** [zcl_skylint_max_one_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_one_stmt.clas.abap)
