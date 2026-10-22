---
description: "Comprehensive reference and catalog for all 108 Clean ABAP, security, performance, and architecture rules in Skylint."
---

# Rules Catalog (108 Rules)

Comprehensive reference for all **108** Clean ABAP, security, performance, and architecture rules in Skylint.

::: tip Skylint at a Glance
- **108 Native ATC Rules:** 100% ABAP Cloud (Contract C1) & Steampunk Ready.
- **46 Automated QuickFixes:** Instant one-click refactoring with <kbd>Ctrl</kbd> + <kbd>1</kbd> in Eclipse ADT.
- **Zero Legacy Overhead:** Built exclusively on `IF_CI_ATC_CHECK` (no obsolete Code Inspector / SCI dependency).
:::

## Clean ABAP & Modern Syntax (41)

Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.

| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix | Remote Enabled |
|---|---|---|:---:|:---:|:---:|
| [`prefer-reduce`](/rules/prefer-reduce) | `ZCL_SKYLINT_PREF_REDUCE` | Prefer REDUCE #( ) expression over simple aggregation LOOP | `#EC PREF_REDUCE` | ⚡ Ready | ✅ Yes |
| [`prefer-tab-expr`](/rules/prefer-tab-expr) | `ZCL_SKYLINT_PREF_TAB_EXPR` | Prefer table expression itab[ ... ] over READ TABLE | `#EC PREF_TAB_EXPR` | ⚡ Ready | ✅ Yes |
| [`prefer-cond`](/rules/prefer-cond) | `ZCL_SKYLINT_PREF_COND` | Prefer COND #( ) expression over IF/ELSEIF/ELSE statement | `#EC PREF_COND` | ⚡ Ready | ✅ Yes |
| [`prefer-switch`](/rules/prefer-switch) | `ZCL_SKYLINT_PREF_SWITCH` | Prefer SWITCH #( ) expression over CASE statement | `#EC PREF_SWITCH` | ⚡ Ready | ✅ Yes |
| [`prefer-lines`](/rules/prefer-lines) | `ZCL_SKYLINT_PREF_LINES` | Prefer lines( ) over DESCRIBE TABLE ... LINES | `#EC LINES` | ⚡ Ready | ✅ Yes |
| [`prefer-is-not`](/rules/prefer-is-not) | `ZCL_SKYLINT_PREF_IS_NOT` | Prefer IS NOT over NOT ... IS | `#EC IS_NOT` | ⚡ Ready | ✅ Yes |
| [`prefer-string-template`](/rules/prefer-string-template) | `ZCL_SKYLINT_PREF_STR_TMPL` | Prefer string templates over CONCATENATE | `#EC STR_TMPL` | ⚡ Ready | ✅ Yes |
| [`prefer-line-exists`](/rules/prefer-line-exists) | `ZCL_SKYLINT_PREF_LINE_EXISTS` | Prefer line_exists( ) over READ TABLE with NO FIELDS | `#EC LINE_EXISTS` | — | ✅ Yes |
| [`prefer-return`](/rules/prefer-return) | `ZCL_SKYLINT_PREF_RETURN` | Prefer RETURN over EXIT outside loop constructs | `#EC RETURN` | ⚡ Ready | ✅ Yes |
| [`prefer-merged-ifs`](/rules/prefer-merged-ifs) | `ZCL_SKYLINT_PREF_MERGE_IFS` | Merge consecutive nested IF blocks using boolean AND | `#EC MERGE_IFS` | — | ✅ Yes |
| [`prefer-symbol-operators`](/rules/prefer-symbol-operators) | `ZCL_SKYLINT_PREF_SYMBOL_OP` | Prefer symbolic operators over textual EQ, NE, LT, GT | `#EC SYMBOL_OP` | ⚡ Ready | ✅ Yes |
| [`prefer-new-operator`](/rules/prefer-new-operator) | `ZCL_SKYLINT_PREF_NEW_OP` | Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION | `#EC NEW_OP` | ⚡ Ready | ✅ Yes |
| [`prefer-xsdbool`](/rules/prefer-xsdbool) | `ZCL_SKYLINT_PREF_XSDBOOL` | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `#EC XSDBOOL` | ⚡ Ready | ✅ Yes |
| [`prefer-fully-typed`](/rules/prefer-fully-typed) | `ZCL_SKYLINT_PREF_FULL_TYPED` | Enforce fully typed constant declarations | `#EC FULL_TYPED` | — | ✅ Yes |
| [`prefer-corresponding`](/rules/prefer-corresponding) | `ZCL_SKYLINT_PREF_CORRESP` | Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `#EC CORRESP` | ⚡ Ready | ✅ Yes |
| [`prefer-returning`](/rules/prefer-returning) | `ZCL_SKYLINT_PREF_RETURNING` | Prefer RETURNING over single EXPORTING | `#EC RETURNING` | — | ✅ Yes |
| [`prefer-class-exceptions`](/rules/prefer-class-exceptions) | `ZCL_SKYLINT_PREF_CLASS_EXC` | Prefer Class-Based Exceptions over Classic EXCEPTIONS | `#EC CLASS_EXC` | — | ✅ Yes |
| [`prefer-final-class`](/rules/prefer-final-class) | `ZCL_SKYLINT_PREF_FINAL_CLS` | Prefer FINAL classes and methods by default | `#EC FINAL_CLS` | ⚡ Ready | ✅ Yes |
| [`prefer-insert-into`](/rules/prefer-insert-into) | `ZCL_SKYLINT_PREF_INSERT` | Prefer INSERT ... INTO TABLE over APPEND for table safety | `#EC INSERT_INTO` | ⚡ Ready | ✅ Yes |
| [`prefer-predicate-names`](/rules/prefer-predicate-names) | `ZCL_SKYLINT_PREF_PRED_NAME` | Enforce predicate naming (IS_, HAS_) on boolean methods | `#EC PRED_NAME` | — | ✅ Yes |
| [`prefer-string-functions`](/rules/prefer-string-functions) | `ZCL_SKYLINT_PREF_STR_FUNC` | Detect obsolete string statements; prefer built-in functions | `#EC STR_FUNC` | ⚡ Ready | ✅ Yes |
| [`prefer-calc-assign-op`](/rules/prefer-calc-assign-op) | `ZCL_SKYLINT_PREF_CALC_OP` | Prefer calculation assignment operators (+=, -=, *=, /=) | `#EC CALC_ASSIGN` | ⚡ Ready | ✅ Yes |
| [`prefer-early-return`](/rules/prefer-early-return) | `ZCL_SKYLINT_PREF_EARLY_RET` | Prefer early return or continue over nested IF blocks | `#EC EARLY_RETURN` | — | ✅ Yes |
| [`prefer-decl-order`](/rules/prefer-decl-order) | `ZCL_SKYLINT_PREF_DECL_ORDER` | Enforce declaration order (TYPES, CONSTANTS, DATA, FS) | `#EC DECL_ORDER` | — | ✅ Yes |
| [`prefer-case`](/rules/prefer-case) | `ZCL_SKYLINT_PREF_CASE` | Use CASE instead of IF when checking multiple values | `#EC PREF_CASE` | — | ✅ Yes |
| [`max-one-statement`](/rules/max-one-statement) | `ZCL_SKYLINT_MAX_ONE_STMT` | Max One Statement Per Line | `#EC ONE_STMT` | — | ✅ Yes |
| [`prefer-inline`](/rules/prefer-inline) | `ZCL_SKYLINT_PREF_INLINE` | Prefer Inline Declarations | `#EC PREFER_INLINE` | — | ✅ Yes |
| [`prefer-final-data`](/rules/prefer-final-data) | `ZCL_SKYLINT_PREF_FINAL_DATA` | Declare inline variables as FINAL when never written again | `#EC PREF_FINAL` | ⚡ Ready | ✅ Yes |
| [`prefer-message-class`](/rules/prefer-message-class) | `ZCL_SKYLINT_PREF_MSG_CLS` | Use a message class instead of inline message text | `#EC MSG_CLASS` | — | ❌ No |
| [`prefer-inline-cast`](/rules/prefer-inline-cast) | `ZCL_SKYLINT_PREF_INL_CAST` | Inline a CAST helper that is only read once | `#EC INLINE_CAST` | ⚡ Ready | ✅ Yes |
| [`prefer-public-constructor`](/rules/prefer-public-constructor) | `ZCL_SKYLINT_PREF_PUB_CTOR` | Declare Constructor in PUBLIC SECTION | `#EC PUB_CTOR` | — | ✅ Yes |
| [`prefer-definitions-top`](/rules/prefer-definitions-top) | `ZCL_SKYLINT_PREF_DEF_TOP` | Place definitions at beginning of routine | `#EC DEF_TOP` | — | ✅ Yes |
| [`max-one-method-parameter-per-line`](/rules/max-one-method-parameter-per-line) | `ZCL_SKYLINT_MAX_PARAM_LINE` | Max one method parameter definition per line | `#EC MAX_PARAM_LINE` | — | ✅ Yes |
| [`prefer-is-initial`](/rules/prefer-is-initial) | `ZCL_SKYLINT_PREF_IS_INITIAL` | Prefer IS [NOT] INITIAL over lines( ) or empty literals | `#EC PREF_INIT` | ⚡ Ready | ✅ Yes |
| [`prefer-cast`](/rules/prefer-cast) | `ZCL_SKYLINT_PREF_CAST` | Prefer modern CAST #( ) expression over ?= | `#EC PREF_CAST` | ⚡ Ready | ✅ Yes |
| [`prefer-naming`](/rules/prefer-naming) | `ZCL_SKYLINT_PREF_NAMING` | Standard Naming Conventions | `#EC NAMING` | — | ✅ Yes |
| [`bad-indent`](/rules/bad-indent) | `ZCL_SKYLINT_NO_BAD_INDENT` | Bad Statement Indentation | `#EC BAD_INDENT` | ⚡ Ready | ✅ Yes |
| [`prefer-join-type`](/rules/prefer-join-type) | `ZCL_SKYLINT_PREF_JOIN_TYPE` | Prefer an explicit JOIN type such as INNER JOIN | `#EC JOIN_TYPE` | ⚡ Ready | ✅ Yes |
| [`prefer-standard-table`](/rules/prefer-standard-table) | `ZCL_SKYLINT_PREF_STD_TABLE` | Prefer explicit TYPE STANDARD TABLE OF over TYPE TABLE OF | `#EC PREF_STD_TABLE` | ⚡ Ready | ✅ Yes |
| [`prefer-is-supplied`](/rules/prefer-is-supplied) | `ZCL_SKYLINT_PREF_IS_SUPPLIED` | Prefer IS SUPPLIED over the obsolete IS REQUESTED | `#EC PREF_IS_SUPPLIED` | ⚡ Ready | ✅ Yes |
| [`prefer-sy`](/rules/prefer-sy) | `ZCL_SKYLINT_PREF_SY` | Prefer the short system field alias SY over SYST | `#EC PREF_SY` | ⚡ Ready | ✅ Yes |

## Anti-Patterns & Bad Practices (39)

Discouraged language constructs, legacy statements, and redundant syntax.

| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix | Remote Enabled |
|---|---|---|:---:|:---:|:---:|
| [`no-call-method`](/rules/no-call-method) | `ZCL_SKYLINT_NO_CALL_METHOD` | Avoid static CALL METHOD statements | `#EC CALL_METH` | ⚡ Ready | ✅ Yes |
| [`no-default-key`](/rules/no-default-key) | `ZCL_SKYLINT_NO_DEFAULT_KEY` | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `#EC DEFAULT_KEY` | ⚡ Ready | ✅ Yes |
| [`no-me-reference`](/rules/no-me-reference) | `ZCL_SKYLINT_NO_ME_REFERENCE` | Avoid self-reference ME-> | `#EC ME` | — | ✅ Yes |
| [`no-redundant-method-call`](/rules/no-redundant-method-call) | `ZCL_SKYLINT_NO_REDUNDANT_CALL` | Omit redundant EXPORTING and RECEIVING in method calls | `#EC EXPORTING` | ⚡ Ready | ❌ No |
| [`no-chained-statements`](/rules/no-chained-statements) | `ZCL_SKYLINT_NO_CHAINED_STMT` | Avoid chained declarations and chained assignments | `#EC CHAIN_DECL` | ⚡ Ready | ✅ Yes |
| [`no-boolean-comparison`](/rules/no-boolean-comparison) | `ZCL_SKYLINT_NO_BOOL_COMPARE` | Avoid comparing boolean method calls to boolean literals | `#EC BOOL_COMPARE` | ⚡ Ready | ✅ Yes |
| [`no-check-statement`](/rules/no-check-statement) | `ZCL_SKYLINT_NO_CHECK_STMT` | Avoid CHECK statements; prefer IF with RETURN or CONTINUE | `#EC CHECK_STMT` | ⚡ Ready | ✅ Yes |
| [`no-empty-block`](/rules/no-empty-block) | `ZCL_SKYLINT_NO_EMPTY_BLOCK` | Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.) | `#EC EMPTY_BLOCK` | — | ✅ Yes |
| [`no-duplicate-conditions`](/rules/no-duplicate-conditions) | `ZCL_SKYLINT_NO_DUP_COND` | Avoid duplicate branch conditions in IF and CASE | `#EC DUP_COND` | — | ✅ Yes |
| [`no-unreachable-code`](/rules/no-unreachable-code) | `ZCL_SKYLINT_NO_UNREACHABLE` | Detect unreachable code after jump or exit statements | `#EC UNREACHABLE` | ⚡ Ready | ✅ Yes |
| [`no-single-when`](/rules/no-single-when) | `ZCL_SKYLINT_NO_SINGLE_WHEN` | Avoid CASE statements with only one WHEN branch | `#EC SINGLE_WHEN` | — | ✅ Yes |
| [`no-yoda-conditions`](/rules/no-yoda-conditions) | `ZCL_SKYLINT_NO_YODA_COND` | Avoid Yoda conditions in comparison expressions | `#EC YODA_COND` | ⚡ Ready | ✅ Yes |
| [`no-static-via-instance`](/rules/no-static-via-instance) | `ZCL_SKYLINT_NO_STATIC_ARROW` | Avoid calling static methods via instance arrow (->) | `#EC STATIC_ARROW` | ⚡ Ready | ❌ No |
| [`no-public-attributes`](/rules/no-public-attributes) | `ZCL_SKYLINT_NO_PUBLIC_ATTR` | Avoid mutable public attributes in classes | `#EC PUBLIC_ATTR` | — | ✅ Yes |
| [`no-obsolete-statements`](/rules/no-obsolete-statements) | `ZCL_SKYLINT_NO_OBSOLETE` | Avoid obsolete statements (MOVE, REFRESH, FORM, etc.) | `#EC OBSOLETE` | ⚡ Ready | ✅ Yes |
| [`no-list-processing`](/rules/no-list-processing) | `ZCL_SKYLINT_NO_LIST_PROC` | Prohibit classic list processing statements | `#EC LIST_PROC` | — | ✅ Yes |
| [`no-scope-leak`](/rules/no-scope-leak) | `ZCL_SKYLINT_NO_SCOPE_LEAK` | Avoid variable usage outside its declaring control block | `#EC SCOPE_LEAK` | — | ✅ Yes |
| [`no-self-assignment`](/rules/no-self-assignment) | `ZCL_SKYLINT_NO_SELF_ASSIGN` | Detect Identical Self Assignments | `#EC SELF_ASSIGN` | ⚡ Ready | ✅ Yes |
| [`no-magic-numbers`](/rules/no-magic-numbers) | `ZCL_SKYLINT_NO_MAGIC_NUMBERS` | Avoid magic numbers in code; use named constants | `#EC MAGIC_NUMBERS` | — | ✅ Yes |
| [`no-like-objects`](/rules/no-like-objects) | `ZCL_SKYLINT_NO_LIKE_OBJECTS` | Avoid LIKE referencing data objects; use explicit TYPE | `#EC LIKE_OBJECTS` | — | ✅ Yes |
| [`no-static-classes`](/rules/no-static-classes) | `ZCL_SKYLINT_NO_STATIC_CLS` | Avoid static-only classes; use instantiable classes | `#EC STATIC_CLS` | — | ✅ Yes |
| [`no-interface-data`](/rules/no-interface-data) | `ZCL_SKYLINT_NO_INTF_DATA` | Avoid mutable DATA in interfaces; allow only CONSTANTS | `#EC INTF_DATA` | — | ✅ Yes |
| [`no-message-raising`](/rules/no-message-raising) | `ZCL_SKYLINT_NO_MSG_RAISING` | Avoid MESSAGE ... RAISING; use class-based exceptions | `#EC MSG_RAISING` | — | ✅ Yes |
| [`no-nested-try`](/rules/no-nested-try) | `ZCL_SKYLINT_NO_NESTED_TRY` | Avoid nested TRY blocks; extract to helper methods | `#EC NESTED_TRY` | — | ✅ Yes |
| [`no-unused-variables`](/rules/no-unused-variables) | `ZCL_SKYLINT_NO_UNUSED_VARS` | Detect unused local variables and field symbols | `#EC NEEDED` | — | ✅ Yes |
| [`no-param-escape`](/rules/no-param-escape) | `ZCL_SKYLINT_NO_PARAM_ESCAPE` | Avoid unnecessary parameter escape (!param) | `#EC PARAM_ESCAPE` | ⚡ Ready | ✅ Yes |
| [`no-inline-length`](/rules/no-inline-length) | `ZCL_SKYLINT_NO_INLINE_LEN` | Avoid inline length specification in declarations | `#EC PAREN_LEN` | ⚡ Ready | ✅ Yes |
| [`no-dash-in-names`](/rules/no-dash-in-names) | `ZCL_SKYLINT_NO_DASH_IN_NAMES` | No Dashes in Variable and Form Names | `#EC NO_DASH` | — | ✅ Yes |
| [`no-friends`](/rules/no-friends) | `ZCL_SKYLINT_NO_FRIENDS` | Avoid FRIENDS in class definitions | `#EC FRIENDS` | — | ✅ Yes |
| [`no-exception-overlap`](/rules/no-exception-overlap) | `ZCL_SKYLINT_NO_EXC_OVERLAP` | Classic EXCEPTIONS must not overlap | `#EC EXC_OVERLAP` | — | ✅ Yes |
| [`no-many-parentheses`](/rules/no-many-parentheses) | `ZCL_SKYLINT_NO_MANY_PARENS` | Remove redundant parentheses | `#EC MANY_PARENS` | ⚡ Ready | ✅ Yes |
| [`no-unnecessary-return`](/rules/no-unnecessary-return) | `ZCL_SKYLINT_NO_UNNEC_RETURN` | Omit unnecessary RETURN at end of routine | `#EC NO_UNNEC_RETURN` | ⚡ Ready | ✅ Yes |
| [`mix-returning`](/rules/mix-returning) | `ZCL_SKYLINT_NO_MIX_RETURNING` | Do not mix RETURNING with EXPORTING or CHANGING | `#EC NO_MIX_RETURNING` | — | ✅ Yes |
| [`method-overwrites-builtin`](/rules/method-overwrites-builtin) | `ZCL_SKYLINT_NO_OVERW_BUILTIN` | Method name overwrites built-in SAP function | `#EC NO_OVERW_BUILTIN` | — | ✅ Yes |
| [`no-ignored-return-value`](/rules/no-ignored-return-value) | `ZCL_SKYLINT_NO_IGNORED_RETURN` | Disallow ignoring the return value of functional methods | `#EC NO_IGNORED_RET` | — | ❌ No |
| [`no-redundant-clear`](/rules/no-redundant-clear) | `ZCL_SKYLINT_NO_REDUNDANT_CLEAR` | Do not CLEAR or FREE variables redundantly | `#EC REDUNDANT_CLEAR` | ⚡ Ready | ✅ Yes |
| [`expand-macros`](/rules/expand-macros) | `ZCL_SKYLINT_PREF_EXPAND_MACRO` | Expand Macro Calls | `#EC EXPAND_MACROS` | ⚡ Ready | ✅ Yes |
| [`no-dead-code`](/rules/no-dead-code) | `ZCL_SKYLINT_NO_DEAD_CODE` | Detect Dead Code with Constant Condition | `#EC NO_DEAD_CODE` | ⚡ Ready | ✅ Yes |
| [`keyword-name`](/rules/keyword-name) | `ZCL_SKYLINT_NO_KEYWORD_NAME` | Avoid Using ABAP Keywords as Identifier Names | `#EC KEYWORD_NAME` | — | ✅ Yes |

## Performance & Database (7)

Database query efficiency, buffer protection, and internal table operation guidelines.

| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix | Remote Enabled |
|---|---|---|:---:|:---:|:---:|
| [`no-db-in-loop`](/rules/no-db-in-loop) | `ZCL_SKYLINT_NO_DB_IN_LOOP` | Avoid database access inside loop iterations | `#EC DB_IN_LOOP` | — | ✅ Yes |
| [`no-empty-fae`](/rules/no-empty-fae) | `ZCL_SKYLINT_NO_EMPTY_FAE` | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `#EC EMPTY_FAE` | ⚡ Ready | ✅ Yes |
| [`no-select-star`](/rules/no-select-star) | `ZCL_SKYLINT_NO_SELECT_STAR` | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `#EC SELECT_STAR` | — | ✅ Yes |
| [`prefer-order-by`](/rules/prefer-order-by) | `ZCL_SKYLINT_PREF_ORDER_BY` | SELECT UP TO 1 ROWS requires ORDER BY | `#EC ORDER_BY` | — | ✅ Yes |
| [`prefer-transporting`](/rules/prefer-transporting) | `ZCL_SKYLINT_PREF_TRANSPORT` | Avoid MODIFY itab in LOOP without TRANSPORTING clause | `#EC TRANSPORTING` | — | ✅ Yes |
| [`prefer-pass-by-reference`](/rules/prefer-pass-by-reference) | `ZCL_SKYLINT_PREF_PASS_BY_REF` | Slow Parameter Passing | `#EC SLOW_PARAM` | — | ✅ Yes |
| [`no-modify-loop-table`](/rules/no-modify-loop-table) | `ZCL_SKYLINT_NO_MOD_LOOP_TAB` | Avoid mutating or sorting tables inside loops | `#EC LOOP_MODIFY` | — | ✅ Yes |

## Security & Robustness (12)

Authorizations, dynamic execution sanitation, error handling, and runtime safety.

| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix | Remote Enabled |
|---|---|---|:---:|:---:|:---:|
| [`no-sy-modify`](/rules/no-sy-modify) | `ZCL_SKYLINT_NO_SY_MODIFY` | Avoid sy-* System Variable Modification | `#EC SY_MODIFY` | — | ✅ Yes |
| [`no-dangerous-statements`](/rules/no-dangerous-statements) | `ZCL_SKYLINT_NO_DANGEROUS_STMT` | Dangerous Statements (abaplint dangerous_statement) | `#EC DANGEROUS_STMT` | — | ✅ Yes |
| [`prefer-auth-check`](/rules/prefer-auth-check) | `ZCL_SKYLINT_PREF_AUTH_CHECK` | Call Transaction Authority Check | `#EC AUTH_CHECK` | ⚡ Ready | ✅ Yes |
| [`no-catch-cx-root`](/rules/no-catch-cx-root) | `ZCL_SKYLINT_NO_CATCH_ROOT` | Catch specific exceptions instead of generic cx_root | `#EC CATCH_ROOT` | — | ✅ Yes |
| [`no-raise-cx-sy`](/rules/no-raise-cx-sy) | `ZCL_SKYLINT_NO_RAISE_CX_SY` | Avoid raising SAP internal system exceptions (cx_sy_*) | `#EC RAISE_CX_SY` | — | ✅ Yes |
| [`prefer-subrc-check`](/rules/prefer-subrc-check) | `ZCL_SKYLINT_PREF_CHECK_SUBRC` | Check sy-subrc after DB, table and string operations | `#EC CHECK_SUBRC` | — | ✅ Yes |
| [`no-client-specified`](/rules/no-client-specified) | `ZCL_SKYLINT_NO_CLIENT_SPEC` | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `#EC CLIENT_SPEC` | ⚡ Ready | ✅ Yes |
| [`no-commit-work`](/rules/no-commit-work) | `ZCL_SKYLINT_NO_COMMIT_WORK` | Avoid COMMIT and ROLLBACK in application logic | `#EC COMMIT_WORK` | — | ❌ No |
| [`no-rfc-error-handling`](/rules/no-rfc-error-handling) | `ZCL_SKYLINT_NO_RFC_ERR` | RFC calls must handle system failures | `#EC RFC_ERR` | — | ✅ Yes |
| [`no-modify-standard-tables`](/rules/no-modify-standard-tables) | `ZCL_SKYLINT_NO_MOD_STD_TABLE` | Modify Only Own Database Tables | `#EC OWN_TABLES` | — | ✅ Yes |
| [`no-dynamic-stuff`](/rules/no-dynamic-stuff) | `ZCL_SKYLINT_NO_DYNAMIC_STMT` | No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.) | `#EC NO_DYNAMIC` | — | ✅ Yes |
| [`no-hardcoded-env-checks`](/rules/no-hardcoded-env-checks) | `ZCL_SKYLINT_NO_HARDCODED_ENV` | Avoid reading environment system fields (sy-sysid, etc.) | `#EC HARDCODED_ENV` | — | ✅ Yes |

## Metrics & Complexity Limits (8)

Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.

| Rule ID | ABAP Class | Description | Pseudo-Comment | QuickFix | Remote Enabled |
|---|---|---|:---:|:---:|:---:|
| [`max-params`](/rules/max-params) | `ZCL_SKYLINT_MAX_PARAMS` | Method signature cleanliness (excessive parameter count) | `#EC MAX_PARAMS` | — | ✅ Yes |
| [`max-method-length`](/rules/max-method-length) | `ZCL_SKYLINT_MAX_METHOD_LEN` | Method Length Limit (excessive statement count) | `#EC METHOD_LEN` | — | ✅ Yes |
| [`max-nesting-depth`](/rules/max-nesting-depth) | `ZCL_SKYLINT_MAX_NESTING` | Nesting Depth Limit (excessive control block nesting) | `#EC NESTING` | — | ✅ Yes |
| [`max-cyclomatic-complexity`](/rules/max-cyclomatic-complexity) | `ZCL_SKYLINT_MAX_CYCLO_COMP` | Cyclomatic Complexity Threshold | `#EC CYCLO_COMP` | — | ✅ Yes |
| [`max-constructor-statements`](/rules/max-constructor-statements) | `ZCL_SKYLINT_MAX_CTOR_STMTS` | Keep constructors clean; avoid heavy logic and DB | `#EC CLEAN_CTOR` | — | ✅ Yes |
| [`max-inheritance-depth`](/rules/max-inheritance-depth) | `ZCL_SKYLINT_MAX_INHERIT` | Avoid deep class inheritance hierarchies | `#EC INHERIT_DEPTH` | — | ❌ No |
| [`max-attributes`](/rules/max-attributes) | `ZCL_SKYLINT_MAX_ATTRIBUTES` | Limit class member attributes to prevent God Classes | `#EC ATTRIBUTES` | — | ✅ Yes |
| [`max-line-length`](/rules/max-line-length) | `ZCL_SKYLINT_MAX_LINE_LEN` | Maximum Line Length | `#EC LINE_LEN` | — | ✅ Yes |

