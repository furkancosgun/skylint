---
description: "Max One Statement Per Line"
---

# Limit One Statement per Source Code Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC ONE_STMT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Max One Statement Per Line.

> **ATC Finding Message:** `Only one statement is allowed per line`

## Rationale

Two statements on one line are easy to miss during review and produce coarse Git diffs. Debugger stepping and code coverage also become harder to follow when multiple statements share a line. Put each statement on its own line.

### Non-Compliant

```abap
lv_count = 0. lv_total = 0.
```

### Compliant

```abap
lv_count = 0.
lv_total = 0.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ONE_STMT

" SAP CI_ prefix format:
... "#EC CI_ONE_STMT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ONE_STMT`
* **Implementation File:** [zcl_skylint_max_one_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_one_stmt.clas.abap)
