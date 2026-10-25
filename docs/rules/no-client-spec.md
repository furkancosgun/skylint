---
title: "Avoid CLIENT SPECIFIED / USING CLIENT in Cloud (Multi-Tenant Isolation)"
description: "Preserve multi-tenant data privacy in SAP BTP by avoiding CLIENT SPECIFIED and USING CLIENT in OpenSQL."
keywords: "CLIENT SPECIFIED ABAP Cloud, Multi-tenant isolation SAP BTP, GDPR Data Isolation ABAP"
category: "security"
ruleId: "no-client-spec"
---

# Avoid CLIENT SPECIFIED / USING CLIENT in Cloud (Multi-Tenant Isolation)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CLIENT_SPEC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL.

> **ATC Finding Message:** `Avoid explicit client specification in ABAP SQL`

## Rationale

The clauses `CLIENT SPECIFIED` and `USING CLIENT` override automatic client handling in OpenSQL. In multi-tenant cloud architectures (SAP BTP ABAP Environment, SAP S/4HANA Cloud), querying data across tenants violates multi-tenant data privacy laws (GDPR) and breaks tenant sandbox isolation.

### Non-Compliant

```abap
" Insecure: Reads data across client boundaries
SELECT * FROM zorders CLIENT SPECIFIED WHERE mandt = '200'.
```

### Compliant

```abap
" Secure: Native automatic client handling preserves tenant sandbox
SELECT order_id, status FROM zorders WHERE status = 'OPEN'.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CLIENT_SPEC

" SAP CI_ prefix format:
... "#EC CI_NO_CLIENT_SPEC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CLIENT_SPEC`
* **Implementation File:** [zcl_skylint_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_client_spec.clas.abap)
