---
description: "Prefer Class-Based Exceptions over Classic EXCEPTIONS"
---

# Prefer Class-Based Exceptions over Classic EXCEPTIONS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC CLASS_EXC" />
</div>

## Overview

Prefer Class-Based Exceptions over Classic EXCEPTIONS.

> **ATC Finding Message:** `Prefer class-based exceptions (RAISING) over classic EXCEPTIONS`

## Rationale

Classic non-class exceptions (set via `sy-subrc`) lack stack traces, cannot carry context data, and cannot be propagated up call stacks cleanly. Use class-based exceptions (`CX_ROOT` subclasses).

### Non-Compliant

```abap
METHODS execute EXCEPTIONS not_found failed.
```

### Compliant

```abap
METHODS execute RAISING cx_not_found cx_failed.
```

## Transformation

```diff
- METHODS execute EXCEPTIONS not_found failed.
+ METHODS execute RAISING cx_not_found cx_failed.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-class-exceptions:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CLASS_EXC

" SAP CI_ prefix format:
... "#EC CI_CLASS_EXC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CLASS_EXC`
* **Implementation File:** [zcl_skylint_pref_class_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_class_exc.clas.abap)
