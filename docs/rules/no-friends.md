---
title: "Avoid FRIENDS in class definitions"
description: "Avoid FRIENDS in class definitions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-friends, anti-patterns"
category: "anti-patterns"
ruleId: "no-friends"
---

# Avoid FRIENDS in class definitions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_FRIENDS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid FRIENDS in class definitions.

> **ATC Finding Message:** `Avoid FRIENDS; expose behavior via public methods`

## Rationale

FRIENDS exposes private and protected members to another class and creates a hidden bidirectional dependency. It defeats encapsulation and makes both classes harder to change independently. Expose a public method or interface instead of granting friendship.

### Non-Compliant

```abap
CLASS lcl_service DEFINITION PUBLIC FINAL FRIENDS lcl_helper CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_FRIENDS

" SAP CI_ prefix format:
... "#EC CI_NO_FRIENDS
```


## Related Rules

* [Prefer CREATE_* Prefix for Factory Methods Returning Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Limit Class Inheritance Depth (Favor Composition over Inheritance)](/rules/max-inherit) — <code>#EC MAX_INHERIT</code>
* [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_FRIENDS`
* **Implementation File:** [zcl_skylint_no_friends.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_friends.clas.abap)
