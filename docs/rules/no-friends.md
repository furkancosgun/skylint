---
description: "Avoid FRIENDS in class definitions"
---

# Avoid FRIENDS in class definitions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC FRIENDS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid FRIENDS in class definitions.

> **ATC Finding Message:** `Avoid FRIENDS; expose behavior via public methods`

## Rationale

FRIENDS grants another class access to private/protected members, breaking encapsulation. Expose behaviour through the public interface instead.

### Non-Compliant

```abap
CLASS lcl_service DEFINITION FINAL FRIENDS lcl_helper CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_service DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS execute.
ENDCLASS.
```

## Transformation

```diff
- CLASS lcl_service DEFINITION FINAL FRIENDS lcl_helper CREATE PUBLIC.
-   PUBLIC SECTION.
-     METHODS execute.
- ENDCLASS.
+ CLASS lcl_service DEFINITION FINAL CREATE PUBLIC.
+   PUBLIC SECTION.
+     METHODS execute.
+ ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC FRIENDS

" SAP CI_ prefix format:
... "#EC CI_FRIENDS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_FRIENDS`
* **Implementation File:** [zcl_skylint_no_friends.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_friends.clas.abap)
