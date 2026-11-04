---
title: "Avoid Hardcoded HTTP, HTTPS, and FTP URLs in Source Code"
description: "Detect and eliminate hardcoded HTTP, HTTPS, and FTP URLs in ABAP source code. Enforce SM59 RFC destinations and BTP Communication Management."
keywords: "Hardcoded URL ABAP, ABAP Cloud Communication Arrangement, SM59 Destination, SAP Security Guideline"
category: "security"
ruleId: "no-hardcoded-url"
---

# Avoid Hardcoded HTTP, HTTPS, and FTP URLs in Source Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_URL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid hardcoded HTTP, HTTPS, and FTP URLs in source code.

> **ATC Finding Message:** `Avoid hardcoded URL; use SM59 destination or communication arrangement`

## Rationale

Hardcoding absolute URLs and endpoint addresses directly in source code creates brittle dependencies, environment pollution, and security vulnerabilities. When promoting code across landscapes (DEV -> QA -> PROD) or deploying to ABAP Cloud environments, hardcoded URLs prevent environment-specific endpoint resolution and break proxy routing.

**Best Practice:** Maintain remote endpoints in SM59 RFC destinations, Communication Arrangements, or Customizing tables, and resolve them dynamically at runtime.

### Non-Compliant

```abap
" Anti-pattern: Hardcoded URL connection
DATA(lo_dest) = cl_http_destination_provider=>create_by_url(
  i_url = 'https://api.skylint.org/v1/orders' ).
DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
```

### Compliant

```abap
" Clean ABAP: Configuration-based destination (SM59, BTP, or Communication Arrangement)
DATA(lo_dest) = cl_http_destination_provider=>create_by_destination(
  i_destination = 'SKYLINT' ).
DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_HTTP` | `Boolean` | <code>true</code> | Flag hardcoded HTTP and HTTPS URLs |
| `CHECK_FTP` | `Boolean` | <code>true</code> | Flag hardcoded FTP and SFTP URLs |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_URL

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_URL
```


## Related Rules

* [Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>
* [Handle System and Communication Failures in Remote Function Calls (RFC)](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HARDCODED_URL`
* **Implementation File:** [#skyl#cl_no_hardcoded_url.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hardcoded_url.clas.abap)
