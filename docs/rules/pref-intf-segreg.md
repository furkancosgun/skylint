---
title: "Prefer Small, Role-Based Interfaces (Interface Segregation)"
description: "Interface Segregation for ABAP: keep SAP interface contracts small and role-based so mocks, dependency injection and ATC reviews stay manageable."
keywords: "interface segregation ABAP, ABAP interface methods, Clean ABAP ISP, SAP ATC, pref-intf-segreg"
category: "clean-abap"
ruleId: "pref-intf-segreg"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4050"
---

# Prefer Small, Role-Based Interfaces (Interface Segregation)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_INTF_SEGREG" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4050" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer interface segregation (small interfaces).

> **ATC Finding Message:** `Interface has too many methods; prefer interface segregation`

## Rationale

An interface with more than a handful of methods forces every implementer and every test double to depend on behaviour it never uses, so one change ripples through unrelated classes. Splitting such a contract into small, role-based interfaces keeps implementations swappable, makes mocking trivial (one or two methods instead of six) and turns each interface into a readable, testable capability. The check counts METHODS and CLASS-METHODS declarations per interface block and reports the interface once the count exceeds MAX_METHODS, which keeps the threshold tuning-free for most teams.

### Non-Compliant

```abap
INTERFACE lif_order_service.
  METHODS create_order.
  METHODS read_order.
  METHODS update_order.
  METHODS delete_order.
  METHODS archive_order.
  METHODS print_order.
ENDINTERFACE.
```

### Compliant

```abap
INTERFACE lif_order_maintenance.
  METHODS create_order.
  METHODS update_order.
  METHODS delete_order.
ENDINTERFACE.

INTERFACE lif_order_reporting.
  METHODS read_order.
  METHODS print_order.
ENDINTERFACE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_METHODS` | `Integer` | <code>5</code> | Maximum number of METHODS/CLASS-METHODS declarations per interface before a finding is raised (default 5, so six or more methods trigger). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_INTF_SEGREG

" SAP CI_ prefix format:
... "#EC CI_PREF_INTF_SEGREG
```

### How the threshold is evaluated

The rule counts every `METHODS` and `CLASS-METHODS` declaration inside one `INTERFACE ... ENDINTERFACE` block and reports a **single** finding (`PREF_INTFS`) on the interface header when that count is greater than `MAX_METHODS` (default `5`, so six methods trigger).

| Interface content | Counted |
| --- | --- |
| `METHODS read_order.` | yes |
| `CLASS-METHODS create_default.` | yes |
| `CONSTANTS c_max_items TYPE i.` | no |
| `TYPES ty_rows TYPE STANDARD TABLE OF ...` | no |
| `DATA mo_reader TYPE REF TO lif_reader.` | no |

Only the interface definition is analysed; implementing classes are never reported.

### Tuning

- Keep `MAX_METHODS` above `0`; very low values (for example `2`) effectively force one interface per capability, which is a reasonable target for new Cloud-ready code but disruptive for legacy projects.
- Generated proxy contracts or vendor interfaces that cannot be split can be suppressed with `"#EC PREF_INTF_SEGREG` on the `INTERFACE` statement.
- The check is token based and needs no RTTI, so it also runs in remote ATC scenarios.


## Related Rules

* [Encapsulate Public Class Attributes and Interface Variables](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>
* [Declare Instance Constructor in PUBLIC SECTION Regardless of Instantiation Scope](/rules/pref-pub-ctor) — <code>#EC PREF_PUB_CTOR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_INTF_SEGREG`
* **ABAP Implementation:** [/skyl/cl_pref_intf_segreg.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_intf_segreg.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4050)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4050)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_INTF_SEGREG&title=%5BBug%5D%3A%20Issue%20in%20pref-intf-segreg)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-intf-segreg)**
