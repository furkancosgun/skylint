---
title: "Avoid COMMIT and ROLLBACK WORK Inside BAdI Implementations"
description: "Prohibit COMMIT WORK and ROLLBACK WORK in ABAP BAdI implementations to safeguard SAP LUW transactional integrity."
keywords: "BAdI COMMIT WORK, SAP LUW integrity, IF_BADI_INTERFACE, Clean ABAP transactions, SAP ATC check, no-badi-commit"
category: "anti-patterns"
ruleId: "no-badi-commit"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5870"
---

# Avoid COMMIT and ROLLBACK WORK Inside BAdI Implementations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_BADI_COMMIT" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5870" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid COMMIT or ROLLBACK in BAdI implementations.

> **ATC Finding Message:** `Avoid COMMIT or ROLLBACK WORK inside BAdI implementations (breaks LUW integrity)`

## Rationale

Business Add-Ins (BAdIs) execute within the caller's Logical Unit of Work (LUW). Triggering COMMIT WORK or ROLLBACK WORK inside a BAdI implementation prematurely terminates the caller's transaction boundary, triggers background update tasks unexpectedly, and invalidates SAP database locks. This leads to critical database inconsistencies and runtime short dumps (e.g. COMMIT_IN_POSTING). Transaction boundaries must remain under the orchestrating caller's control.

### Non-Compliant

```abap
METHOD if_badi_interface~execute.
  save_custom_audit_log( ).
  COMMIT WORK.
ENDMETHOD.
```

### Compliant

```abap
METHOD if_badi_interface~execute.
  save_custom_audit_log( ).
  " Transaction boundaries are controlled by the calling orchestrator
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

### LUW integrity and BAdIs

Classes implementing `IF_BADI_INTERFACE` participate in SAP transactional units managed by standard or orchestrating applications:

| Command in BAdI Method | Risk | Finding |
| --- | --- | --- |
| `COMMIT WORK.` | Triggers premature commit, flushes update tasks, releases enqueue locks | `NO_BADI_CM` |
| `ROLLBACK WORK.` | Destroys caller's uncommitted transaction state | `NO_BADI_CM` |
| Asynchronous update via `CALL FUNCTION ... IN UPDATE TASK` | Registered for caller's eventual commit | Compliant |

### Remote Enablement Note

This check utilizes ABAP Run-Time Type Identification (RTTI) to inspect whether the enclosing class implements `IF_BADI_INTERFACE`. As a result, `remote_enablement` is set to `abap_false` by design to prevent RFC failures in remote ATC scenarios.

### Suppression

In exceptional standalone test runners, suppress with `"#EC NO_BADI_COMMIT`.


## Related Rules

* [Close Opened Datasets and Database Cursors Explicitly](/rules/no-unclosed-res) — <code>#EC NO_UNCLOSED_RES</code>
* [Prevent Variable Scope Leakage Outside Control Blocks](/rules/no-scope-leak) — <code>#EC NO_SCOPE_LEAK</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BADI_COMMIT`
* **ABAP Implementation:** [/skyl/cl_no_badi_commit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_badi_commit.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5870)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5870)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BADI_COMMIT&title=%5BBug%5D%3A%20Issue%20in%20no-badi-commit)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-badi-commit)**
