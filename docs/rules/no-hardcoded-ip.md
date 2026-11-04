---
title: "Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code"
description: "Detect and eliminate hardcoded IPv4 and IPv6 addresses in ABAP source code. Enforce SM59 RFC destinations and cloud communication management."
keywords: "Hardcoded IP ABAP, IPv4 Address Linting, IPv6 Security SAP, Clean Core Network Configuration"
category: "security"
ruleId: "no-hardcoded-ip"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4979"
---

# Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_IP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4979" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid hardcoded IPv4 and IPv6 addresses in source code.

> **ATC Finding Message:** `Avoid hardcoded IP address; use SM59 destination or hostname configuration`

## Rationale

Hardcoding IP addresses in ABAP source code couples business logic to physical or virtual infrastructure, breaks DNS load balancing, and violates cloud portability guidelines. In modern hybrid and cloud environments (BTP, S/4HANA Private/Public Cloud), server IP addresses are dynamic and must be resolved through hostname configuration, SM59 destinations, or Communication Arrangements.

**Best Practice:** Use logical destinations (such as SM59 or BTP Destinations) or DNS hostnames instead of raw IP addresses.

### Non-Compliant

```abap
" Anti-pattern: Hardcoded IP address connection
DATA(lo_dest) = cl_http_destination_provider=>create_by_url(
  i_url = 'http://192.168.1.50:8080/api' ).
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
| `CHECK_IPV4` | `Boolean` | <code>true</code> | Detect hardcoded IPv4 addresses |
| `CHECK_IPV6` | `Boolean` | <code>true</code> | Detect hardcoded IPv6 addresses |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_IP

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_IP
```


## Related Rules

* [Avoid Hardcoded HTTP, HTTPS, and FTP URLs in Source Code](/rules/no-hardcoded-url) — <code>#EC NO_HARDCODED_URL</code>
* [Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HARDCODED_IP`
* **ABAP Implementation:** [/skyl/cl_no_hardcoded_ip.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hardcoded_ip.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4979)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4979)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_HARDCODED_IP&title=%5BBug%5D%3A%20Issue%20in%20no-hardcoded-ip)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-hardcoded-ip)**
