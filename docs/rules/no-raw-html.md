---
title: "Avoid Hardcoded Raw HTML Markup and Cross-Site Scripting"
description: "Prevent Cross-Site Scripting (XSS) in ABAP by detecting hardcoded raw HTML tags in strings and enforcing cl_abap_format escaping."
keywords: "no-raw-html, XSS ABAP Security, Raw HTML Detection, cl_abap_format, Clean ABAP, SAP ATC"
category: "security"
ruleId: "no-raw-html"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5172"
---

# Avoid Hardcoded Raw HTML Markup and Cross-Site Scripting

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAW_HTML" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5172" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid raw unescaped HTML tags in strings and templates.

> **ATC Finding Message:** `Avoid hardcoded raw HTML; use UI5, BSP, or cl_abap_format/escape to prevent XSS`

## Rationale

Embedding raw HTML markup strings (`<script>`, `<div>`, `<span>`, `<table>`) directly inside ABAP business logic violates separation of concerns by coupling backend data processing to client-side presentation rendering. Furthermore, interpolating dynamic user values into raw HTML strings without strict context-aware encoding introduces severe Cross-Site Scripting (XSS / OWASP Top 10 A03 / CWE-79) vulnerabilities. In modern SAP architectures and ABAP Cloud, user interfaces should be developed with SAP Fiori / SAPUI5 consuming OData/RAP services. Where HTML generation is strictly necessary (such as email bodies), all dynamic variables must be sanitized using escape( val = ... format = cl_abap_format=>e_html_text ).

### Non-Compliant

```abap
DATA(lv_html_content) = |<div class="user-profile"><span>{ lv_customer_name }</span></div>|.
```

### Compliant

```abap
DATA(lv_safe_name) = escape( val = lv_customer_name format = cl_abap_format=>e_html_text ).
DATA(lv_html_content) = |<div class="user-profile"><span>{ lv_safe_name }</span></div>|. "#EC NO_RAW_HTML
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SCRIPTS` | `Boolean` | <code>true</code> | Detect script and iframe HTML tags presenting critical Cross-Site Scripting (XSS) risks (default: true). |
| `CHECK_TAGS` | `Boolean` | <code>true</code> | Detect structural HTML tags such as div, span, table, form, and input in string literals (default: true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAW_HTML

" SAP CI_ prefix format:
... "#EC CI_NO_RAW_HTML
```

## Detected HTML Elements

The check inspects string literals and templates for embedded HTML tags:

| Tag Category | Parameter Attribute | Tags Detected | Security Assessment |
|---|---|---|---|
| High-Risk Executable Tags | `CHECK_SCRIPTS` | `<script>`, `<iframe>` | Critical XSS risk; client-side code execution |
| Structural Markup Tags | `CHECK_TAGS` | `<html>`, `<body>`, `<div>`, `<span>`, `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<td>`, `<th>`, `<form>`, `<input>`, `<img>`, `<a>`, `<p>` | UI coupling, formatting inconsistencies, XSS injection surface |

Non-HTML XML tags (such as `<OrderHeader id="123"/>`) and relational comparison operators (`<`, `>`) without HTML tag names are ignored. When generating HTML email notifications, encode dynamic values with `escape( val = ... format = cl_abap_format=>e_html_text )` and suppress the literal markup statement with `"#EC NO_RAW_HTML` or `##NO_RAW_HTML`.


## Related Rules

* [Avoid Hardcoded HTTP and FTP URLs in Source Code](/rules/no-hardcoded-url) — <code>#EC NO_HARDCODED_URL</code>
* [Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code](/rules/no-hardcoded-ip) — <code>#EC NO_HARDCODED_IP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAW_HTML`
* **ABAP Implementation:** [/skyl/cl_no_raw_html.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raw_html.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5172)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5172)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_RAW_HTML&title=%5BBug%5D%3A%20Issue%20in%20no-raw-html)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-raw-html)**
