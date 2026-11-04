---
title: "Avoid Internal C-Kernel Calls and Native Database SQL"
description: "Ensure ABAP Cloud and S/4HANA readiness by replacing internal SYSTEM-CALL and native EXEC SQL statements with released SAP Cloud APIs."
keywords: "no-kernel-call, SYSTEM-CALL, EXEC SQL, ABAP Cloud, SAP ATC"
category: "security"
ruleId: "no-kernel-call"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1953"
---

# Avoid Internal C-Kernel Calls and Native Database SQL

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_KERNEL_CALL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1953" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Kernel and Native Calls.

> **ATC Finding Message:** `Avoid internal kernel calls (CALL, SYSTEM-CALL, EXEC SQL)`

## Rationale

Invoking internal SAP C-kernel routines via SYSTEM-CALL or CALL 'routine', as well as embedding native database code with EXEC SQL, bypasses the OpenSQL syntax abstraction layer, authorization buffers, and tenant isolation safeguards. Undocumented kernel calls depend on internal C-routines that are unstable across kernel patch levels, and EXEC SQL statements create vendor-specific database coupling that breaks ABAP Cloud compatibility (Cloud Contract C1). Applications should interact with the platform exclusively through released ABAP Cloud APIs, Core Data Services (CDS) view entities, and typed ABAP SQL.

### Non-Compliant

```abap
SYSTEM-CALL rfc_clone_connection.
```

### Compliant

```abap
DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination( 'ERP_DEST' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_KERNEL_CALL

" SAP CI_ prefix format:
... "#EC CI_NO_KERNEL_CALL
```

### Reported Instructions

The check identifies three categories of low-level platform invocations:

| Construct | Description |
|---|---|
| `SYSTEM-CALL` | Undocumented low-level kernel routines invoked directly in ABAP. |
| `CALL 'c_routine'` | C-kernel procedures called with literal routine names. |
| `EXEC SQL ... ENDEXEC` | Embedded native SQL bypassing SAP Open SQL and SAP HANA CDS engines. |

All matches produce finding code `NO_KERNEL`. Suppress findings when working with approved low-level system drivers using pseudo-comment `"#EC NO_KERNEL_CALL`.


## Related Rules

* [Handle System and Communication Failures in Remote RFC Calls](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>
* [Provide FAILED and REPORTED in RAP EML Statements](/rules/no-unhandled-eml) — <code>#EC NO_UNHANDLED_EML</code>
* [Avoid Raising System Exceptions Directly (cx_sy_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_KERNEL_CALL`
* **ABAP Implementation:** [/skyl/cl_no_kernel_call.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_kernel_call.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1953)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1953)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_KERNEL_CALL&title=%5BBug%5D%3A%20Issue%20in%20no-kernel-call)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-kernel-call)**
