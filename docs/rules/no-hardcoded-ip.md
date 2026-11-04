---
title: "Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code"
description: "Detect and eliminate hardcoded IPv4 and IPv6 addresses in ABAP source code to enforce DNS resolution and destination-based routing."
keywords: "no-hardcoded-ip, Hardcoded IP ABAP, IPv4 Address Linting, IPv6 Security, Clean ABAP, SAP ATC"
category: "security"
ruleId: "no-hardcoded-ip"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5140"
---

# Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_HARDCODED_IP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5140" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid hardcoded IPv4 and IPv6 addresses in source code.

> **ATC Finding Message:** `Avoid hardcoded IP address; use SM59 destination or hostname configuration`

## Rationale

Embedding raw IPv4 or IPv6 network addresses directly into ABAP business logic tightly couples application components to physical or virtual host hardware, bypassing DNS hostname resolution, TLS certificate validation, load balancers, and reverse proxies. In containerized, virtualized, and hybrid cloud environments (such as SAP BTP and SAP S/4HANA Cloud), network topologies and IP address assignments change dynamically without warning. Clean ABAP, SAP security baselines, and ABAP Cloud Contract C1 mandate routing outbound network connections through logical destinations (such as SM59 or SAP Destination Service) or fully qualified domain names.

### Non-Compliant

```abap
DATA(lo_destination) = cl_http_destination_provider=>create_by_url(
  i_url = 'http://192.168.10.50:8080/api/v1/telemetry' ).
```

### Compliant

```abap
DATA(lo_destination) = cl_http_destination_provider=>create_by_destination(
  i_destination = 'TELEMETRY_GATEWAY' ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_IPV4` | `Boolean` | <code>true</code> | Detect hardcoded IPv4 dot-decimal addresses in string literals and templates (default: true). |
| `CHECK_IPV6` | `Boolean` | <code>true</code> | Detect hardcoded IPv6 hexadecimal colon-separated addresses in string literals (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HARDCODED_IP

" SAP CI_ prefix format:
... "#EC CI_NO_HARDCODED_IP
```

## Supported IP Address Formats

The check inspects string literals and templates using regular expression pattern matching:

| IP Version | Parameter Attribute | Pattern Detected | Excluded Patterns |
|---|---|---|---|
| `IPv4` | `CHECK_IPV4` | Dot-decimal notation (`192.168.1.100`, `10.20.30.40:8080`) | Semantic version strings (`1.2.3`), single numbers |
| `IPv6` | `CHECK_IPV6` | Hexadecimal colon-separated notation (`2001:0db8:...`, `::1`) | Standard timestamps, port numbers |

Outbound network calls should reference destination configurations managed in SM59 or SAP BTP Destination Service. Suppress intentional IP declarations using `"#EC NO_HARDCODED_IP` or `##NO_HARDCODED_IP`.


## Related Rules

* [Avoid Hardcoded HTTP and FTP URLs in Source Code](/rules/no-hardcoded-url) — <code>#EC NO_HARDCODED_URL</code>
* [Avoid Reading Environment and Landscape System Fields](/rules/no-hardcoded-env) — <code>#EC NO_HARDCODED_ENV</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HARDCODED_IP`
* **ABAP Implementation:** [/skyl/cl_no_hardcoded_ip.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hardcoded_ip.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5140)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5140)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_HARDCODED_IP&title=%5BBug%5D%3A%20Issue%20in%20no-hardcoded-ip)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-hardcoded-ip)**
