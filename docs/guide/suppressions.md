---
description: "Guide to suppressing findings in Skylint using standard SAP ATC pseudo-comments and pragmas with dual-match compatibility (#EC and #EC CI_)."
---

# Suppressions Guide

In Clean ABAP development, static analysis rules guide quality and readability. However, in certain scenarios—such as interfacing with external legacy APIs or performance-critical micro-optimizations—deviating from a rule is intentional and necessary.

Skylint supports full **statement-level suppression** using standard ABAP pseudo-comments (`"#EC ..."`), fully compliant with the **SAP ATC framework and SAP Code Pal standards**.

---

## 🎯 Dual-Match Compatibility (`TAG` & `CI_TAG`)

In adherence to SAP's ATC framework design (as seen in SAP Code Pal for ABAP Cloud), Skylint check rules support **both** concise tags and traditional SAP `CI_` prefixed tags:

- **Concise Format:** `"#EC <TAG>"`
- **Official SAP ATC Format:** `"#EC CI_<TAG>"`

Both formats are 100% equivalent and recognized natively by Skylint's base framework.

---

## 1. Using Pseudo-Comments (`"#EC ..."`)

Place the pseudo-comment at the end of the flagged ABAP statement (after the period or colon):

```abap
" Flagged by rule 'prefer-lines'
DESCRIBE TABLE lt_customers LINES lv_count. "#EC LINES

" Traditional SAP ATC prefix is also recognized
DESCRIBE TABLE lt_customers LINES lv_count. "#EC CI_LINES
```

### Multiple Pseudo-Comments on One Statement
If a single statement triggers multiple checks, you can combine pseudo-comments separated by spaces or commas:

```abap
DESCRIBE TABLE lt_data LINES lv_count. "#EC LINES, NO_DESCRIBE
```

---

## 2. Pragmas vs. Pseudo-Comments in Custom ATC Checks

In SAP NetWeaver and ABAP Cloud, compiler pragmas (`##...`) are defined in the SAP Kernel repository (table `ROPTAG` / transaction `SE38`). Custom customer pragmas cannot be declared arbitrarily by custom check engines without SAP system-level registration.

Therefore, for all custom ATC check suites including Skylint:
- **Pseudo-comments (`"#EC <TAG>"`)** are the **standard, official, and guaranteed mechanism** for suppressing findings across both Eclipse ADT, SAP GUI, and CI/CD CLI scans.

---

## 3. How the Base Engine Evaluates Suppressions

Every Skylint check inherits from `zcl_skylint_check_base`. When a statement or token is reported:

1. Skylint inspects the statement's associated `pseudo_comments` table provided by the ATC framework (`if_ci_atc_source_code_provider=>ty_statement`).
2. It evaluates whether either the registered tag (e.g. `LINES`) or its `CI_` prefixed counterpart (e.g. `CI_LINES`) is attached.
3. If a match is found, the finding is suppressed automatically, preventing false alarms in your ATC run and CI/CD pipelines.

---

## 💡 Best Practices for Suppressions

::: tip Clean ABAP Guideline: Fix First, Suppress Only with Justification
1. **Always prefer fixing over suppressing:** If an automated QuickFix is available (<kbd>Ctrl</kbd> + <kbd>1</kbd>), apply it rather than hiding the finding.
2. **Document the rationale:** Whenever you add a pseudo-comment or pragma, accompany it with a brief explanatory comment explaining *why* the rule was bypassed:
   ```abap
   " External RFC interface requires classical EXPORTING syntax
   lo_proxy->call_legacy_endpoint( EXPORTING iv_data = lv_payload ) ##CI_NO_EXPORTING.
   ```
3. **Do not blanket-suppress:** Suppress only the exact offending statement. Avoid wide-ranging suppression where possible.
:::

---

## 🔍 Finding Rule Suppression Codes

Every rule in Skylint defines its specific suppression code. You can find the exact pseudo-comment or pragma code for any check:
- In the [Rules Catalog](/rules/) under each rule's documentation page.
- In Eclipse ADT: open the finding in the **ATC Result View** to see the suggested suppression code in the finding details.
