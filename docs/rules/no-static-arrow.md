---
title: "Call Static Methods with Class Component Selector (=>)"
description: "Avoid invoking static methods via instance arrow (->); call directly via class selector (=>) in ABAP Cloud."
keywords: "no-static-arrow, static methods, class component selector, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-static-arrow"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1092"
---

# Call Static Methods with Class Component Selector (=>)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_STATIC_ARROW" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1092" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid calling static methods via instance arrow (->).

> **ATC Finding Message:** `Call static method using => instead of ->`

## Rationale

Invoking a static method through an instance dereference arrow (->) gives the misleading impression that polymorphic dynamic dispatch is occurring, even though the call is bound statically at compile time. It also introduces an unnecessary dependency on an instantiated object reference that could be initial, obscuring actual program architecture and confusing static call-graph analyzers. Clean ABAP requires using the class component selector (=>) directly on the defining class name, which clarifies static binding and improves ABAP Cloud readiness.

### Non-Compliant

```abap
DATA lo_tax_calculator TYPE REF TO zcl_tax_calculator.
lo_tax_calculator->calculate_vat_amount( iv_net_amount = lv_net_amount ).
```

### Compliant

```abap
zcl_tax_calculator=>calculate_vat_amount( iv_net_amount = lv_net_amount ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_STATIC_ARROW

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_ARROW
```

### Static Method Resolution

The check inspects method call tokens containing `->` and uses ABAP Run-Time Type Identification (RTTI) to verify whether the target method is declared as a static `CLASS-METHODS`. Because RTTI requires local type descriptor resolution, this rule operates with `remote_enablement = abap_false`.

The `STATICCL` QuickFix resolves the defining class name and replaces the instance dereference with `class_name=>method_name( )`. Suppress false positives with `"#EC NO_STATIC_ARROW`.


## Related Rules

* [Design Classes with Instance Methods and Interfaces Instead of Static-Only Utilities](/rules/no-static-cls) — <code>#EC NO_STATIC_CLS</code>
* [Name Static Factory Methods CREATE_* When They Return Their Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Replace IS INSTANCE OF and CASE TYPE OF with Polymorphism](/rules/no-instance-of) — <code>#EC NO_INSTANCE_OF</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_STATIC_ARROW`
* **ABAP Implementation:** [/skyl/cl_no_static_arrow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_static_arrow.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1092)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1092)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_STATIC_ARROW&title=%5BBug%5D%3A%20Issue%20in%20no-static-arrow)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-static-arrow)**
