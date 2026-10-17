# 📋 Skylint Rules Catalog (74 Rules)

Comprehensive reference for all **74** Clean ABAP, security, performance, and architecture rules in Skylint.

Every rule runs natively inside the **ABAP Test Cockpit (ATC)** and supports automated refactorings via Eclipse ADT QuickFixes.

## Clean ABAP & Modern Syntax (28)

Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`prefer-lines`](/rules/prefer-lines) | `ZCL_SKYLINT_PREF_LINES` | Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `#EC LINES` | ⚡ Ready |
| [`prefer-is-not`](/rules/prefer-is-not) | `ZCL_SKYLINT_PREF_IS_NOT` | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `#EC IS_NOT` | ⚡ Ready |
| [`prefer-string-template`](/rules/prefer-string-template) | `ZCL_SKYLINT_PREF_STR_TMPL` | Prefer string templates over CONCATENATE | `CONCATSTR` | `#EC STR_TMPL` | ⚡ Ready |
| [`prefer-line-exists`](/rules/prefer-line-exists) | `ZCL_SKYLINT_PREF_LINE_EXISTS` | Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS | `PREFLINEX` | `#EC LINE_EXISTS` | — |
| [`prefer-return`](/rules/prefer-return) | `ZCL_SKYLINT_PREF_RETURN` | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `#EC RETURN` | ⚡ Ready |
| [`merge-nested-ifs`](/rules/merge-nested-ifs) | `ZCL_SKYLINT_PREF_MERGE_IFS` | Detect consecutive nested IF blocks that can be merged with AND | `NESTEDIF` | `#EC MERGE_IFS` | — |
| [`prefer-symbol-operators`](/rules/prefer-symbol-operators) | `ZCL_SKYLINT_PREF_SYMBOL_OP` | Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords | `PREFEROP` | `#EC SYMBOL_OP` | ⚡ Ready |
| [`prefer-new-operator`](/rules/prefer-new-operator) | `ZCL_SKYLINT_PREF_NEW_OP` | Prefer NEW #( ) constructor over CREATE OBJECT and RAISE EXCEPTION TYPE | `PREFERNEW` | `#EC NEW_OP` | ⚡ Ready |
| [`prefer-xsdbool`](/rules/prefer-xsdbool) | `ZCL_SKYLINT_PREF_XSDBOOL` | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDB` | `#EC XSDBOOL` | ⚡ Ready |
| [`require-fully-typed`](/rules/require-fully-typed) | `ZCL_SKYLINT_PREF_FULL_TYPED` | Enforce fully typed constant declarations | `FULLYTYPED` | `#EC FULL_TYPED` | — |
| [`prefer-corresponding`](/rules/prefer-corresponding) | `ZCL_SKYLINT_PREF_CORRESP` | Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `#EC CORRESP` | ⚡ Ready |
| [`prefer-returning`](/rules/prefer-returning) | `ZCL_SKYLINT_PREF_RETURNING` | Prefer RETURNING over single EXPORTING | `PREFER_RET` | `#EC RETURNING` | — |
| [`prefer-class-exceptions`](/rules/prefer-class-exceptions) | `ZCL_SKYLINT_PREF_CLASS_EXC` | Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `#EC CLASS_EXC` | — |
| [`prefer-final-class`](/rules/prefer-final-class) | `ZCL_SKYLINT_PREF_FINAL_CLS` | Prefer FINAL classes and methods by default | `NOT_FINAL` | `#EC FINAL_CLS` | ⚡ Ready |
| [`prefer-insert-into`](/rules/prefer-insert-into) | `ZCL_SKYLINT_PREF_INSERT` | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `#EC INSERT_INTO` | ⚡ Ready |
| [`clean-constructor`](/rules/clean-constructor) | `ZCL_SKYLINT_CLEAN_CTOR` | Keep constructors clean; avoid heavy business logic/loops/DB access | `CTOR_LOGIC` | `#EC CLEAN_CTOR` | — |
| [`no-static-classes`](/rules/no-static-classes) | `ZCL_SKYLINT_NO_STATIC_CLS` | Avoid static-only classes; prefer instantiable interface-based design | `STAT_CLASS` | `#EC STATIC_CLS` | — |
| [`prefer-predicate-names`](/rules/prefer-predicate-names) | `ZCL_SKYLINT_PREF_PRED_NAME` | Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods | `BOOL_NAME` | `#EC PRED_NAME` | — |
| [`no-nested-try`](/rules/no-nested-try) | `ZCL_SKYLINT_NO_NESTED_TRY` | Avoid nested TRY blocks; extract inner error handling to helper methods | `NESTED_TRY` | `#EC NESTED_TRY` | — |
| [`test-method-naming`](/rules/test-method-naming) | `ZCL_SKYLINT_PREF_TEST_NAME` | Enforce test method naming convention (TEST_, SHOULD_) in AUnit | `TEST_NAME` | `#EC TEST_NAME` | — |
| [`prefer-string-functions`](/rules/prefer-string-functions) | `ZCL_SKYLINT_PREF_STR_FUNC` | Detect obsolete string statements; prefer built-in functions | `CONDENSE_S` | `#EC STR_FUNC` | ⚡ Ready |
| [`prefer-calc-assign-op`](/rules/prefer-calc-assign-op) | `ZCL_SKYLINT_PREF_CALC_OP` | Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1 | `CALC_ASSGN` | `#EC CALC_ASSIGN` | ⚡ Ready |
| [`prefer-early-return`](/rules/prefer-early-return) | `ZCL_SKYLINT_PREF_EARLY_RET` | Prefer early exit (RETURN or CONTINUE) instead of nested IF blocks | `GUARD_METH` | `#EC EARLY_RETURN` | — |
| [`require-decl-order`](/rules/require-decl-order) | `ZCL_SKYLINT_PREF_DECL_ORDER` | Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS) | `DECL_ORDER` | `#EC DECL_ORDER` | — |
| [`no-param-escape`](/rules/no-param-escape) | `ZCL_SKYLINT_NO_PARAM_ESCAPE` | Detect unnecessary exclamation mark parameter escape (!iv_param) | `PARAM_ESCP` | `#EC PARAM_ESCAPE` | ⚡ Ready |
| [`prefer-case`](/rules/prefer-case) | `ZCL_SKYLINT_PREF_CASE` | Change IF to CASE when checking the same variable against multiple values | `USE_CASE` | `#EC PREF_CASE` | — |
| [`max-one-statement`](/rules/max-one-statement) | `ZCL_SKYLINT_MAX_ONE_STMT` | Max One Statement Per Line | `ONE_STMT` | `#EC ONE_STMT` | — |
| [`prefer-inline`](/rules/prefer-inline) | `ZCL_SKYLINT_PREF_INLINE` | Prefer Inline Declarations | `PREF_INL` | `#EC PREFER_INLINE` | — |

## Anti-Patterns & Bad Practices (25)

Discouraged language constructs, legacy statements, and redundant syntax.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`no-call-method`](/rules/no-call-method) | `ZCL_SKYLINT_NO_CALL_METHOD` | Avoid static CALL METHOD statements | `CALLMETHOD` | `#EC CALL_METH` | ⚡ Ready |
| [`no-default-key`](/rules/no-default-key) | `ZCL_SKYLINT_NO_DEFAULT_KEY` | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `#EC DEFAULT_KEY` | ⚡ Ready |
| [`no-me-reference`](/rules/no-me-reference) | `ZCL_SKYLINT_NO_ME_REFERENCE` | Avoid self-reference ME-> | `AVOIDME` | `#EC ME` | — |
| [`no-redundant-method-call`](/rules/no-redundant-method-call) | `ZCL_SKYLINT_NO_REDUNDANT_CALL` | Omit redundant EXPORTING, RECEIVING, and single parameter names in method calls | `OMITEXPORT` | `#EC EXPORTING` | ⚡ Ready |
| [`no-chained-statements`](/rules/no-chained-statements) | `ZCL_SKYLINT_NO_CHAINED_STMT` | Avoid chained declarations and chained assignments | `CHAINDECL` | `#EC CHAIN_DECL` | ⚡ Ready |
| [`no-boolean-comparison`](/rules/no-boolean-comparison) | `ZCL_SKYLINT_NO_BOOL_COMPARE` | Avoid comparing boolean method calls to boolean literals | `BOOLCOMP` | `#EC BOOL_COMPARE` | ⚡ Ready |
| [`no-check-in-loop`](/rules/no-check-in-loop) | `ZCL_SKYLINT_NO_CHECK_IN_LOOP` | Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE) | `CHKINLOOP` | `#EC CHECK_IN_LOOP` | ⚡ Ready |
| [`no-empty-block`](/rules/no-empty-block) | `ZCL_SKYLINT_NO_EMPTY_BLOCK` | Detect empty control blocks (IF, CASE, LOOP, TRY, CATCH, etc.) | `EMPTYCTRL` | `#EC EMPTY_BLOCK` | — |
| [`no-duplicate-conditions`](/rules/no-duplicate-conditions) | `ZCL_SKYLINT_NO_DUP_COND` | Detect identical branch conditions in IF/ELSEIF and CASE/WHEN | `DUPCOND` | `#EC DUP_COND` | — |
| [`no-unreachable-code`](/rules/no-unreachable-code) | `ZCL_SKYLINT_NO_UNREACHABLE` | Detect unreachable code following unconditional jump statements | `UNREACHCD` | `#EC UNREACHABLE` | ⚡ Ready |
| [`no-single-when`](/rules/no-single-when) | `ZCL_SKYLINT_NO_SINGLE_WHEN` | Avoid short CASE constructs with only one WHEN branch; prefer IF | `SHORTCASE` | `#EC SINGLE_WHEN` | — |
| [`no-yoda-conditions`](/rules/no-yoda-conditions) | `ZCL_SKYLINT_NO_YODA_COND` | Avoid Yoda conditions in comparison expressions | `YODACOND` | `#EC YODA_COND` | ⚡ Ready |
| [`no-static-via-instance`](/rules/no-static-via-instance) | `ZCL_SKYLINT_NO_STATIC_ARROW` | Avoid calling static methods via instance arrow (->) | `STATICVIAI` | `#EC STATIC_ARROW` | ⚡ Ready |
| [`no-public-attributes`](/rules/no-public-attributes) | `ZCL_SKYLINT_NO_PUBLIC_ATTR` | Avoid mutable public attributes in classes | `NOPUBATTR` | `#EC PUBLIC_ATTR` | — |
| [`no-obsolete-statements`](/rules/no-obsolete-statements) | `ZCL_SKYLINT_NO_OBSOLETE` | Avoid obsolete or deprecated statements (MOVE, REFRESH, FORM, AT NEW, etc.) | `OBSOLETE` | `#EC OBSOLETE` | ⚡ Ready |
| [`no-scope-leak`](/rules/no-scope-leak) | `ZCL_SKYLINT_NO_SCOPE_LEAK` | Scope of variable (avoid variable leaking outside control blocks) | `SCOPELEAK` | `#EC SCOPE_LEAK` | — |
| [`no-self-assignment`](/rules/no-self-assignment) | `ZCL_SKYLINT_NO_SELF_ASSIGN` | Detect Identical Self Assignments | `IDENTMOVE` | `#EC SELF_ASSIGN` | ⚡ Ready |
| [`no-sy-modify`](/rules/no-sy-modify) | `ZCL_SKYLINT_NO_SY_MODIFY` | Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `#EC SY_MODIFY` | — |
| [`no-magic-numbers`](/rules/no-magic-numbers) | `ZCL_SKYLINT_NO_MAGIC_NUMBERS` | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `#EC MAGIC_NUMBERS` | — |
| [`no-like-objects`](/rules/no-like-objects) | `ZCL_SKYLINT_NO_LIKE_OBJECTS` | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `#EC LIKE_OBJECTS` | — |
| [`no-interface-data`](/rules/no-interface-data) | `ZCL_SKYLINT_NO_INTF_DATA` | Avoid mutable DATA declarations in interfaces; allow only CONSTANTS | `INTF_DATA` | `#EC INTF_DATA` | — |
| [`no-message-raising`](/rules/no-message-raising) | `ZCL_SKYLINT_NO_MSG_RAISING` | Avoid obsolete MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `#EC MSG_RAISING` | — |
| [`no-unused-variables`](/rules/no-unused-variables) | `ZCL_SKYLINT_NO_UNUSED_VARS` | Detect unused local variables and field symbols | `UNUSED_VAR` | `#EC NEEDED` | — |
| [`no-inline-length`](/rules/no-inline-length) | `ZCL_SKYLINT_NO_INLINE_LEN` | Avoid inline length specification in declarations | `PAREN_LEN` | `#EC PAREN_LEN` | ⚡ Ready |
| [`names-no-dash`](/rules/names-no-dash) | `ZCL_SKYLINT_NAMES_NO_DASH` | No Dashes in Variable and Form Names | `NO_DASH` | `#EC NO_DASH` | — |

## Performance & Database (6)

Database query efficiency, buffer protection, and internal table operation guidelines.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`no-db-in-loop`](/rules/no-db-in-loop) | `ZCL_SKYLINT_NO_DB_IN_LOOP` | Avoid database access inside loop iterations | `DBINLOOP` | `#EC DB_IN_LOOP` | — |
| [`no-empty-fae`](/rules/no-empty-fae) | `ZCL_SKYLINT_NO_EMPTY_FAE` | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `#EC EMPTY_FAE` | ⚡ Ready |
| [`no-select-star`](/rules/no-select-star) | `ZCL_SKYLINT_NO_SELECT_STAR` | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `#EC SELECT_STAR` | — |
| [`require-order-by`](/rules/require-order-by) | `ZCL_SKYLINT_PREF_ORDER_BY` | SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `#EC ORDER_BY` | — |
| [`require-transporting`](/rules/require-transporting) | `ZCL_SKYLINT_PREF_TRANSPORT` | Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause | `FULL_MODIF` | `#EC TRANSPORTING` | — |
| [`slow-param-passing`](/rules/slow-param-passing) | `ZCL_SKYLINT_SLOW_PARAM_PASS` | Slow Parameter Passing | `SLOW_PASS` | `#EC SLOW_PARAM` | — |

## Security & Robustness (9)

Authorizations, dynamic execution sanitation, error handling, and runtime safety.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`no-dangerous-statements`](/rules/no-dangerous-statements) | `ZCL_SKYLINT_NO_DANGEROUS_STMT` | Dangerous Statements (abaplint dangerous_statement) | `DANGER_STM` | `#EC DANGEROUS_STMT` | — |
| [`require-auth-check`](/rules/require-auth-check) | `ZCL_SKYLINT_PREF_AUTH_CHECK` | Call Transaction Authority Check | `AUTH_CHECK` | `#EC AUTH_CHECK` | ⚡ Ready |
| [`no-catch-cx-root`](/rules/no-catch-cx-root) | `ZCL_SKYLINT_NO_CATCH_ROOT` | Avoid generic CATCH cx_root; catch specific exception classes | `CATCH_ROOT` | `#EC CATCH_ROOT` | — |
| [`no-raise-cx-sy`](/rules/no-raise-cx-sy) | `ZCL_SKYLINT_NO_RAISE_CX_SY` | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `#EC RAISE_CX_SY` | — |
| [`require-subrc-check`](/rules/require-subrc-check) | `ZCL_SKYLINT_CHECK_SUBRC` | Check sy-subrc after DB, table and string operations | `CHECKSUBRC` | `#EC CHECK_SUBRC` | — |
| [`no-client-specified`](/rules/no-client-specified) | `ZCL_SKYLINT_NO_CLIENT_SPEC` | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPE` | `#EC CLIENT_SPEC` | ⚡ Ready |
| [`no-commit-work`](/rules/no-commit-work) | `ZCL_SKYLINT_NO_COMMIT_WORK` | Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations | `NO_COMMIT` | `#EC COMMIT_WORK` | — |
| [`modify-own-tables`](/rules/modify-own-tables) | `ZCL_SKYLINT_MODIFY_OWN_TAB` | Modify Only Own Database Tables | `NOT_OWN_TB` | `#EC OWN_TABLES` | — |
| [`no-dynamic-stuff`](/rules/no-dynamic-stuff) | `ZCL_SKYLINT_NO_DYNAMIC_STMT` | No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.) | `DYN_STUFF` | `#EC NO_DYNAMIC` | — |

## Metrics & Complexity Limits (6)

Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| [`max-params`](/rules/max-params) | `ZCL_SKYLINT_MAX_PARAMS` | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `#EC MAX_PARAMS` | — |
| [`max-method-length`](/rules/max-method-length) | `ZCL_SKYLINT_MAX_METHOD_LEN` | Method Length Limit (excessive statement count) | `METHOD_LEN` | `#EC METHOD_LEN` | — |
| [`max-nesting-depth`](/rules/max-nesting-depth) | `ZCL_SKYLINT_MAX_NESTING` | Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `#EC NESTING` | — |
| [`max-cyclomatic-complexity`](/rules/max-cyclomatic-complexity) | `ZCL_SKYLINT_MAX_CYCLO_COMP` | Cyclomatic Complexity Threshold | `CYCLO_COMP` | `#EC CYCLO_COMP` | — |
| [`max-inheritance-depth`](/rules/max-inheritance-depth) | `ZCL_SKYLINT_MAX_INHERIT` | Avoid deep class inheritance hierarchies | `DEEP_INHRT` | `#EC INHERIT_DEPTH` | — |
| [`max-attributes`](/rules/max-attributes) | `ZCL_SKYLINT_MAX_ATTRIBUTES` | Limit number of member attributes in a class (God Class smell) | `ATTR_COUNT` | `#EC ATTRIBUTES` | — |

