---
title: "Avoid CHECK Statements Inside and Outside Iteration Loops"
description: "Avoid ambiguous CHECK statements and replace them with explicit IF CONTINUE or IF RETURN guard clauses in Clean ABAP."
keywords: "no-check-stmt, CHECK statement, guard clause, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-check-stmt"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L766"
---

# Avoid CHECK Statements Inside and Outside Iteration Loops

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CHECK_IN_LOOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L766" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid CHECK statements; prefer IF with RETURN or CONTINUE.

> **ATC Finding Messages:**
> - `Avoid CHECK inside loop; use IF ... CONTINUE instead`
> - `Avoid CHECK outside loop; use IF ... RETURN instead`

## Rationale

The CHECK statement exhibits dual, context-dependent semantics in ABAP: inside a loop (LOOP, DO, WHILE) it functions as CONTINUE to cycle iteration, whereas outside loops it abruptly acts as RETURN from the procedure. This duality creates subtle defects during code refactoring when code containing CHECK is extracted into or moved outside a loop block. Clean ABAP rules strictly prohibit CHECK, recommending explicit guard clauses such as IF NOT ( ... ) CONTINUE inside loops or IF NOT ( ... ) RETURN outside loops. The check reports NO_CHK_LP or NO_CHK_OUT and provides automated quickfixes for both scenarios.

### Non-Compliant

```abap
LOOP AT lt_invoices INTO ls_invoice.
  CHECK ls_invoice-payment_status = 'PAID'.
  process_settlement( ls_invoice ).
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_invoices INTO ls_invoice.
  IF ls_invoice-payment_status <> 'PAID'.
    CONTINUE.
  ENDIF.
  process_settlement( ls_invoice ).
ENDLOOP.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_IN_LOOP` | `Boolean` | <code>true</code> | Detect CHECK statements within loops (LOOP, DO, WHILE) and propose IF NOT ... CONTINUE guard clauses. |
| `CHECK_OUTSIDE_LOOP` | `Boolean` | <code>true</code> | Detect CHECK statements outside loops and propose IF NOT ... RETURN guard clauses. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CHECK_IN_LOOP

" SAP CI_ prefix format:
... "#EC CI_NO_CHECK_IN_LOOP
```

### Contextual Semantics and QuickFixes

`CHECK` has unpredictable behavior when moved between contexts:

| Context | CHECK Behavior | Clean ABAP Replacement | QuickFix |
|---|---|---|---|
| Inside Loop (`LOOP`, `DO`, `WHILE`) | Cycles to next iteration | `IF NOT ( cond ). CONTINUE. ENDIF.` | `IFGUARD` |
| Outside Loop (Method Body) | Exits current procedure | `IF NOT ( cond ). RETURN. ENDIF.` | `IFRET` |

The check provides two distinct finding codes: `NO_CHK_LP` (suppress with `"#EC NO_CHECK_IN_LOOP`) and `NO_CHK_OUT` (suppress with `"#EC NO_CHECK_OUTSIDE_LOOP`). Both behaviors are configurable via attributes `CHECK_IN_LOOP` and `CHECK_OUTSIDE_LOOP`.


## Related Rules

* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid Comparing Boolean Method Calls to abap_true or abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>
* [Avoid Yoda Conditions by Placing Variables Before Literals](/rules/no-yoda-cond) — <code>#EC NO_YODA_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CHECK_STMT`
* **ABAP Implementation:** [/skyl/cl_no_check_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_check_stmt.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 766)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L766)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CHECK_STMT&title=%5BBug%5D%3A%20Issue%20in%20no-check-stmt)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-check-stmt)**
