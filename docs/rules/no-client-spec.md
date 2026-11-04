---
title: "Avoid CLIENT SPECIFIED and USING CLIENT in ABAP SQL"
description: "Preserve multi-tenant data isolation and GDPR compliance in SAP BTP and S/4HANA by avoiding USING CLIENT and CLIENT SPECIFIED in ABAP SQL."
keywords: "no-client-spec, CLIENT SPECIFIED, USING CLIENT, multi-tenant isolation, ABAP Cloud"
category: "security"
ruleId: "no-client-spec"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2514"
---

# Avoid CLIENT SPECIFIED and USING CLIENT in ABAP SQL

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_CLIENT_SPEC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2514" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL.

> **ATC Finding Message:** `Avoid explicit client specification in ABAP SQL`

## Rationale

The CLIENT SPECIFIED and USING CLIENT clauses in ABAP SQL bypass automatic client handling and disable implicit tenant filtering. In multi-tenant cloud environments (such as SAP BTP ABAP Environment and SAP S/4HANA Cloud), querying or mutating data across client boundaries violates multi-tenancy isolation and data privacy compliance (GDPR). In ABAP Cloud (Contract C1), explicit client handling is strictly prohibited, and OpenSQL automatically guarantees that database operations are strictly confined to the logon tenant.

### Non-Compliant

```abap
DATA lv_partner_id TYPE string VALUE '1000001'.
SELECT SINGLE partner, name_first
  FROM but000
  USING CLIENT '100'
  WHERE partner = @lv_partner_id
  INTO @DATA(ls_business_partner).
```

### Compliant

```abap
DATA lv_partner_id TYPE string VALUE '1000001'.
SELECT SINGLE partner, name_first
  FROM but000
  WHERE partner = @lv_partner_id
  INTO @DATA(ls_business_partner).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CLIENT_SPEC

" SAP CI_ prefix format:
... "#EC CI_NO_CLIENT_SPEC
```

### Scope and Multi-Tenant Isolation

The rule monitors all ABAP SQL database operations (`SELECT`, `UPDATE`, `MODIFY`, `DELETE`, `INSERT`) and reports any occurrence of:

- `USING CLIENT` (ABAP SQL modern client switching)
- `CLIENT SPECIFIED` (Classic Open SQL client switching)

**Finding Code:** `NO_CLNT_SP`  
**Suppression:** Pseudo-comment `"#EC NO_CLIENT_SPEC`.

In ABAP Cloud and SAP BTP, tenant separation is maintained automatically by the application server and the database engine. Cross-client access is disallowed to ensure compliance with multi-tenant security architecture.


## Related Rules

* [Enforce WHERE Conditions on Database UPDATE and DELETE Statements](/rules/no-unfilt-dml) — <code>#EC NO_UNFILT_DML</code>
* [Avoid Database Queries Inside Loops (N+1 Query Antipattern)](/rules/no-db-in-loop) — <code>#EC NO_DB_IN_LOOP</code>
* [Guard FOR ALL ENTRIES Against Empty Driving Tables](/rules/no-empty-fae) — <code>#EC NO_EMPTY_FAE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CLIENT_SPEC`
* **ABAP Implementation:** [/skyl/cl_no_client_spec.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_client_spec.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2514)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2514)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CLIENT_SPEC&title=%5BBug%5D%3A%20Issue%20in%20no-client-spec)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-client-spec)**
