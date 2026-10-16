# 🤫 Suppressions & Pragmas Guide

In Clean ABAP development, static analysis rules guide quality and readability. However, in certain scenarios—such as interfacing with external legacy APIs or performance-critical micro-optimizations—deviating from a rule is intentional and necessary.

Skylint supports full **statement-level suppression** using standard ABAP pseudo-comments and modern compiler pragmas, fully compliant with **SAP ATC and Code Pal standards**.

---

## 🎯 Dual-Match Compatibility (`TAG` & `CI_TAG`)

In adherence to SAP's ATC framework design (as seen in SAP Code Pal for ABAP Cloud), Skylint check rules support **both** modern concise tags and traditional SAP `CI_` prefixed tags:

- **Concise Format:** `"#EC <TAG>"` or `##<TAG>`
- **Official SAP ATC Format:** `"#EC CI_<TAG>"` or `##CI_<TAG>`

Both formats are 100% equivalent and recognized by Skylint.

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

## 2. Using Modern Pragmas (`##...`)

Modern ABAP introduces pragmas (`##`) which are recognized directly by the ABAP compiler and placed before the statement's terminating period `.`:

```abap
" Flagged by rule 'no-call-method'
CALL METHOD lo_service->process_item ##CALL_METH.

" Using the CI_ prefix
CALL METHOD lo_service->process_item ##CI_CALL_METH.
```

### Advantages of Pragmas over Pseudo-Comments
1. **Compiler Validated:** The ABAP compiler verifies pragma syntax during compilation.
2. **Refactoring Safe:** Moving or reformatting lines preserves pragmas more reliably than trailing text comments.
3. **Clean ABAP Recommended:** Clean ABAP guidelines favor compiler pragmas (`##`) over legacy pseudo-comments (`"#EC`).

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
