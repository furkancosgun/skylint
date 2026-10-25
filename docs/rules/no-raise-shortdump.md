---
description: "Avoid RAISE SHORTDUMP"
---

# Avoid RAISE SHORTDUMP in Application Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC SHORTDUMP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid RAISE SHORTDUMP.

> **ATC Finding Message:** `Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions`

## Rationale

RAISE SHORTDUMP intentionally causes a runtime error (DUMP) and terminates the LUW abruptly. In modern enterprise applications and ABAP Cloud, failures must be communicated back to callers or framework layers using catchable class-based exceptions rather than uncatchable crash commands.

### Non-Compliant

```abap
RAISE SHORTDUMP TYPE cx_sy_zerodivide.
```

### Compliant

```abap
RAISE EXCEPTION TYPE cx_sy_zerodivide.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SHORTDUMP

" SAP CI_ prefix format:
... "#EC CI_SHORTDUMP
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAISE_SHORTDUMP`
* **Implementation File:** [zcl_skylint_no_raise_shortdump.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_shortdump.clas.abap)
