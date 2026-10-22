---
description: "Use a message class instead of inline message text"
---

# Use a message class (SE91) instead of inline message text

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC MSG_CLASS" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Use a message class instead of inline message text.

> **ATC Finding Message:** `Define the message class and raise it as e001( msg_class )`

## Rationale

Inline message texts are not translatable through SE91 and are scattered across the codebase. A message class centralizes text, numbering, and translation for all consumers. Raise messages with MESSAGE e001(zmsg) or a class-based exception that references the message text.

### Non-Compliant

```abap
MESSAGE 'Something went wrong' TYPE 'E'.
```

### Compliant

```abap
MESSAGE e001(zmsg).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MSG_CLASS

" SAP CI_ prefix format:
... "#EC CI_MSG_CLASS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_MSG_CLS`
* **Implementation File:** [zcl_skylint_pref_msg_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_msg_cls.clas.abap)
