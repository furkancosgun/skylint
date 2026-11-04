---
title: "Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)"
description: "Eliminate hardcoded sy-sysid and sy-mandt checks in ABAP. Ensure Clean Core cloud readiness and multi-tenant isolation."
keywords: "Hardcoded sy-sysid ABAP, Tenant Isolation BTP, sy-mandt Clean Core, SAP S/4HANA Cloud Readiness"
category: "security"
ruleId: "no-hardcoded-env"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3305"
---

# Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_ENV" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3305" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid reading environment system fields (sy-sysid, etc.).

> **ATC Finding Message:** `Avoid reading environment system fields (sy-sysid, sy-uname, sy-tcode, etc.)`

## Rationale

Branching business logic on hardcoded SAP System IDs (`sy-sysid = 'PRD'`), client numbers (`sy-mandt = '100'`), or server hostnames makes ABAP code fragile, untestable in sandbox environments, and incompatible with cloud transports. In multi-tenant ABAP Cloud systems (BTP), hardcoding client numbers breaks tenant isolation and violates SAP Clean Core guidelines.

**Best Practice:** Encapsulate environment configurations in feature toggles, custom configuration tables, or standard SAP BPF/BTP environment services.

### Non-Compliant

```abap
" Anti-pattern: Hardcoded environment and client checks
IF sy-sysid = 'PRD' AND sy-mandt = '100'.
  send_live_bank_order( is_payment ).
ELSEIF sy-sysid = 'DEV'.
  mock_bank_response( ).
ENDIF.
```

### Compliant

```abap
" Clean ABAP: Feature toggle or environment service configuration
IF mo_env_service->is_live_payment_active( ) = abap_true.
  send_live_bank_order( is_payment ).
ELSE.
  mock_bank_response( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SYSID` | `Boolean` | <code>true</code> | Detect hardcoded checks against sy-sysid |
| `CHECK_MANDT` | `Boolean` | <code>true</code> | Detect hardcoded client number comparisons against sy-mandt |
| `CHECK_HOST` | `Boolean` | <code>true</code> | Detect hardcoded server hostnames (sy-host) |
| `CHECK_DBSYS` | `Boolean` | <code>true</code> | Detect database system checks (sy-dbsys) |
| `CHECK_OPSYS` | `Boolean` | <code>true</code> | Detect operating system checks (sy-opsys) |
| `CHECK_UNAME` | `Boolean` | <code>true</code> | Detect hardcoded user names (sy-uname) in conditional branches |
| `CHECK_TCODE` | `Boolean` | <code>true</code> | Detect hardcoded transaction code comparisons (sy-tcode) |
| `CHECK_REPID` | `Boolean` | <code>true</code> | Detect hardcoded report / program ID checks (sy-repid) |
| `CHECK_CPROG` | `Boolean` | <code>true</code> | Detect hardcoded calling program checks (sy-cprog) |
| `ONLY_CONDITIONAL` | `Boolean` | <code>false</code> | Only flag occurrences when used inside conditional comparisons (IF, CASE) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_ENV

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_ENV
```


## Related Rules

* [Avoid Raising System Exceptions Directly (CX_SY_*)](/rules/no-raise-cx-sy) — <code>#EC NO_RAISE_CX_SY</code>
* [Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)](/rules/no-kernel-call) — <code>#EC NO_KERNEL_CALL</code>
* [Handle System and Communication Failures in Remote Function Calls (RFC)](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HARDCODED_ENV`
* **ABAP Implementation:** [/skyl/cl_no_hardcoded_env.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hardcoded_env.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3305)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3305)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_HARDCODED_ENV&title=%5BBug%5D%3A%20Issue%20in%20no-hardcoded-env)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-hardcoded-env)**
