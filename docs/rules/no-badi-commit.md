---
title: "Avoid COMMIT or ROLLBACK in BAdI Implementations"
description: "Prevent LUW transaction corruption in SAP by prohibiting COMMIT WORK and ROLLBACK WORK inside BAdI implementations."
keywords: "BAdI COMMIT WORK, LUW Integrity SAP, IF_BADI_INTERFACE, Transaction Boundaries"
category: "anti-patterns"
ruleId: "no-badi-commit"
---

# Avoid COMMIT or ROLLBACK in BAdI Implementations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_BADI_COMMIT" />
  <Badge type="warning" text="Local Only" />
</div>

## Overview

Avoid COMMIT or ROLLBACK in BAdI implementations.

> **ATC Finding Message:** `Avoid COMMIT or ROLLBACK WORK inside BAdI implementations (breaks LUW integrity)`

## Rationale

Executing `COMMIT WORK` or `ROLLBACK WORK` inside a Business Add-In (BAdI) breaks the Logical Unit of Work (LUW) of the calling application. It prematurely commits or rolls back standard transactions, leading to severe database inconsistencies and SAP short dumps.

**Standard:** Let the standard transaction or orchestrating caller manage commit and rollback lifecycles.

### Non-Compliant

```abap
METHOD do_work.
  " Anti-pattern: Breaks caller's transaction boundary
  COMMIT WORK.
ENDMETHOD.
```

### Compliant

```abap
METHOD do_work.
  " Clean ABAP: Pure extension logic without transaction control
  update_buffer( ).
ENDMETHOD.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BADI_COMMIT

" SAP CI_ prefix format:
... "#EC CI_NO_BADI_COMMIT
```


## Related Rules

* [Ensure Opened Datasets and Cursors are Closed](/rules/no-unclosed-res) — <code>#EC NO_UNCLOSED_RES</code>
* [Avoid Variable Scope Leaking from Inner Blocks](/rules/no-scope-leak) — <code>#EC NO_SCOPE_LEAK</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_BADI_COMMIT`
* **Implementation File:** [zcl_skylint_no_badi_commit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_badi_commit.clas.abap)
