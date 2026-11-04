---
title: "Avoid Hardcoded HTTP and FTP URLs in Source Code"
description: "Detect hardcoded HTTP, HTTPS, and FTP URLs in ABAP source code to enforce SAP Destination Service and Communication Arrangements."
keywords: "no-hardcoded-url, Hardcoded URL ABAP, SAP Destination Service, Communication Arrangement, Clean ABAP, SAP ATC"
category: "security"
ruleId: "no-hardcoded-url"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5108"
---

# Avoid Hardcoded HTTP and FTP URLs in Source Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_URL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5108" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid hardcoded HTTP, HTTPS, and FTP URLs in source code.

> **ATC Finding Message:** `Avoid hardcoded URL; use SM59 destination or communication arrangement`

## Rationale

Hardcoding absolute HTTP, HTTPS, or FTP URLs directly in ABAP source code creates tight coupling to external network infrastructure, breaks environment portability across landscape tiers (development, testing, quality assurance, and production), and prevents infrastructure teams from modifying hostnames, proxy routes, or TLS configurations without source code deployments. In SAP BTP and S/4HANA Cloud (Cloud Contract C1), outbound network communication must be decoupled via SAP Destination Service, SM59 HTTP destinations, or Communication Arrangements (cl_http_destination_provider). Clean ABAP requires isolating network endpoints in centrally managed destinations.

### Non-Compliant

```abap
DATA(lo_destination) = cl_http_destination_provider=>create_by_url(
  i_url = 'https://api.partner.example.com/v1/orders' ).
```

### Compliant

```abap
DATA(lo_destination) = cl_http_destination_provider=>create_by_destination(
  i_destination = 'OUTBOUND_ORDER_API' ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_HTTP` | `Boolean` | <code>true</code> | Detect hardcoded HTTP and HTTPS URLs in string literals and text symbols (default: true). |
| `CHECK_FTP` | `Boolean` | <code>true</code> | Detect hardcoded FTP and SFTP URLs in string literals and text symbols (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_URL

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_URL
```

## URL Protocol Detection

The check inspects string literals and templates for embedded URL schemes:

| Protocol Checked | Parameter Attribute | Example Flagged Literal | Clean Replacement |
|---|---|---|---|
| `HTTP://` / `HTTPS://` | `CHECK_HTTP` | `'https://api.example.com/orders'` | `cl_http_destination_provider=>create_by_destination` |
| `FTP://` / `SFTP://` | `CHECK_FTP` | `'ftp://files.example.com/exports'` | Logical file destinations or managed communication arrangements |

Short literals under 10 characters (such as prefix constants `'https://'`) and relative URL paths (such as `'/api/v1/orders'`) are not flagged. Suppress valid static URL declarations using `"#EC NO_HARDCODED_URL` or `##NO_HARDCODED_URL`.


## Related Rules

* [Avoid Reading Environment and Landscape System Fields](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>
* [Handle System and Communication Failures in Remote RFC Calls](/rules/no-rfc-err) — <code>#EC NO_RFC_ERR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HARDCODED_URL`
* **ABAP Implementation:** [/skyl/cl_no_hardcoded_url.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hardcoded_url.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5108)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5108)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_HARDCODED_URL&title=%5BBug%5D%3A%20Issue%20in%20no-hardcoded-url)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-hardcoded-url)**
