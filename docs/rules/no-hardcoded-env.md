---
title: "Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)"
description: "Eliminate hardcoded sy-sysid and sy-mandt checks in ABAP. Ensure Clean Core cloud readiness and multi-tenant isolation."
keywords: "Hardcoded sy-sysid ABAP, Tenant Isolation BTP, sy-mandt Clean Core, SAP S/4HANA Cloud Readiness"
category: "security"
ruleId: "no-hardcoded-env"
---

# Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_ENV" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid reading environment system fields (sy-sysid, etc.).

> **ATC Finding Message:** `Avoid reading environment system fields (sy-sysid, sy-uname, etc.)`

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
| `ONLY_CONDITIONAL` | `Boolean` | <code>false</code> | Only flag occurrences when used inside conditional comparisons (IF, CASE) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_ENV

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_ENV
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_HARDCODED_ENV`
* **Implementation File:** [zcl_skylint_no_hardcoded_env.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_hardcoded_env.clas.abap)
