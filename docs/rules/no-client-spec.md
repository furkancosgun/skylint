---
description: "Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL"
---

# Avoid CLIENT SPECIFIED / USING CLIENT in Cloud

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC CLIENT_SPEC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL.

> **ATC Finding Message:** `Avoid explicit client specification in ABAP SQL`

## Rationale

USING CLIENT and CLIENT SPECIFIED let code read or write another client and bypass the tenant isolation that ABAP Cloud guarantees. This is a security and compliance violation in multi-tenant environments. Remove explicit client handling and rely on the session client.

### Non-Compliant

```abap
SELECT customer_id FROM /dmo/customer USING CLIENT '100' INTO TABLE @lt_customer_ids.
```

### Compliant

```abap
SELECT customer_id FROM /dmo/customer INTO TABLE @lt_customer_ids.
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
... "#EC CLIENT_SPEC

" SAP CI_ prefix format:
... "#EC CI_CLIENT_SPEC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CLIENT_SPEC`
* **Implementation File:** [zcl_skylint_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_client_spec.clas.abap)
