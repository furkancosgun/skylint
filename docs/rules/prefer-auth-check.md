# Ensure AUTHORITY-CHECK Before Sensitive Operations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: AUTH_CHECK" />
</div>

## Overview

Call Transaction Authority Check.

> **ATC Finding Message:** `CALL TRANSACTION must be protected with AUTHORITY-CHECK`

## Rationale

Omitting authorization checks leaves critical business data and actions exposed to unauthorized users. Always verify permissions before selecting or modifying protected resources.

### Non-Compliant

```abap
CALL TRANSACTION 'VA01'.
```

### Compliant

```abap
CALL TRANSACTION 'VA01' WITH AUTHORITY-CHECK.
```

## Transformation

```diff
- CALL TRANSACTION 'VA01'.
+ CALL TRANSACTION 'VA01' WITH AUTHORITY-CHECK.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-auth-check:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC AUTH_CHECK

" SAP CI_ prefix format:
... "#EC CI_AUTH_CHECK
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_AUTH_CHECK`
* **Finding Code:** `AUTH_CHECK`
* **Implementation File:** [zcl_skylint_pref_auth_check.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_auth_check.clas.abap)
