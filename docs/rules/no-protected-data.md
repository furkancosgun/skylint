---
title: "Avoid Protected Attributes"
description: "Enforce clean encapsulation by disallowing DATA in class PROTECTED SECTION."
keywords: "Clean ABAP, protected data, no-protected-data"
category: "clean-abap"
ruleId: "no-protected-data"
---

# Avoid Protected Attributes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_PROTECTED_DATA" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid declaring DATA or CLASS-DATA in PROTECTED SECTION.

> **ATC Finding Message:** `Avoid protected attributes; make them private and provide methods instead`

## Rationale

Protected data members expose internal class state to subclasses, violating encapsulation. Make attributes private and provide getter methods if needed.

### Non-Compliant

```abap
PROTECTED SECTION.
  DATA mv_count TYPE i.
```

### Compliant

```abap
PRIVATE SECTION.
  DATA mv_count TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_PROTECTED_DATA

" SAP CI_ prefix format:
... "#EC CI_NO_PROTECTED_DATA
```


## Related Rules

* [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_PROTECTED_DATA`
* **Implementation File:** [#skyl#cl_no_protected_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_protected_data.clas.abap)
