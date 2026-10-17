# ☁️ Skylint

> **Modern, Minimal ABAP Linter for SAP BTP & S/4HANA (ATC-Native)**

**Skylint** is an extensible, high-performance static code analysis framework for ABAP. Every rule is a **native ATC check** (`if_ci_atc_check`) running on SAP BTP ABAP Environment & S/4HANA — no adapters, no branches, no portability layers.

---

## ⚡ Highlights

- **ATC-Native (`main` only):** Every check inherits `zcl_skylint_check_base`, which implements `if_ci_atc_check` directly. All types come from the SAP ATC framework (`if_ci_atc_source_code_provider`, `if_ci_atc_check`, `if_ci_atc_check_meta_data`).
- **Zero Boilerplate Architecture:** Base class encapsulates procedure iteration, finding registration with checksum/location, statement/token reporting, attribute resolution, and pseudo-comment filtering. Subclasses only require `constructor` and `check`.
- **QuickFix Ready & Validated:** Built-in helper API (`quickfix_replace`) for automated transformations, verified by round-trip syntax testing.
- **Single-Branch Delivery:** One branch, one syntax (ABAP Cloud), one deployment path via abapGit.

---

## 📁 Repository Structure

```text
skylint/
├── src/
│   ├── core/                                     # ATC-native core infrastructure
│   │   ├── zcl_skylint_check_base.clas.abap      # Base check class (implements if_ci_atc_check)
│   │   ├── zcl_skylint_check_meta_data.clas.abap # Shared if_ci_atc_check_meta_data implementation
│   │   ├── zcl_skylint_ast_util.clas.abap        # AST & token sequence traversal utility
│   │   └── zcl_skylint_rtti_util.clas.abap       # Safe ABAP RTTI inspection utility
│   │
│   ├── checks/                                   # 84 Modular Check Implementations
│   │   ├── zcl_skylint_pref_lines.clas.abap      # Check class implementation
│   │   └── zcl_skylint_pref_lines.clas.xml       # abapGit XML metadata
│   └── deps/atc/src/                             # Local-only ATC framework stubs (never shipped)
├── bin/                                          # Executable CLI (skylint scan, explain, list, init)
├── lib/                                          # Core JS engine (ast parser, atc doubles, quickfix roundtrip)
├── test/                                         # Test suite
│   ├── fixtures/                                 # Test fixtures per check (source.abap + expected.json)
│   ├── run.mjs                                   # Main test runner (executes checks via transpiled runtime)
│   └── stubs/                                    # Transpiler stubs
├── abaplint.json                                 # abaplint validation configuration & rule sets
└── package.json                                  # Lint, build, and test scripts
```

---

## 📋 Clean ABAP & Cloud Rule Catalog (84 Rules)

All Clean ABAP, security, and cloud-native rules implemented in Skylint:

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| `prefer-lines` | [ZCL_SKYLINT_PREF_LINES](src/checks/zcl_skylint_pref_lines.clas.abap) | Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `"#EC LINES"` | ⚡ Ready |
| `no-call-method` | [ZCL_SKYLINT_NO_CALL_METHOD](src/checks/zcl_skylint_no_call_method.clas.abap) | Avoid static CALL METHOD statements | `CALLMETHOD` | `"#EC CALL_METH"` | ⚡ Ready |
| `no-default-key` | [ZCL_SKYLINT_NO_DEFAULT_KEY](src/checks/zcl_skylint_no_default_key.clas.abap) | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `"#EC DEFAULT_KEY"` | ⚡ Ready |
| `prefer-is-not` | [ZCL_SKYLINT_PREF_IS_NOT](src/checks/zcl_skylint_pref_is_not.clas.abap) | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `"#EC IS_NOT"` | ⚡ Ready |
| `no-me-reference` | [ZCL_SKYLINT_NO_ME_REFERENCE](src/checks/zcl_skylint_no_me_reference.clas.abap) | Avoid self-reference ME-> | `AVOIDME` | `"#EC ME"` | — |
| `no-exporting` | [ZCL_SKYLINT_NO_EXPORTING](src/checks/zcl_skylint_no_exporting.clas.abap) | Omit explicit EXPORTING in method calls | `OMITEXPORT` | `"#EC EXPORTING"` | ⚡ Ready |
| `no-chained-assignment` | [ZCL_SKYLINT_NO_CHAIN_ASSIGN](src/checks/zcl_skylint_no_chain_assign.clas.abap) | Avoid assignment chaining (a = b = c) | `ASSIGNCHN` | `"#EC CHAIN_ASSIGN"` | ⚡ Ready |
| `no-chained-decl` | [ZCL_SKYLINT_NO_CHAIN_DECL](src/checks/zcl_skylint_no_chain_decl.clas.abap) | Avoid chained declarations (DATA:, TYPES:, etc.) | `CHAINDECL` | `"#EC CHAIN_DECL"` | ⚡ Ready |
| `prefer-string-template` | [ZCL_SKYLINT_PREF_STR_TMPL](src/checks/zcl_skylint_pref_str_tmpl.clas.abap) | Prefer string templates over CONCATENATE | `CONCATSTR` | `"#EC STR_TMPL"` | ⚡ Ready |
| `no-boolean-comparison` | [ZCL_SKYLINT_NO_BOOL_COMPARE](src/checks/zcl_skylint_no_bool_compare.clas.abap) | Avoid comparing boolean method calls to boolean literals | `BOOLCOMP` | `"#EC BOOL_COMPARE"` | ⚡ Ready |
| `prefer-line-exists` | [ZCL_SKYLINT_PREF_LINE_EXISTS](src/checks/zcl_skylint_pref_line_exists.clas.abap) | Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS | `PREFLINEX` | `"#EC LINE_EXISTS"` | — |
| `prefer-return` | [ZCL_SKYLINT_PREF_RETURN](src/checks/zcl_skylint_pref_return.clas.abap) | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `"#EC RETURN"` | ⚡ Ready |
| `no-check-in-loop` | [ZCL_SKYLINT_NO_CHECK_IN_LOOP](src/checks/zcl_skylint_no_check_in_loop.clas.abap) | Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE) | `CHKINLOOP` | `"#EC CHECK_IN_LOOP"` | ⚡ Ready |
| `no-empty-block` | [ZCL_SKYLINT_NO_EMPTY_BLOCK](src/checks/zcl_skylint_no_empty_block.clas.abap) | Detect empty control blocks (IF, CASE, LOOP, TRY, CATCH, etc.) | `EMPTYCTRL` | `"#EC EMPTY_BLOCK"` | — |
| `no-duplicate-conditions` | [ZCL_SKYLINT_NO_DUP_COND](src/checks/zcl_skylint_no_dup_cond.clas.abap) | Detect identical branch conditions in IF/ELSEIF and CASE/WHEN | `DUPCOND` | `"#EC DUP_COND"` | — |
| `merge-nested-ifs` | [ZCL_SKYLINT_PREF_MERGE_IFS](src/checks/zcl_skylint_pref_merge_ifs.clas.abap) | Detect consecutive nested IF blocks that can be merged with AND | `NESTEDIF` | `"#EC MERGE_IFS"` | — |
| `no-unreachable-code` | [ZCL_SKYLINT_NO_UNREACHABLE](src/checks/zcl_skylint_no_unreachable.clas.abap) | Detect unreachable code following unconditional jump statements | `UNREACHCD` | `"#EC UNREACHABLE"` | ⚡ Ready |
| `no-single-when` | [ZCL_SKYLINT_NO_SINGLE_WHEN](src/checks/zcl_skylint_no_single_when.clas.abap) | Avoid short CASE constructs with only one WHEN branch; prefer IF | `SHORTCASE` | `"#EC SINGLE_WHEN"` | — |
| `no-yoda-conditions` | [ZCL_SKYLINT_NO_YODA_COND](src/checks/zcl_skylint_no_yoda_cond.clas.abap) | Avoid Yoda conditions in comparison expressions | `YODACOND` | `"#EC YODA_COND"` | ⚡ Ready |
| `prefer-symbol-operators` | [ZCL_SKYLINT_PREF_SYMBOL_OP](src/checks/zcl_skylint_pref_symbol_op.clas.abap) | Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords | `PREFEROP` | `"#EC SYMBOL_OP"` | ⚡ Ready |
| `prefer-new-operator` | [ZCL_SKYLINT_PREF_NEW_OP](src/checks/zcl_skylint_pref_new_op.clas.abap) | Prefer NEW #( ) constructor expression over legacy CREATE OBJECT | `PREFERNEW` | `"#EC NEW_OP"` | ⚡ Ready |
| `prefer-raise-new` | [ZCL_SKYLINT_PREF_RAISE_NEW](src/checks/zcl_skylint_pref_raise_new.clas.abap) | Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE | `RAISEEXCNE` | `"#EC RAISE_NEW"` | ⚡ Ready |
| `prefer-xsdbool` | [ZCL_SKYLINT_PREF_XSDBOOL](src/checks/zcl_skylint_pref_xsdbool.clas.abap) | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDB` | `"#EC XSDBOOL"` | ⚡ Ready |
| `no-receiving` | [ZCL_SKYLINT_NO_RECEIVING](src/checks/zcl_skylint_no_receiving.clas.abap) | Omit RECEIVING in method calls | `OMITRECEIV` | `"#EC RECEIVING"` | ⚡ Ready |
| `no-static-via-instance` | [ZCL_SKYLINT_NO_STATIC_ARROW](src/checks/zcl_skylint_no_static_arrow.clas.abap) | Avoid calling static methods via instance arrow (->) | `STATICVIAI` | `"#EC STATIC_ARROW"` | ⚡ Ready |
| `no-public-attributes` | [ZCL_SKYLINT_NO_PUBLIC_ATTR](src/checks/zcl_skylint_no_public_attr.clas.abap) | Avoid mutable public attributes in classes | `NOPUBATTR` | `"#EC PUBLIC_ATTR"` | — |
| `no-obsolete-statements` | [ZCL_SKYLINT_NO_OBSOLETE](src/checks/zcl_skylint_no_obsolete.clas.abap) | Avoid obsolete or deprecated statements (MOVE, REFRESH, BREAK, STATICS, etc.) | `OBSOLETE` | `"#EC OBSOLETE"` | ⚡ Ready |
| `max-params` | [ZCL_SKYLINT_MAX_PARAMS](src/checks/zcl_skylint_max_params.clas.abap) | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `"#EC MAX_PARAMS"` | — |
| `no-db-in-loop` | [ZCL_SKYLINT_NO_DB_IN_LOOP](src/checks/zcl_skylint_no_db_in_loop.clas.abap) | Avoid database access inside loop iterations | `DBINLOOP` | `"#EC DB_IN_LOOP"` | — |
| `no-empty-fae` | [ZCL_SKYLINT_NO_EMPTY_FAE](src/checks/zcl_skylint_no_empty_fae.clas.abap) | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `"#EC EMPTY_FAE"` | ⚡ Ready |
| `no-select-star` | [ZCL_SKYLINT_NO_SELECT_STAR](src/checks/zcl_skylint_no_select_star.clas.abap) | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `"#EC SELECT_STAR"` | — |
| `no-scope-leak` | [ZCL_SKYLINT_NO_SCOPE_LEAK](src/checks/zcl_skylint_no_scope_leak.clas.abap) | Scope of variable (avoid variable leaking outside control blocks) | `SCOPELEAK` | `"#EC SCOPE_LEAK"` | — |
| `no-self-assignment` | [ZCL_SKYLINT_NO_SELF_ASSIGN](src/checks/zcl_skylint_no_self_assign.clas.abap) | Detect Identical Self Assignments | `IDENTMOVE` | `"#EC SELF_ASSIGN"` | ⚡ Ready |
| `require-fully-typed` | [ZCL_SKYLINT_PREF_FULL_TYPED](src/checks/zcl_skylint_pref_full_typed.clas.abap) | Enforce fully typed constant declarations | `FULLYTYPED` | `"#EC FULL_TYPED"` | — |
| `no-single-param-name` | [ZCL_SKYLINT_NO_PARAM_NAME](src/checks/zcl_skylint_no_param_name.clas.abap) | Omit parameter name in single parameter method call | `OMITPARM` | `"#EC PARAM_NAME"` | ⚡ Ready |
| `prefer-corresponding` | [ZCL_SKYLINT_PREF_CORRESP](src/checks/zcl_skylint_pref_corresp.clas.abap) | Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `"#EC CORRESP"` | ⚡ Ready |
| `max-method-length` | [ZCL_SKYLINT_MAX_METHOD_LEN](src/checks/zcl_skylint_max_method_len.clas.abap) | Method Length Limit (excessive statement count) | `METHOD_LEN` | `"#EC METHOD_LEN"` | — |
| `max-nesting-depth` | [ZCL_SKYLINT_MAX_NESTING](src/checks/zcl_skylint_max_nesting.clas.abap) | Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `"#EC NESTING"` | — |
| `no-sy-modify` | [ZCL_SKYLINT_NO_SY_MODIFY](src/checks/zcl_skylint_no_sy_modify.clas.abap) | Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `"#EC SY_MODIFY"` | — |
| `prefer-returning` | [ZCL_SKYLINT_PREF_RETURNING](src/checks/zcl_skylint_pref_returning.clas.abap) | Prefer RETURNING over single EXPORTING | `PREFER_RET` | `"#EC RETURNING"` | — |
| `prefer-class-exceptions` | [ZCL_SKYLINT_PREF_CLASS_EXC](src/checks/zcl_skylint_pref_class_exc.clas.abap) | Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `"#EC CLASS_EXC"` | — |
| `dangerous-statement` | [ZCL_SKYLINT_NO_DANGEROUS_STMT](src/checks/zcl_skylint_no_dangerous_stmt.clas.abap) | Dangerous Statements (abaplint dangerous_statement) | `DANGER_STM` | `"#EC DANGEROUS_STMT"` | — |
| `require-auth-check` | [ZCL_SKYLINT_PREF_AUTH_CHECK](src/checks/zcl_skylint_pref_auth_check.clas.abap) | Call Transaction Authority Check | `AUTH_CHECK` | `"#EC AUTH_CHECK"` | ⚡ Ready |
| `require-order-by` | [ZCL_SKYLINT_PREF_ORDER_BY](src/checks/zcl_skylint_pref_order_by.clas.abap) | SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `"#EC ORDER_BY"` | — |
| `max-cyclomatic-complexity` | [ZCL_SKYLINT_MAX_CYCLO_COMP](src/checks/zcl_skylint_max_cyclo_comp.clas.abap) | Cyclomatic Complexity Threshold | `CYCLO_COMP` | `"#EC CYCLO_COMP"` | — |
| `prefer-final-class` | [ZCL_SKYLINT_PREF_FINAL_CLS](src/checks/zcl_skylint_pref_final_cls.clas.abap) | Prefer FINAL Classes by Default | `NOT_FINAL` | `"#EC FINAL_CLS"` | — |
| `no-raise-shortdump` | [ZCL_SKYLINT_NO_SHORTDUMP](src/checks/zcl_skylint_no_shortdump.clas.abap) | Avoid RAISE SHORTDUMP (prefer graceful exceptions) | `SHORTDUMP` | `"#EC SHORTDUMP"` | — |
| `no-magic-numbers` | [ZCL_SKYLINT_NO_MAGIC_NUMBERS](src/checks/zcl_skylint_no_magic_numbers.clas.abap) | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `"#EC MAGIC_NUMBERS"` | — |
| `prefer-insert-into` | [ZCL_SKYLINT_PREF_INSERT](src/checks/zcl_skylint_pref_insert.clas.abap) | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `"#EC INSERT_INTO"` | ⚡ Ready |
| `no-obsolete-loop-control` | [ZCL_SKYLINT_NO_OBS_LOOP_CTL](src/checks/zcl_skylint_no_obs_loop_ctl.clas.abap) | Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP | `OBS_L_CTRL` | `"#EC OBS_LOOP_CTL"` | — |
| `no-like-objects` | [ZCL_SKYLINT_NO_LIKE_OBJECTS](src/checks/zcl_skylint_no_like_objects.clas.abap) | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `"#EC LIKE_OBJECTS"` | — |
| `clean-constructor` | [ZCL_SKYLINT_CLEAN_CTOR](src/checks/zcl_skylint_clean_ctor.clas.abap) | Keep constructors clean; avoid heavy business logic/loops/DB access | `CTOR_LOGIC` | `"#EC CLEAN_CTOR"` | — |
| `no-static-classes` | [ZCL_SKYLINT_NO_STATIC_CLS](src/checks/zcl_skylint_no_static_cls.clas.abap) | Avoid static-only classes; prefer instantiable interface-based design | `STAT_CLASS` | `"#EC STATIC_CLS"` | — |
| `prefer-predicate-names` | [ZCL_SKYLINT_PREF_PRED_NAME](src/checks/zcl_skylint_pref_pred_name.clas.abap) | Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods | `BOOL_NAME` | `"#EC PRED_NAME"` | — |
| `max-inheritance-depth` | [ZCL_SKYLINT_MAX_INHERIT](src/checks/zcl_skylint_max_inherit.clas.abap) | Avoid deep class inheritance hierarchies | `DEEP_INHRT` | `"#EC INHERIT_DEPTH"` | — |
| `max-attributes` | [ZCL_SKYLINT_MAX_ATTRIBUTES](src/checks/zcl_skylint_max_attributes.clas.abap) | Limit number of member attributes in a class (God Class smell) | `ATTR_COUNT` | `"#EC ATTRIBUTES"` | — |
| `no-interface-data` | [ZCL_SKYLINT_NO_INTF_DATA](src/checks/zcl_skylint_no_intf_data.clas.abap) | Avoid mutable DATA declarations in interfaces; allow only CONSTANTS | `INTF_DATA` | `"#EC INTF_DATA"` | — |
| `no-catch-cx-root` | [ZCL_SKYLINT_NO_CATCH_ROOT](src/checks/zcl_skylint_no_catch_root.clas.abap) | Avoid generic CATCH cx_root; catch specific exception classes | `CATCH_ROOT` | `"#EC CATCH_ROOT"` | — |
| `no-message-raising` | [ZCL_SKYLINT_NO_MSG_RAISING](src/checks/zcl_skylint_no_msg_raising.clas.abap) | Avoid obsolete MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `"#EC MSG_RAISING"` | — |
| `no-nested-try` | [ZCL_SKYLINT_NO_NESTED_TRY](src/checks/zcl_skylint_no_nested_try.clas.abap) | Avoid nested TRY blocks; extract inner error handling to helper methods | `NESTED_TRY` | `"#EC NESTED_TRY"` | — |
| `no-raise-cx-sy` | [ZCL_SKYLINT_NO_RAISE_CX_SY](src/checks/zcl_skylint_no_raise_cx_sy.clas.abap) | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `"#EC RAISE_CX_SY"` | — |
| `require-subrc-check` | [ZCL_SKYLINT_CHECK_SUBRC](src/checks/zcl_skylint_check_subrc.clas.abap) | Check sy-subrc after DB, table and string operations | `CHECKSUBRC` | `"#EC CHECK_SUBRC"` | — |
| `no-form-routines` | [ZCL_SKYLINT_NO_FORM](src/checks/zcl_skylint_no_form.clas.abap) | Avoid obsolete FORM routines; use modern methods in ABAP Cloud | `AVOID_FORM` | `"#EC NO_FORM"` | — |
| `no-client-specified` | [ZCL_SKYLINT_NO_CLIENT_SPEC](src/checks/zcl_skylint_no_client_spec.clas.abap) | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPE` | `"#EC CLIENT_SPEC"` | ⚡ Ready |
| `no-commit-work` | [ZCL_SKYLINT_NO_COMMIT_WORK](src/checks/zcl_skylint_no_commit_work.clas.abap) | Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations | `NO_COMMIT` | `"#EC COMMIT_WORK"` | — |
| `require-transporting` | [ZCL_SKYLINT_PREF_TRANSPORT](src/checks/zcl_skylint_pref_transport.clas.abap) | Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause | `FULL_MODIF` | `"#EC TRANSPORTING"` | — |
| `test-method-naming` | [ZCL_SKYLINT_PREF_TEST_NAME](src/checks/zcl_skylint_pref_test_name.clas.abap) | Enforce test method naming convention (TEST_, SHOULD_) in AUnit | `TEST_NAME` | `"#EC TEST_NAME"` | — |
| `prefer-final-method` | [ZCL_SKYLINT_PREF_FINAL_METH](src/checks/zcl_skylint_pref_final_meth.clas.abap) | Prefer marking non-overridden methods as FINAL | `PREF_FINAL` | `"#EC FINAL_METHOD"` | ⚡ Ready |
| `prefer-string-functions` | [ZCL_SKYLINT_PREF_STR_FUNC](src/checks/zcl_skylint_pref_str_func.clas.abap) | Detect obsolete string statements; prefer built-in functions | `CONDENSE_S` | `"#EC STR_FUNC"` | ⚡ Ready |
| `prefer-calc-assign-op` | [ZCL_SKYLINT_PREF_CALC_OP](src/checks/zcl_skylint_pref_calc_op.clas.abap) | Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1 | `CALC_ASSGN` | `"#EC CALC_ASSIGN"` | ⚡ Ready |
| `prefer-early-continue` | [ZCL_SKYLINT_PREF_EARLY_CONT](src/checks/zcl_skylint_pref_early_cont.clas.abap) | Use early CONTINUE guard clause instead of wrapping loop in IF block | `GUARD_LOOP` | `"#EC EARLY_CONTINUE"` | — |
| `prefer-early-return` | [ZCL_SKYLINT_PREF_EARLY_RET](src/checks/zcl_skylint_pref_early_ret.clas.abap) | Use early RETURN guard clause instead of wrapping method in IF block | `GUARD_METH` | `"#EC EARLY_RETURN"` | — |
| `no-production-assert` | [ZCL_SKYLINT_NO_PROD_ASSERT](src/checks/zcl_skylint_no_prod_assert.clas.abap) | Detect native ASSERT in production code; use exceptions instead | `PROD_ASSRT` | `"#EC PROD_ASSERT"` | — |
| `no-unused-variables` | [ZCL_SKYLINT_NO_UNUSED_VARS](src/checks/zcl_skylint_no_unused_vars.clas.abap) | Detect unused local variables and field symbols | `UNUSED_VAR` | `"#EC NEEDED"` | — |
| `require-decl-order` | [ZCL_SKYLINT_PREF_DECL_ORDER](src/checks/zcl_skylint_pref_decl_order.clas.abap) | Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS) | `DECL_ORDER` | `"#EC DECL_ORDER"` | — |
| `no-param-escape` | [ZCL_SKYLINT_NO_PARAM_ESCAPE](src/checks/zcl_skylint_no_param_escape.clas.abap) | Detect unnecessary exclamation mark parameter escape (!iv_param) | `PARAM_ESCP` | `"#EC PARAM_ESCAPE"` | ⚡ Ready |
| `prefer-case` | [ZCL_SKYLINT_PREF_CASE](src/checks/zcl_skylint_pref_case.clas.abap) | Change IF to CASE when checking the same variable against multiple values | `USE_CASE` | `"#EC PREF_CASE"` | — |
| `no-inline-length` | [ZCL_SKYLINT_NO_INLINE_LEN](src/checks/zcl_skylint_no_inline_len.clas.abap) | Avoid inline length specification in declarations | `PAREN_LEN` | `"#EC PAREN_LEN"` | ⚡ Ready |
| `max-one-statement` | [ZCL_SKYLINT_MAX_ONE_STMT](src/checks/zcl_skylint_max_one_stmt.clas.abap) | Max One Statement Per Line | `ONE_STMT` | `"#EC ONE_STMT"` | — |
| `names-no-dash` | [ZCL_SKYLINT_NAMES_NO_DASH](src/checks/zcl_skylint_names_no_dash.clas.abap) | No Dashes in Variable and Form Names | `NO_DASH` | `"#EC NO_DASH"` | — |
| `prefer-inline` | [ZCL_SKYLINT_PREF_INLINE](src/checks/zcl_skylint_pref_inline.clas.abap) | Prefer Inline Declarations | `PREF_INL` | `"#EC PREFER_INLINE"` | — |
| `slow-param-passing` | [ZCL_SKYLINT_SLOW_PARAM_PASS](src/checks/zcl_skylint_slow_param_pass.clas.abap) | Slow Parameter Passing | `SLOW_PASS` | `"#EC SLOW_PARAM"` | — |
| `modify-own-tables` | [ZCL_SKYLINT_MODIFY_OWN_TAB](src/checks/zcl_skylint_modify_own_tab.clas.abap) | Modify Only Own Database Tables | `NOT_OWN_TB` | `"#EC OWN_TABLES"` | — |
| `no-dynamic-stuff` | [ZCL_SKYLINT_NO_DYNAMIC_STMT](src/checks/zcl_skylint_no_dynamic_stmt.clas.abap) | No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.) | `DYN_STUFF` | `"#EC NO_DYNAMIC"` | — |

---

## 🚀 How to Author a Custom Skylint Check

Authoring a check in Skylint requires extending `zcl_skylint_check_base` and implementing two methods:

### Step 1: Define Check Metadata & Inspection Logic (`src/checks/zcl_skylint_pref_is_not.clas.abap`)

```abap
CLASS zcl_skylint_pref_is_not DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_is_not TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFERISNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'IS_NOT'.

ENDCLASS.


CLASS zcl_skylint_pref_is_not IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
      VALUE #( description       = 'Prefer IS NOT over NOT IS'
               remote_enablement = abap_true
               finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_is_not
                                              severity       = if_ci_atc_check=>finding_severities-warning
                                              text           = 'Use IS NOT instead of NOT ... IS INITIAL'
                                              pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CHECK'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_is_not ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

### Step 2: Add Test Fixtures (`test/fixtures/prefer-is-not/`)

Each check keeps a fixture directory as test data, executed by the
ATC-native JS harness (`test/run.mjs`):

* `source.abap` — full test class source (sliced per `METHOD` or per `CLASS DEFINITION` block).
* `expected.json` — expected findings, e.g.:
  ```json
  [
    { "method": "TEST_001", "code": "PREFERISNT", "line": 2, "column": 4 },
    { "method": "TEST_002", "code": null }
  ]
  ```
  `code: null` asserts zero findings. Line numbers are relative to the sliced
  block (line 1 = `METHOD` statement).

  > Fixture-based verification runs locally: `npm run build && node test/run.mjs`.
  > The harness parses fixtures into `ty_procedure` values and drives the real
  > `if_ci_atc_check~run` with JS test doubles for the SAP boundary.

### Step 3: Add Native QuickFix Support (Optional)

Checks can register automated QuickFix transformations:

```abap
" 1. Register QuickFix in constructor:
super->constructor(
    VALUE #(
        ...
        quickfix_codes = VALUE #(
            ( code       = c_quickfix_codes-prefer_is_not
              short_text = 'Replace with IS NOT' ) ) ) ).

" 2. Generate and attach quickfix in check():
DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.

ls_quickfix = quickfix_replace(
    iv_quickfix_code  = c_quickfix_codes-prefer_is_not
    iv_statement_from = sy-tabix
    it_new_code       = VALUE #( ( 'CHECK lv_val IS NOT INITIAL.' ) ) ).

report_statement( is_statement    = <ls_statement>
                  iv_finding_code = c_finding_codes-prefer_is_not
                  is_quickfix     = ls_quickfix ).

" 3. Verify findings via the fixture (`test/fixtures/prefer-is-not/expected.json`).
```

---

## 🛠️ Available Base APIs (`zcl_skylint_check_base`)

| Method | Description |
|---|---|
| `report_statement( is_statement, iv_finding_code, is_quickfix )` | Reports a finding for a statement with auto checksum/location and pseudo-comment suppression. |
| `report_token( is_token, is_statement, iv_finding_code, is_quickfix )` | Reports a finding pinpointing a specific token column. |
| `quickfix_replace( iv_quickfix_code, iv_statement_from, it_new_code, ... )` | Constructs a standardized QuickFix replacement descriptor. |

---

## 🏛️ Architecture

Single-branch, ATC-native delivery — no adapters, no platform branches:

```
           ┌──────────────────────────────────────────────┐
           │              main (ATC-Native)               │
           │  • 84 Rules (if_ci_atc_check)               │
           │  • Framework Types (if_ci_atc_*)            │
           │  • Shared Base + Metadata (core/)           │
           └──────────────────────────────────────────────┘
```

1. **`src/core/`**: `zcl_skylint_check_base` (implements `if_ci_atc_check`: procedure loop, checksum/location, quickfix contexts), `zcl_skylint_check_meta_data` (shared `if_ci_atc_check_meta_data`), AST/RTTI utilities.
2. **`src/checks/`**: 84 rule classes, each directly selectable in ATC check variants.
3. **`deps/atc/src/`**: Local-only ATC framework stubs for abaplint resolution — never shipped via abapGit (real SAP systems provide these natively).

---

## 🧪 Development & Verification

```bash
# 1. Install dependencies & initialize git submodules
npm install
npm run deps

# 2. Run abaplint validation (ABAP Cloud syntax)
npm run lint

# 3. Transpile and execute all unit tests & QuickFix round-trip validations
npm test

# Run a specific check fixture
node test/run.mjs prefer-lines

# Re-index check rules and synchronize the rule catalog
npm run index
```

> **Testing Architecture:** The test harness (`test/run.mjs`) is ATC-native. Fixtures are parsed into `ty_procedure` values and run through the actual transpiled `if_ci_atc_check~run` methods using JS test doubles for the SAP boundary. Every registered QuickFix is re-parsed via `@abaplint/core` (`test/roundtrip.mjs`) to verify syntax validity.

---

## Scanner (CLI)

Scan any folder for `*.abap` files with rust-style diagnostics. Requires a prior `npm run build` (checks run transpiled, exactly as tested):

```bash
# Scan folder with rust-style diagnostics
npx skylint scan ./src

# Only some checks, JSON / SARIF output, explicit config
npx skylint scan ./src --filter prefer-lines --json --config skylint.yaml
npx skylint scan ./src --sarif > results.sarif

# Apply QuickFixes (writes files; each fix is syntax re-validated, overlapping
# fixes are skipped, a file that would break is reverted untouched)
npx skylint scan ./src --fix
npx skylint scan ./src --fix --dry-run

# Explain a specific rule with Bad vs Good examples
npx skylint explain prefer-lines

# Write a default skylint.yaml configuration (never overwrites)
npx skylint init
```

```text
warning: Avoid chained declarations; declare each entity individually
 --> C:\projects\customer\src\zcl_demo.clas.abap:16:5
   |
16 |     DATA: lv_a TYPE i,
   |     ^^^^^^^^^^^^^^^^^
   |
  = note: [CHAINDECL check_no-chained-decl] quickfix: PREFINLDCL
```

Exit codes: `0` clean, `1` issues remain, `2` usage/build error.

### skylint.yaml

Optional project config, auto-discovered as `skylint.yaml` / `.skylint.yaml` / `skylint.yml` in the scanned folder or cwd (or `--config <file>`):

```yaml
minSeverity: warning      # hide notes (error | warning | note)
exclude:
  - "**/*.testclasses.abap"
checks:
  max-method-length:
    enabled: false
  no-me-reference:
    severity: note        # error | warning | note
```

---

## 📦 Deployment via abapGit

1. Clone **`main`** via **abapGit** in your BTP ABAP Environment or S/4HANA system.
2. Activate all objects and add the check classes (`ZCL_SKYLINT_*`) to your ATC Check Variant.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

