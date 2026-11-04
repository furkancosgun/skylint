---
title: "Avoid Hardcoded and Unescaped Raw HTML in Source Code"
description: "Prevent Cross-Site Scripting (XSS) vulnerabilities by detecting raw HTML string concatenation in ABAP source code. Enforce SAP Fiori and cl_abap_format escaping."
keywords: "XSS ABAP, Raw HTML Security SAP, cl_abap_format escape_html, Clean Core UI Separation"
category: "security"
ruleId: "no-raw-html"
---

# Avoid Hardcoded and Unescaped Raw HTML in Source Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_RAW_HTML" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid raw unescaped HTML tags in strings and templates.

> **ATC Finding Message:** `Avoid hardcoded raw HTML; use UI5, BSP, or cl_abap_format/escape to prevent XSS`

## Rationale

Embedding raw HTML markup strings (`<div>`, `<script>`, `<table>`) directly in ABAP source code creates Cross-Site Scripting (XSS) vulnerabilities (OWASP A03 / CWE-79) and couples backend logic to user interface rendering. When dynamic values are concatenated into raw HTML without strict escaping, malicious scripts can be executed in the user's browser session.

**Best Practice:** Separate presentation from logic using SAP Fiori / SAPUI5, BSP extensions, or use `cl_abap_format` / `escape( ... format = cl_abap_format=>e_html_text )` to sanitize HTML output.

### Non-Compliant

```abap
" Anti-pattern: Concatenating unescaped user data into raw HTML
DATA(lv_html) = |<div class="user-info"><b>{ lv_name }</b></div>|.
```

### Compliant

```abap
" Clean ABAP: Use UI framework or encode output to prevent XSS
DATA(lv_safe_name) = escape( val = lv_name format = cl_abap_format=>e_html_text ).
DATA(lv_html) = |<div class="user-info"><b>{ lv_safe_name }</b></div>|. "#EC NO_RAW_HTML
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SCRIPTS` | `Boolean` | <code>true</code> | Detect high-risk script and iframe HTML tags |
| `CHECK_TAGS` | `Boolean` | <code>true</code> | Detect structural HTML tags (div, table, form, etc.) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAW_HTML

" SAP CI_ prefix format:
... "#EC CI_NO_RAW_HTML
```


## Related Rules

* [Avoid Hardcoded HTTP, HTTPS, and FTP URLs in Source Code](/rules/no-hardcoded-url) — <code>#EC NO_HARDCODED_URL</code>
* [Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code](/rules/no-hardcoded-ip) — <code>#EC NO_HARDCODED_IP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAW_HTML`
* **Implementation File:** [#skyl#cl_no_raw_html.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raw_html.clas.abap)
