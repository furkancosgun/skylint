---
description: "Avoid reading environment system fields (sy-sysid, etc.)"
---

# Avoid Hardcoding System & Tenant Environment Checks

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC HARDCODED_ENV" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid reading environment system fields (sy-sysid, etc.).

> **ATC Finding Message:** `Avoid reading environment system fields (sy-sysid, sy-uname, etc.)`

## Rationale

Hardcoding system identifiers (sy-sysid), client numbers (sy-mandt), host names (sy-host), or database systems (sy-dbsys) against literal values violates cloud multi-tenancy and breaks during staging, system copy, or migration. Use feature toggles, switch frameworks, or customizing instead.

### Non-Compliant

```abap
IF sy-sysid = 'PRD' OR sy-mandt = '100'.
  enable_production_mode( ).
ENDIF.
```

### Compliant

```abap
IF is_feature_enabled( c_features-prod_mode ) = abap_true.
  enable_production_mode( ).
ENDIF.
```

## Transformation

```diff
- IF sy-sysid = 'PRD' OR sy-mandt = '100'.
-   enable_production_mode( ).
- ENDIF.
+ IF is_feature_enabled( c_features-prod_mode ) = abap_true.
+   enable_production_mode( ).
+ ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_SYSID` | `Boolean` | <code>true</code> |
| `CHECK_MANDT` | `Boolean` | <code>true</code> |
| `CHECK_HOST` | `Boolean` | <code>true</code> |
| `CHECK_DBSYS` | `Boolean` | <code>true</code> |
| `CHECK_OPSYS` | `Boolean` | <code>true</code> |
| `CHECK_UNAME` | `Boolean` | <code>true</code> |
| `ONLY_CONDITIONAL` | `Boolean` | <code>false</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  no-hardcoded-env-checks:
    enabled: true
    severity: warning
    attributes:
      checkSysid: true
      checkMandt: true
      checkHost: true
      checkDbsys: true
      checkOpsys: true
      checkUname: true
      onlyConditional: false
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC HARDCODED_ENV

" SAP CI_ prefix format:
... "#EC CI_HARDCODED_ENV
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_HARDCODED_ENV`
* **Implementation File:** [zcl_skylint_no_hardcoded_env.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_hardcoded_env.clas.abap)
