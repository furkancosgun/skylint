---
title: "Prefer Interface Segregation (Small, Focused Interfaces)"
description: "Prefer Interface Segregation (Small, Focused Interfaces) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-intf-segreg, clean-abap"
category: "clean-abap"
ruleId: "pref-intf-segreg"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3954"
---

# Prefer Interface Segregation (Small, Focused Interfaces)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_INTF_SEGREG" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3954" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer interface segregation (small interfaces).

> **ATC Finding Message:** `Interface has too many methods; prefer interface segregation`

## Rationale

Fat interfaces force implementers to depend on methods they do not need and make test mock creation cumbersome. Break large interfaces into small, cohesive, role-based contracts adhering to the Interface Segregation Principle (ISP).

### Non-Compliant

```abap
INTERFACE lif_everything.
  METHODS: read, write, print, send_email, archive, validate.
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE lif_reader.
  METHODS read.
ENDINTERFACE.
INTERFACE lif_writer.
  METHODS write.
ENDINTERFACE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_METHODS` | `Integer` | <code>5</code> | Maximum number of methods allowed in a single interface (Interface Segregation Principle, default: 5) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_INTF_SEGREG

" SAP CI_ prefix format:
... "#EC CI_PREF_INTF_SEGREG
```


## Related Rules

* [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>
* [Declare Constructor in PUBLIC SECTION](/rules/pref-pub-ctor) — <code>#EC PREF_PUB_CTOR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_INTF_SEGREG`
* **ABAP Implementation:** [/skyl/cl_pref_intf_segreg.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_intf_segreg.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3954)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3954)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_INTF_SEGREG&title=%5BBug%5D%3A%20Issue%20in%20pref-intf-segreg)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-intf-segreg)**
