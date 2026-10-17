# Avoid Explicit COMMIT WORK in Business Logic

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: NO_COMMIT" />
</div>

## Overview

Avoid COMMIT and ROLLBACK in application logic.

> **ATC Finding Message:** `Avoid COMMIT/ROLLBACK WORK; transactional control belongs to framework`

## Rationale

Transactional business logic should rely on the persistence framework or framework save sequence (e.g. RAP) rather than triggering premature or uncoordinated database commits.

## Transformation

```diff
- " Inside a RAP behavior implementation (CL_ABAP_BEHAVIOR_HANDLER)
- METHOD update.
-   MODIFY ENTITIES OF ...
-   COMMIT WORK.
- ENDMETHOD.
+ " In RAP, commits are managed automatically by the framework save sequence
+ METHOD update.
+   MODIFY ENTITIES OF ...
+ ENDMETHOD.
```

### Non-Compliant

```abap
" Inside a RAP behavior implementation (CL_ABAP_BEHAVIOR_HANDLER)
METHOD update.
  MODIFY ENTITIES OF ...
  COMMIT WORK.
ENDMETHOD.
```

### Compliant

```abap
" In RAP, commits are managed automatically by the framework save sequence
METHOD update.
  MODIFY ENTITIES OF ...
ENDMETHOD.
```

## CLI & CI/CD Configuration

```yaml
checks:
  no-commit-work:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC COMMIT_WORK

" SAP CI_ prefix format:
... "#EC CI_COMMIT_WORK
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_COMMIT_WORK`
* **Finding Code:** `NO_COMMIT`
* **Implementation File:** [zcl_skylint_no_commit_work.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_commit_work.clas.abap)
