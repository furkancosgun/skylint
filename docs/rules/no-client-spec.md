---
title: "Avoid CLIENT SPECIFIED / USING CLIENT in Cloud (Multi-Tenant Isolation)"
description: "Preserve multi-tenant data privacy in SAP BTP by avoiding CLIENT SPECIFIED and USING CLIENT in OpenSQL."
keywords: "CLIENT SPECIFIED ABAP Cloud, Multi-tenant isolation SAP BTP, GDPR Data Isolation ABAP"
category: "security"
ruleId: "no-client-spec"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2467"
---

# Avoid CLIENT SPECIFIED / USING CLIENT in Cloud (Multi-Tenant Isolation)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_CLIENT_SPEC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2467" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CLIENT_SPEC

" SAP CI_ prefix format:
... "#EC CI_NO_CLIENT_SPEC
```


## Related Rules

* [Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)](/rules/no-unfilt-dml) — <code>#EC NO_UNFILT_DML</code>
* [Avoid Database Access Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CLIENT_SPEC`
* **ABAP Implementation:** [/skyl/cl_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_client_spec.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2467)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2467)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CLIENT_SPEC&title=%5BBug%5D%3A%20Issue%20in%20no-client-spec)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-client-spec)**
