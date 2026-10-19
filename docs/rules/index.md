# Rules Catalog (93 Rules)

Comprehensive reference for all **93** Clean ABAP, security, performance, and architecture rules in Skylint.

::: tip Skylint at a Glance
- **93 Native ATC Rules:** 100% ABAP Cloud (Contract C1) & Steampunk Ready.
- **35 Automated QuickFixes:** Instant one-click refactoring with <kbd>Ctrl</kbd> + <kbd>1</kbd> in Eclipse ADT.
- **Zero Legacy Overhead:** Built exclusively on `IF_CI_ATC_CHECK` (no obsolete Code Inspector / SCI dependency).
:::

## Clean ABAP & Modern Syntax (39)

Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`prefer-lines`](/rules/prefer-lines) | `ZCL_SKYLINT_PREF_LINES` | Prefer lines( ) over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `#EC LINES` | ⚡ Ready |
| [`prefer-is-not`](/rules/prefer-is-not) | `ZCL_SKYLINT_PREF_IS_NOT` | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `#EC IS_NOT` | ⚡ Ready |
| [`prefer-string-template`](/rules/prefer-string-template) | `ZCL_SKYLINT_PREF_STR_TMPL` | Prefer string templates over CONCATENATE | `CONCATSTR` | `#EC STR_TMPL` | ⚡ Ready |
| [`prefer-line-exists`](/rules/prefer-line-exists) | `ZCL_SKYLINT_PREF_LINE_EXISTS` | Prefer line_exists( ) over READ TABLE with NO FIELDS | `PREFLINEX` | `#EC LINE_EXISTS` | — |
| [`prefer-return`](/rules/prefer-return) | `ZCL_SKYLINT_PREF_RETURN` | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `#EC RETURN` | ⚡ Ready |
| [`prefer-merged-ifs`](/rules/prefer-merged-ifs) | `ZCL_SKYLINT_PREF_MERGE_IFS` | Merge consecutive nested IF blocks using boolean AND | `NESTEDIF` | `#EC MERGE_IFS` | — |
| [`prefer-symbol-operators`](/rules/prefer-symbol-operators) | `ZCL_SKYLINT_PREF_SYMBOL_OP` | Prefer symbolic operators over textual EQ, NE, LT, GT | `PREFEROP` | `#EC SYMBOL_OP` | ⚡ Ready |
| [`prefer-new-operator`](/rules/prefer-new-operator) | `ZCL_SKYLINT_PREF_NEW_OP` | Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION | `PREFERNEW` | `#EC NEW_OP` | ⚡ Ready |
| [`prefer-xsdbool`](/rules/prefer-xsdbool) | `ZCL_SKYLINT_PREF_XSDBOOL` | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDB` | `#EC XSDBOOL` | ⚡ Ready |
| [`prefer-fully-typed`](/rules/prefer-fully-typed) | `ZCL_SKYLINT_PREF_FULL_TYPED` | Enforce fully typed constant declarations | `FULLYTYPED` | `#EC FULL_TYPED` | — |
| [`prefer-corresponding`](/rules/prefer-corresponding) | `ZCL_SKYLINT_PREF_CORRESP` | Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `#EC CORRESP` | ⚡ Ready |
| [`prefer-returning`](/rules/prefer-returning) | `ZCL_SKYLINT_PREF_RETURNING` | Prefer RETURNING over single EXPORTING | `PREFER_RET` | `#EC RETURNING` | — |
| [`prefer-class-exceptions`](/rules/prefer-class-exceptions) | `ZCL_SKYLINT_PREF_CLASS_EXC` | Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `#EC CLASS_EXC` | — |
| [`prefer-final-class`](/rules/prefer-final-class) | `ZCL_SKYLINT_PREF_FINAL_CLS` | Prefer FINAL classes and methods by default | `NOT_FINAL` | `#EC FINAL_CLS` | ⚡ Ready |
| [`prefer-insert-into`](/rules/prefer-insert-into) | `ZCL_SKYLINT_PREF_INSERT` | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `#EC INSERT_INTO` | ⚡ Ready |
| [`max-constructor-statements`](/rules/max-constructor-statements) | `ZCL_SKYLINT_MAX_CTOR_STMTS` | Keep constructors clean; avoid heavy logic and DB | `CTOR_LOGIC` | `#EC CLEAN_CTOR` | — |
| [`no-static-classes`](/rules/no-static-classes) | `ZCL_SKYLINT_NO_STATIC_CLS` | Avoid static-only classes; use instantiable classes | `STAT_CLASS` | `#EC STATIC_CLS` | — |
| [`prefer-predicate-names`](/rules/prefer-predicate-names) | `ZCL_SKYLINT_PREF_PRED_NAME` | Enforce predicate naming (IS_, HAS_) on boolean methods | `BOOL_NAME` | `#EC PRED_NAME` | — |
| [`no-nested-try`](/rules/no-nested-try) | `ZCL_SKYLINT_NO_NESTED_TRY` | Avoid nested TRY blocks; extract to helper methods | `NESTED_TRY` | `#EC NESTED_TRY` | — |
| [`prefer-test-naming`](/rules/prefer-test-naming) | `ZCL_SKYLINT_PREF_TEST_NAME` | Enforce test method naming (TEST_, SHOULD_) in AUnit | `TEST_NAME` | `#EC TEST_NAME` | — |
| [`prefer-string-functions`](/rules/prefer-string-functions) | `ZCL_SKYLINT_PREF_STR_FUNC` | Detect obsolete string statements; prefer built-in functions | `CONDENSE_S` | `#EC STR_FUNC` | ⚡ Ready |
| [`prefer-calc-assign-op`](/rules/prefer-calc-assign-op) | `ZCL_SKYLINT_PREF_CALC_OP` | Prefer calculation assignment operators (+=, -=, *=, /=) | `CALC_ASSGN` | `#EC CALC_ASSIGN` | ⚡ Ready |
| [`prefer-early-return`](/rules/prefer-early-return) | `ZCL_SKYLINT_PREF_EARLY_RET` | Prefer early return or continue over nested IF blocks | `GUARD_METH` | `#EC EARLY_RETURN` | — |
| [`prefer-decl-order`](/rules/prefer-decl-order) | `ZCL_SKYLINT_PREF_DECL_ORDER` | Enforce declaration order (TYPES, CONSTANTS, DATA, FS) | `DECL_ORDER` | `#EC DECL_ORDER` | — |
| [`no-param-escape`](/rules/no-param-escape) | `ZCL_SKYLINT_NO_PARAM_ESCAPE` | Avoid unnecessary parameter escape (!param) | `PARAM_ESCP` | `#EC PARAM_ESCAPE` | ⚡ Ready |
| [`prefer-case`](/rules/prefer-case) | `ZCL_SKYLINT_PREF_CASE` | Use CASE instead of IF when checking multiple values | `USE_CASE` | `#EC PREF_CASE` | — |
| [`max-one-statement`](/rules/max-one-statement) | `ZCL_SKYLINT_MAX_ONE_STMT` | Max One Statement Per Line | `ONE_STMT` | `#EC ONE_STMT` | — |
| [`prefer-inline`](/rules/prefer-inline) | `ZCL_SKYLINT_PREF_INLINE` | Prefer Inline Declarations | `PREF_INL` | `#EC PREFER_INLINE` | — |
| [`prefer-final-data`](/rules/prefer-final-data) | `ZCL_SKYLINT_PREF_FINAL_DATA` | Declare inline variables as FINAL when never written again | `PREF_FIN` | `#EC PREF_FINAL` | ⚡ Ready |
| [`prefer-message-class`](/rules/prefer-message-class) | `ZCL_SKYLINT_PREF_MSG_CLS` | Use a message class (SE91) instead of inline message text | `PREF_MSG` | `#EC MSG_CLASS` | — |
| [`prefer-inline-cast`](/rules/prefer-inline-cast) | `ZCL_SKYLINT_PREF_INL_CAST` | Inline a CAST helper that is only read once | `PREF_ICST` | `#EC INLINE_CAST` | ⚡ Ready |
| [`prefer-public-constructor`](/rules/prefer-public-constructor) | `ZCL_SKYLINT_PREF_PUB_CTOR` | Declare Constructor in PUBLIC SECTION | `CTOR_PUB` | `#EC PUB_CTOR` | — |
| [`prefer-definitions-top`](/rules/prefer-definitions-top) | `ZCL_SKYLINT_PREF_DEF_TOP` | Place definitions at beginning of routine | `DEF_TOP` | `#EC DEF_TOP` | — |
| [`no-unnecessary-return`](/rules/no-unnecessary-return) | `ZCL_SKYLINT_NO_UNNEC_RETURN` | Omit unnecessary RETURN at end of routine | `UNNEC_RET` | `#EC NO_UNNEC_RETURN` | ⚡ Ready |
| [`mix-returning`](/rules/mix-returning) | `ZCL_SKYLINT_NO_MIX_RETURNING` | Do not mix RETURNING with EXPORTING or CHANGING | `MIX_RET` | `#EC NO_MIX_RETURNING` | — |
| [`max-one-method-parameter-per-line`](/rules/max-one-method-parameter-per-line) | `ZCL_SKYLINT_MAX_PARAM_LINE` | Max one method parameter definition per line | `PARAM_LINE` | `#EC MAX_PARAM_LINE` | — |
| [`prefer-is-initial`](/rules/prefer-is-initial) | `ZCL_SKYLINT_PREF_IS_INITIAL` | Prefer IS [NOT] INITIAL over lines( ) or empty literals | `PREF_INIT` | `#EC PREF_INIT` | ⚡ Ready |
| [`prefer-cast`](/rules/prefer-cast) | `ZCL_SKYLINT_PREF_CAST` | Prefer modern CAST #( ) expression over ?= | `PREFCAST` | `#EC PREF_CAST` | ⚡ Ready |
| [`no-redundant-clear`](/rules/no-redundant-clear) | `ZCL_SKYLINT_NO_REDUNDANT_CLEAR` | Do not CLEAR or FREE variables redundantly | `REDUNCLEAR` | `#EC REDUNDANT_CLEAR` | ⚡ Ready |

## Anti-Patterns & Bad Practices (30)

Discouraged language constructs, legacy statements, and redundant syntax.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`no-call-method`](/rules/no-call-method) | `ZCL_SKYLINT_NO_CALL_METHOD` | Avoid static CALL METHOD statements | `CALLMETHOD` | `#EC CALL_METH` | ⚡ Ready |
| [`no-default-key`](/rules/no-default-key) | `ZCL_SKYLINT_NO_DEFAULT_KEY` | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `#EC DEFAULT_KEY` | ⚡ Ready |
| [`no-me-reference`](/rules/no-me-reference) | `ZCL_SKYLINT_NO_ME_REFERENCE` | Avoid self-reference ME-> | `AVOIDME` | `#EC ME` | — |
| [`no-redundant-method-call`](/rules/no-redundant-method-call) | `ZCL_SKYLINT_NO_REDUNDANT_CALL` | Omit redundant EXPORTING and RECEIVING in method calls | `OMITEXPORT` | `#EC EXPORTING` | ⚡ Ready |
| [`no-chained-statements`](/rules/no-chained-statements) | `ZCL_SKYLINT_NO_CHAINED_STMT` | Avoid chained declarations and chained assignments | `CHAINDECL` | `#EC CHAIN_DECL` | ⚡ Ready |
| [`no-boolean-comparison`](/rules/no-boolean-comparison) | `ZCL_SKYLINT_NO_BOOL_COMPARE` | Avoid comparing boolean method calls to boolean literals | `BOOLCOMP` | `#EC BOOL_COMPARE` | ⚡ Ready |
| [`no-check-statement`](/rules/no-check-statement) | `ZCL_SKYLINT_NO_CHECK_STMT` | Avoid CHECK statements; prefer IF with RETURN or CONTINUE | `CHKINLOOP` | `#EC CHECK_STMT` | ⚡ Ready |
| [`no-empty-block`](/rules/no-empty-block) | `ZCL_SKYLINT_NO_EMPTY_BLOCK` | Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.) | `EMPTYCTRL` | `#EC EMPTY_BLOCK` | — |
| [`no-duplicate-conditions`](/rules/no-duplicate-conditions) | `ZCL_SKYLINT_NO_DUP_COND` | Avoid duplicate branch conditions in IF and CASE | `DUPCOND` | `#EC DUP_COND` | — |
| [`no-unreachable-code`](/rules/no-unreachable-code) | `ZCL_SKYLINT_NO_UNREACHABLE` | Detect unreachable code after jump or exit statements | `UNREACHCD` | `#EC UNREACHABLE` | ⚡ Ready |
| [`no-single-when`](/rules/no-single-when) | `ZCL_SKYLINT_NO_SINGLE_WHEN` | Avoid CASE statements with only one WHEN branch | `SHORTCASE` | `#EC SINGLE_WHEN` | — |
| [`no-yoda-conditions`](/rules/no-yoda-conditions) | `ZCL_SKYLINT_NO_YODA_COND` | Avoid Yoda conditions in comparison expressions | `YODACOND` | `#EC YODA_COND` | ⚡ Ready |
| [`no-static-via-instance`](/rules/no-static-via-instance) | `ZCL_SKYLINT_NO_STATIC_ARROW` | Avoid calling static methods via instance arrow (->) | `STATICVIAI` | `#EC STATIC_ARROW` | ⚡ Ready |
| [`no-public-attributes`](/rules/no-public-attributes) | `ZCL_SKYLINT_NO_PUBLIC_ATTR` | Avoid mutable public attributes in classes | `NOPUBATTR` | `#EC PUBLIC_ATTR` | — |
| [`no-obsolete-statements`](/rules/no-obsolete-statements) | `ZCL_SKYLINT_NO_OBSOLETE` | Avoid obsolete statements (MOVE, REFRESH, FORM, etc.) | `OBSOLETE` | `#EC OBSOLETE` | ⚡ Ready |
| [`no-scope-leak`](/rules/no-scope-leak) | `ZCL_SKYLINT_NO_SCOPE_LEAK` | Avoid variable usage outside its declaring control block | `SCOPELEAK` | `#EC SCOPE_LEAK` | — |
| [`no-self-assignment`](/rules/no-self-assignment) | `ZCL_SKYLINT_NO_SELF_ASSIGN` | Detect Identical Self Assignments | `IDENTMOVE` | `#EC SELF_ASSIGN` | ⚡ Ready |
| [`no-sy-modify`](/rules/no-sy-modify) | `ZCL_SKYLINT_NO_SY_MODIFY` | Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `#EC SY_MODIFY` | — |
| [`no-magic-numbers`](/rules/no-magic-numbers) | `ZCL_SKYLINT_NO_MAGIC_NUMBERS` | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `#EC MAGIC_NUMBERS` | — |
| [`no-like-objects`](/rules/no-like-objects) | `ZCL_SKYLINT_NO_LIKE_OBJECTS` | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `#EC LIKE_OBJECTS` | — |
| [`no-interface-data`](/rules/no-interface-data) | `ZCL_SKYLINT_NO_INTF_DATA` | Avoid mutable DATA in interfaces; allow only CONSTANTS | `INTF_DATA` | `#EC INTF_DATA` | — |
| [`no-message-raising`](/rules/no-message-raising) | `ZCL_SKYLINT_NO_MSG_RAISING` | Avoid MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `#EC MSG_RAISING` | — |
| [`no-unused-variables`](/rules/no-unused-variables) | `ZCL_SKYLINT_NO_UNUSED_VARS` | Detect unused local variables and field symbols | `UNUSED_VAR` | `#EC NEEDED` | — |
| [`no-inline-length`](/rules/no-inline-length) | `ZCL_SKYLINT_NO_INLINE_LEN` | Avoid inline length specification in declarations | `PAREN_LEN` | `#EC PAREN_LEN` | ⚡ Ready |
| [`no-dash-in-names`](/rules/no-dash-in-names) | `ZCL_SKYLINT_NO_DASH_IN_NAMES` | No Dashes in Variable and Form Names | `NO_DASH` | `#EC NO_DASH` | — |
| [`no-friends`](/rules/no-friends) | `ZCL_SKYLINT_NO_FRIENDS` | Avoid FRIENDS in class definitions | `NO_FRIENDS` | `#EC FRIENDS` | — |
| [`no-exception-overlap`](/rules/no-exception-overlap) | `ZCL_SKYLINT_NO_EXC_OVERLAP` | Classic EXCEPTIONS must not overlap | `NO_EXC_OVL` | `#EC EXC_OVERLAP` | — |
| [`no-many-parentheses`](/rules/no-many-parentheses) | `ZCL_SKYLINT_NO_MANY_PARENS` | Remove redundant parentheses | `MANY_PAREN` | `#EC MANY_PARENS` | ⚡ Ready |
| [`no-ignored-return-value`](/rules/no-ignored-return-value) | `ZCL_SKYLINT_NO_IGNORED_RETURN` | Disallow ignoring the return value of functional methods | `IGNRET` | `#EC NO_IGNORED_RET` | — |
| [`no-modify-loop-table`](/rules/no-modify-loop-table) | `ZCL_SKYLINT_NO_MOD_LOOP_TAB` | Avoid mutating or sorting tables inside loops | `MOD_LOOPTB` | `#EC LOOP_MODIFY` | — |

## Performance & Database (6)

Database query efficiency, buffer protection, and internal table operation guidelines.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`no-db-in-loop`](/rules/no-db-in-loop) | `ZCL_SKYLINT_NO_DB_IN_LOOP` | Avoid database access inside loop iterations | `DBINLOOP` | `#EC DB_IN_LOOP` | — |
| [`no-empty-fae`](/rules/no-empty-fae) | `ZCL_SKYLINT_NO_EMPTY_FAE` | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `#EC EMPTY_FAE` | ⚡ Ready |
| [`no-select-star`](/rules/no-select-star) | `ZCL_SKYLINT_NO_SELECT_STAR` | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `#EC SELECT_STAR` | — |
| [`prefer-order-by`](/rules/prefer-order-by) | `ZCL_SKYLINT_PREF_ORDER_BY` | SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `#EC ORDER_BY` | — |
| [`prefer-transporting`](/rules/prefer-transporting) | `ZCL_SKYLINT_PREF_TRANSPORT` | Avoid MODIFY itab in LOOP without TRANSPORTING clause | `FULL_MODIF` | `#EC TRANSPORTING` | — |
| [`prefer-pass-by-reference`](/rules/prefer-pass-by-reference) | `ZCL_SKYLINT_PREF_PASS_BY_REF` | Slow Parameter Passing | `SLOW_PASS` | `#EC SLOW_PARAM` | — |

## Security & Robustness (11)

Authorizations, dynamic execution sanitation, error handling, and runtime safety.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`no-dangerous-statements`](/rules/no-dangerous-statements) | `ZCL_SKYLINT_NO_DANGEROUS_STMT` | Dangerous Statements (abaplint dangerous_statement) | `DANGER_STM` | `#EC DANGEROUS_STMT` | — |
| [`prefer-auth-check`](/rules/prefer-auth-check) | `ZCL_SKYLINT_PREF_AUTH_CHECK` | Call Transaction Authority Check | `AUTH_CHECK` | `#EC AUTH_CHECK` | ⚡ Ready |
| [`no-catch-cx-root`](/rules/no-catch-cx-root) | `ZCL_SKYLINT_NO_CATCH_ROOT` | Catch specific exceptions instead of generic cx_root | `CATCH_ROOT` | `#EC CATCH_ROOT` | — |
| [`no-raise-cx-sy`](/rules/no-raise-cx-sy) | `ZCL_SKYLINT_NO_RAISE_CX_SY` | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `#EC RAISE_CX_SY` | — |
| [`prefer-subrc-check`](/rules/prefer-subrc-check) | `ZCL_SKYLINT_PREF_CHECK_SUBRC` | Check sy-subrc after DB, table and string operations | `CHECKSUBRC` | `#EC CHECK_SUBRC` | — |
| [`no-client-specified`](/rules/no-client-specified) | `ZCL_SKYLINT_NO_CLIENT_SPEC` | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPE` | `#EC CLIENT_SPEC` | ⚡ Ready |
| [`no-commit-work`](/rules/no-commit-work) | `ZCL_SKYLINT_NO_COMMIT_WORK` | Avoid COMMIT and ROLLBACK in application logic | `NO_COMMIT` | `#EC COMMIT_WORK` | — |
| [`no-rfc-error-handling`](/rules/no-rfc-error-handling) | `ZCL_SKYLINT_NO_RFC_ERR` | RFC calls must handle system failures | `NO_RFC_ERR` | `#EC RFC_ERR` | — |
| [`no-modify-standard-tables`](/rules/no-modify-standard-tables) | `ZCL_SKYLINT_NO_MOD_STD_TABLE` | Modify Only Own Database Tables | `NOT_OWN_TB` | `#EC OWN_TABLES` | — |
| [`no-dynamic-stuff`](/rules/no-dynamic-stuff) | `ZCL_SKYLINT_NO_DYNAMIC_STMT` | No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.) | `DYN_STUFF` | `#EC NO_DYNAMIC` | — |
| [`no-hardcoded-env-checks`](/rules/no-hardcoded-env-checks) | `ZCL_SKYLINT_NO_HARDCODED_ENV` | Avoid reading environment system fields (sy-sysid, etc.) | `ENV_CHECK` | `#EC HARDCODED_ENV` | — |

## Metrics & Complexity Limits (6)

Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`max-params`](/rules/max-params) | `ZCL_SKYLINT_MAX_PARAMS` | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `#EC MAX_PARAMS` | — |
| [`max-method-length`](/rules/max-method-length) | `ZCL_SKYLINT_MAX_METHOD_LEN` | Method Length Limit (excessive statement count) | `METHOD_LEN` | `#EC METHOD_LEN` | — |
| [`max-nesting-depth`](/rules/max-nesting-depth) | `ZCL_SKYLINT_MAX_NESTING` | Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `#EC NESTING` | — |
| [`max-cyclomatic-complexity`](/rules/max-cyclomatic-complexity) | `ZCL_SKYLINT_MAX_CYCLO_COMP` | Cyclomatic Complexity Threshold | `CYCLO_COMP` | `#EC CYCLO_COMP` | — |
| [`max-inheritance-depth`](/rules/max-inheritance-depth) | `ZCL_SKYLINT_MAX_INHERIT` | Avoid deep class inheritance hierarchies | `DEEP_INHRT` | `#EC INHERIT_DEPTH` | — |
| [`max-attributes`](/rules/max-attributes) | `ZCL_SKYLINT_MAX_ATTRIBUTES` | Limit class member attributes to prevent God Classes | `ATTR_COUNT` | `#EC ATTRIBUTES` | — |

