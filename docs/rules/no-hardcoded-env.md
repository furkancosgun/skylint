---
title: "Avoid Reading Environment and Landscape System Fields"
description: "Eliminate hardcoded sy-sysid, sy-mandt, and sy-uname checks in ABAP to ensure multi-tenant isolation and ABAP Cloud readiness."
keywords: "no-hardcoded-env, sy-sysid ABAP, sy-mandt, Multi-Tenant Isolation, Clean ABAP, ABAP Cloud"
category: "security"
ruleId: "no-hardcoded-env"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3383"
---

# Avoid Reading Environment and Landscape System Fields

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_ENV" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3383" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid reading environment system fields (sy-sysid, etc.).

> **ATC Finding Message:** `Avoid reading environment system fields (sy-sysid, sy-uname, sy-tcode, etc.)`

## Rationale

Conditioning application logic on hardcoded SAP environment system fields—such as system ID (sy-sysid), client (sy-mandt), host server (sy-host), database system (sy-dbsys), operating system (sy-opsys), or logon user (sy-uname)—creates brittle code that fails when promoted through landscape tiers (DEV to QA to PROD). In multi-tenant ABAP Cloud architectures (SAP BTP ABAP environment and S/4HANA Cloud), hardcoding client numbers violates multi-tenant isolation principles and triggers Cloud Contract C1 tenant isolation errors. Clean ABAP mandates abstracting environmental dependencies into injectable configuration services, feature toggles, customizing tables, or official authorization checks.

### Non-Compliant

```abap
IF sy-sysid = 'PRD' AND sy-mandt = '100'.
  process_live_payment( ls_payment ).
ELSE.
  simulate_test_payment( ls_payment ).
ENDIF.
```

### Compliant

```abap
IF mo_environment_provider->is_production_environment( ) = abap_true.
  process_live_payment( ls_payment ).
ELSE.
  simulate_test_payment( ls_payment ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SYSID` | `Boolean` | <code>true</code> | Detect access to sy-sysid system field representing the SAP system ID (default: true). |
| `CHECK_MANDT` | `Boolean` | <code>true</code> | Detect access to sy-mandt system field representing the client number (default: true). |
| `CHECK_HOST` | `Boolean` | <code>true</code> | Detect access to sy-host system field representing the application server hostname (default: true). |
| `CHECK_DBSYS` | `Boolean` | <code>true</code> | Detect access to sy-dbsys system field representing the underlying database system (default: true). |
| `CHECK_OPSYS` | `Boolean` | <code>true</code> | Detect access to sy-opsys system field representing the operating system (default: true). |
| `CHECK_UNAME` | `Boolean` | <code>true</code> | Detect access to sy-uname system field representing the current logon username (default: true). |
| `CHECK_TCODE` | `Boolean` | <code>true</code> | Detect access to sy-tcode system field representing the current transaction code (default: true). |
| `CHECK_REPID` | `Boolean` | <code>true</code> | Detect access to sy-repid system field representing the current ABAP program or report (default: true). |
| `CHECK_CPROG` | `Boolean` | <code>true</code> | Detect access to sy-cprog system field representing the calling main program (default: true). |
| `ONLY_CONDITIONAL` | `Boolean` | <code>false</code> | Restrict detection to conditional expressions such as IF, CASE, WHEN, CHECK, COND, and SWITCH (default: false). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_ENV

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_ENV
```

## Evaluated System Fields

Each system field check can be toggled individually through rule parameters:

| System Field | Parameter Attribute | Architectural Concern | Recommended Clean Alternative |
|---|---|---|---|
| `sy-sysid` | `CHECK_SYSID` | Brittle across landscape tiers | Feature toggles, customizing tables, or BTP destination configurations |
| `sy-mandt` | `CHECK_MANDT` | Breaks multi-tenant isolation | Tenant-aware configuration tables or standard RAP context |
| `sy-host` | `CHECK_HOST` | Couples logic to physical hardware | Logical RFC / HTTP destinations via SM59 or BTP Destination Service |
| `sy-dbsys` | `CHECK_DBSYS` | Platform-specific code branch | Database-independent CDS views or AMDP wrappers |
| `sy-opsys` | `CHECK_OPSYS` | OS-dependent file handling | Cloud storage services or released file APIs |
| `sy-uname` | `CHECK_UNAME` | Hardcoded backdoor or user bypass | `AUTHORITY-CHECK` statements against authorization objects |
| `sy-tcode` | `CHECK_TCODE` | Dynpro-dependent classic transaction | Business service interfaces or RAP behavior actions |
| `sy-repid` / `sy-cprog` | `CHECK_REPID` / `CHECK_CPROG` | Program name coupling | Object-oriented caller callbacks or interfaces |

Set `ONLY_CONDITIONAL` to `abap_true` to restrict reports to conditional statements (`IF`, `CASE`, `WHEN`, `CHECK`, `COND`, `SWITCH`, `WHERE`). Suppress individual findings with `"#EC NO_HARDCODED_ENV` or `##NO_HARDCODED_ENV`.


## Related Rules

* [Avoid Raising System Exceptions Directly (cx_sy_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Avoid Internal C-Kernel Calls and Native Database SQL](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>
* [Handle System and Communication Failures in Remote RFC Calls](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HARDCODED_ENV`
* **ABAP Implementation:** [/skyl/cl_no_hardcoded_env.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hardcoded_env.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3383)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3383)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_HARDCODED_ENV&title=%5BBug%5D%3A%20Issue%20in%20no-hardcoded-env)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-hardcoded-env)**
