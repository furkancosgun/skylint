---
title: "Prefer Interface Segregation (Small, Focused Interfaces)"
description: "Prefer Interface Segregation (Small, Focused Interfaces) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-intf-segreg, clean-abap"
category: "clean-abap"
ruleId: "pref-intf-segreg"
---

# Prefer Interface Segregation (Small, Focused Interfaces)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_INTF_SEGREG" />
  <Badge type="info" text="Remote Enabled" />
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

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_INTF_SEGREG`
* **Implementation File:** [zcl_skylint_pref_intf_segreg.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_intf_segreg.clas.abap)
