---
title: "Escape ABAP SQL Host Variables and Table Targets with @"
description: "Detect ABAP SQL statements whose INTO, APPENDING or OF TABLE targets are not escaped with @ - strict SQL mode readiness for ABAP Cloud and S/4HANA."
keywords: "ABAP strict SQL mode, @ escaping host variables, SELECT INTO TABLE, pref-strict-sql, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-strict-sql"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4943"
---

# Escape ABAP SQL Host Variables and Table Targets with @

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_STRICT_SQL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4943" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer strict SQL; escape host variables and targets with @.

> **ATC Finding Message:** `Use strict SQL syntax; escape host variables and targets with @`

## Rationale

ABAP SQL strict mode, which is mandatory in ABAP Cloud and for new S/4HANA development, requires every host variable, host expression and internal table target to be marked with the escape character @ so the compiler can separate ABAP operands from database columns. Without the escape a statement either fails in strict mode or silently falls back to the classic variant, where a same-named DDIC column shadows the local variable and the result is hard to predict. The check inspects the operand after INTO, APPENDING TABLE, OF TABLE and FIELDS OF TABLE, including the comma-separated INTO ( ... ) list form, and reports PREF_SQL so strict mode compliance grows statement by statement. The escape also documents intent for reviewers: @lt_orders is unambiguously an ABAP table, not a database object.

### Non-Compliant

```abap
DATA lt_open_orders TYPE STANDARD TABLE OF zsales_order.
SELECT sales_order_id, customer_id FROM zsales_order
  INTO TABLE lt_open_orders
  WHERE status = 'OPEN'.
```

### Compliant

```abap
DATA lt_open_orders TYPE STANDARD TABLE OF zsales_order.
SELECT sales_order_id, customer_id FROM zsales_order
  INTO TABLE @lt_open_orders
  WHERE status = 'OPEN'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_STRICT_SQL

" SAP CI_ prefix format:
... "#EC CI_PREF_STRICT_SQL
```

## Inspected target positions

| Statement form | Operand that must start with `@` |
| --- | --- |
| `INTO TABLE target` | `target` |
| `APPENDING TABLE target` | `target` |
| `... OF TABLE target` | `target` |
| `FIELDS OF target` | `target` |
| `INTO target` | `target` |
| `INTO ( operand_a, operand_b )` | every operand inside the parentheses |

## Notes

- Only statements classified as database access are inspected, so `READ TABLE`, `APPEND` and other internal table operations are never reported.
- The escape character must be the first character of the operand: `@DATA(lt_orders)` and `@ls_order` pass, while `DATA(lt_orders)` and `ls_order` are reported.
- Suppress a single statement with `"#EC PREF_STRICT_SQL` when classic SQL is unavoidable, for example a client-dependent `SELECT` that needs an explicit `ORDER BY`.
- The rule only checks the target side. Unescaped comparison operands in the `WHERE` clause are a separate migration step and are not part of this finding.


## Related Rules

* [Use ASSIGNING Instead of INTO with Field Symbols](/rules/no-into-fs) — <code>#EC NO_INTO_FS</code>
* [Make MODIFY, DELETE, INSERT and UPDATE Unambiguous for Itab and Database](/rules/no-ambiguous-stmt) — <code>#EC NO_AMBIGUOUS_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_STRICT_SQL`
* **ABAP Implementation:** [/skyl/cl_pref_strict_sql.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_strict_sql.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4943)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4943)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_STRICT_SQL&title=%5BBug%5D%3A%20Issue%20in%20pref-strict-sql)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-strict-sql)**
