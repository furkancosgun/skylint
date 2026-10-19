<p align="center">
  <img src="docs/public/logo.svg" width="120" height="120" alt="Skylint Logo" />
</p>

<h1 align="center">Skylint</h1>

<p align="center">
  <strong>Enterprise Clean ABAP & Cloud ATC Linter Engine</strong>
</p>

<p align="center">
  <a href="https://github.com/furkancosgun/skylint/actions/workflows/ci.yml"><img src="https://github.com/furkancosgun/skylint/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="https://furkancosgun.github.io/skylint/"><img src="https://img.shields.io/badge/docs-online-blue.svg" alt="Docs" /></a>
  <a href="#-clean-abap--cloud-rule-catalog-94-rules"><img src="https://img.shields.io/badge/rules-94-brightgreen.svg" alt="Rules" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-yellow.svg" alt="License" /></a>
</p>

> 📖 **Full Documentation & Interactive Rule Guide:** [https://furkancosgun.github.io/skylint/](https://furkancosgun.github.io/skylint/)

**Skylint** is an extensible, high-performance static code analysis framework for ABAP. Every rule is a **native ATC check** (`if_ci_atc_check`) running directly on SAP BTP ABAP Environment & S/4HANA (ABAP Cloud).

---

## ⚡ Highlights

- **Native SAP ATC:** Every check implements `if_ci_atc_check` directly and runs natively in Eclipse ADT and SAP GUI.
- **94 Clean ABAP Rules:** Comprehensive checks for modern syntax, expressions, safety, and performance.
- **Automated QuickFixes:** Built-in QuickFix engine for instant refactoring via `Ctrl + 1`.
- **Zero Boilerplate:** Base class encapsulates statement traversal, finding reporting, and pseudo-comment handling.
- **CLI & CI/CD Ready:** Fast local CLI (`npx skylint scan`) and automated GitHub Actions CI & Pages deployment.

---

## 📁 Repository Structure

```text
skylint/
├── src/
│   ├── core/         # Base check class, metadata, AST & RTTI utilities
│   ├── checks/       # 94 modular check implementations
│   └── atc/          # Generated ATC objects (CHKC, CHKO, CHKV)
├── bin/              # Executable CLI (skylint scan, explain, init)
├── docs/             # VitePress enterprise documentation source
├── test/             # Test fixtures and ATC-native runner
├── abaplint.json     # Linter configuration (ABAP Cloud)
└── package.json      # Build, test, and indexing scripts
```

---

## 📋 Clean ABAP & Cloud Rule Catalog (94 Rules)

All Clean ABAP, security, and cloud-native rules implemented in Skylint:

| Rule ID | ABAP Class | Description | Finding Code | Pseudo-Comment | QuickFix |
|---|---|---|:---:|:---:|:---:|
| `prefer-lines` | [ZCL_SKYLINT_PREF_LINES](src/checks/zcl_skylint_pref_lines.clas.abap) | Prefer lines( ) over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `"#EC LINES"` | ⚡ Ready |
| `no-call-method` | [ZCL_SKYLINT_NO_CALL_METHOD](src/checks/zcl_skylint_no_call_method.clas.abap) | Avoid static CALL METHOD statements | `CALLMETHOD` | `"#EC CALL_METH"` | ⚡ Ready |
| `no-default-key` | [ZCL_SKYLINT_NO_DEFAULT_KEY](src/checks/zcl_skylint_no_default_key.clas.abap) | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `"#EC DEFAULT_KEY"` | ⚡ Ready |
| `prefer-is-not` | [ZCL_SKYLINT_PREF_IS_NOT](src/checks/zcl_skylint_pref_is_not.clas.abap) | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `"#EC IS_NOT"` | ⚡ Ready |
| `no-me-reference` | [ZCL_SKYLINT_NO_ME_REFERENCE](src/checks/zcl_skylint_no_me_reference.clas.abap) | Avoid self-reference ME-> | `AVOIDME` | `"#EC ME"` | — |
| `no-redundant-method-call` | [ZCL_SKYLINT_NO_REDUNDANT_CALL](src/checks/zcl_skylint_no_redundant_call.clas.abap) | Omit redundant EXPORTING and RECEIVING in method calls | `OMITEXPORT` | `"#EC EXPORTING"` | ⚡ Ready |
| `no-chained-statements` | [ZCL_SKYLINT_NO_CHAINED_STMT](src/checks/zcl_skylint_no_chained_stmt.clas.abap) | Avoid chained declarations and chained assignments | `CHAINDECL` | `"#EC CHAIN_DECL"` | ⚡ Ready |
| `prefer-string-template` | [ZCL_SKYLINT_PREF_STR_TMPL](src/checks/zcl_skylint_pref_str_tmpl.clas.abap) | Prefer string templates over CONCATENATE | `CONCATSTR` | `"#EC STR_TMPL"` | ⚡ Ready |
| `no-boolean-comparison` | [ZCL_SKYLINT_NO_BOOL_COMPARE](src/checks/zcl_skylint_no_bool_compare.clas.abap) | Avoid comparing boolean method calls to boolean literals | `BOOLCOMP` | `"#EC BOOL_COMPARE"` | ⚡ Ready |
| `prefer-line-exists` | [ZCL_SKYLINT_PREF_LINE_EXISTS](src/checks/zcl_skylint_pref_line_exists.clas.abap) | Prefer line_exists( ) over READ TABLE with NO FIELDS | `PREFLINEX` | `"#EC LINE_EXISTS"` | — |
| `prefer-return` | [ZCL_SKYLINT_PREF_RETURN](src/checks/zcl_skylint_pref_return.clas.abap) | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `"#EC RETURN"` | ⚡ Ready |
| `no-check-statement` | [ZCL_SKYLINT_NO_CHECK_STMT](src/checks/zcl_skylint_no_check_stmt.clas.abap) | Avoid CHECK statements; prefer IF with RETURN or CONTINUE | `CHKINLOOP` | `"#EC CHECK_STMT"` | ⚡ Ready |
| `no-empty-block` | [ZCL_SKYLINT_NO_EMPTY_BLOCK](src/checks/zcl_skylint_no_empty_block.clas.abap) | Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.) | `EMPTYCTRL` | `"#EC EMPTY_BLOCK"` | — |
| `no-duplicate-conditions` | [ZCL_SKYLINT_NO_DUP_COND](src/checks/zcl_skylint_no_dup_cond.clas.abap) | Avoid duplicate branch conditions in IF and CASE | `DUPCOND` | `"#EC DUP_COND"` | — |
| `prefer-merged-ifs` | [ZCL_SKYLINT_PREF_MERGE_IFS](src/checks/zcl_skylint_pref_merge_ifs.clas.abap) | Merge consecutive nested IF blocks using boolean AND | `NESTEDIF` | `"#EC MERGE_IFS"` | — |
| `no-unreachable-code` | [ZCL_SKYLINT_NO_UNREACHABLE](src/checks/zcl_skylint_no_unreachable.clas.abap) | Detect unreachable code after jump or exit statements | `UNREACHCD` | `"#EC UNREACHABLE"` | ⚡ Ready |
| `no-single-when` | [ZCL_SKYLINT_NO_SINGLE_WHEN](src/checks/zcl_skylint_no_single_when.clas.abap) | Avoid CASE statements with only one WHEN branch | `SHORTCASE` | `"#EC SINGLE_WHEN"` | — |
| `no-yoda-conditions` | [ZCL_SKYLINT_NO_YODA_COND](src/checks/zcl_skylint_no_yoda_cond.clas.abap) | Avoid Yoda conditions in comparison expressions | `YODACOND` | `"#EC YODA_COND"` | ⚡ Ready |
| `prefer-symbol-operators` | [ZCL_SKYLINT_PREF_SYMBOL_OP](src/checks/zcl_skylint_pref_symbol_op.clas.abap) | Prefer symbolic operators over textual EQ, NE, LT, GT | `PREFEROP` | `"#EC SYMBOL_OP"` | ⚡ Ready |
| `prefer-new-operator` | [ZCL_SKYLINT_PREF_NEW_OP](src/checks/zcl_skylint_pref_new_op.clas.abap) | Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION | `PREFERNEW` | `"#EC NEW_OP"` | ⚡ Ready |
| `prefer-xsdbool` | [ZCL_SKYLINT_PREF_XSDBOOL](src/checks/zcl_skylint_pref_xsdbool.clas.abap) | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDB` | `"#EC XSDBOOL"` | ⚡ Ready |
| `no-static-via-instance` | [ZCL_SKYLINT_NO_STATIC_ARROW](src/checks/zcl_skylint_no_static_arrow.clas.abap) | Avoid calling static methods via instance arrow (->) | `STATICVIAI` | `"#EC STATIC_ARROW"` | ⚡ Ready |
| `no-public-attributes` | [ZCL_SKYLINT_NO_PUBLIC_ATTR](src/checks/zcl_skylint_no_public_attr.clas.abap) | Avoid mutable public attributes in classes | `NOPUBATTR` | `"#EC PUBLIC_ATTR"` | — |
| `no-obsolete-statements` | [ZCL_SKYLINT_NO_OBSOLETE](src/checks/zcl_skylint_no_obsolete.clas.abap) | Avoid obsolete statements (MOVE, REFRESH, FORM, etc.) | `OBSOLETE` | `"#EC OBSOLETE"` | ⚡ Ready |
| `max-params` | [ZCL_SKYLINT_MAX_PARAMS](src/checks/zcl_skylint_max_params.clas.abap) | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `"#EC MAX_PARAMS"` | — |
| `no-db-in-loop` | [ZCL_SKYLINT_NO_DB_IN_LOOP](src/checks/zcl_skylint_no_db_in_loop.clas.abap) | Avoid database access inside loop iterations | `DBINLOOP` | `"#EC DB_IN_LOOP"` | — |
| `no-empty-fae` | [ZCL_SKYLINT_NO_EMPTY_FAE](src/checks/zcl_skylint_no_empty_fae.clas.abap) | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `"#EC EMPTY_FAE"` | ⚡ Ready |
| `no-select-star` | [ZCL_SKYLINT_NO_SELECT_STAR](src/checks/zcl_skylint_no_select_star.clas.abap) | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `"#EC SELECT_STAR"` | — |
| `no-scope-leak` | [ZCL_SKYLINT_NO_SCOPE_LEAK](src/checks/zcl_skylint_no_scope_leak.clas.abap) | Avoid variable usage outside its declaring control block | `SCOPELEAK` | `"#EC SCOPE_LEAK"` | — |
| `no-self-assignment` | [ZCL_SKYLINT_NO_SELF_ASSIGN](src/checks/zcl_skylint_no_self_assign.clas.abap) | Detect Identical Self Assignments | `IDENTMOVE` | `"#EC SELF_ASSIGN"` | ⚡ Ready |
| `prefer-fully-typed` | [ZCL_SKYLINT_PREF_FULL_TYPED](src/checks/zcl_skylint_pref_full_typed.clas.abap) | Enforce fully typed constant declarations | `FULLYTYPED` | `"#EC FULL_TYPED"` | — |
| `prefer-corresponding` | [ZCL_SKYLINT_PREF_CORRESP](src/checks/zcl_skylint_pref_corresp.clas.abap) | Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `"#EC CORRESP"` | ⚡ Ready |
| `max-method-length` | [ZCL_SKYLINT_MAX_METHOD_LEN](src/checks/zcl_skylint_max_method_len.clas.abap) | Method Length Limit (excessive statement count) | `METHOD_LEN` | `"#EC METHOD_LEN"` | — |
| `max-nesting-depth` | [ZCL_SKYLINT_MAX_NESTING](src/checks/zcl_skylint_max_nesting.clas.abap) | Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `"#EC NESTING"` | — |
| `no-sy-modify` | [ZCL_SKYLINT_NO_SY_MODIFY](src/checks/zcl_skylint_no_sy_modify.clas.abap) | Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `"#EC SY_MODIFY"` | — |
| `prefer-returning` | [ZCL_SKYLINT_PREF_RETURNING](src/checks/zcl_skylint_pref_returning.clas.abap) | Prefer RETURNING over single EXPORTING | `PREFER_RET` | `"#EC RETURNING"` | — |
| `prefer-class-exceptions` | [ZCL_SKYLINT_PREF_CLASS_EXC](src/checks/zcl_skylint_pref_class_exc.clas.abap) | Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `"#EC CLASS_EXC"` | — |
| `no-dangerous-statements` | [ZCL_SKYLINT_NO_DANGEROUS_STMT](src/checks/zcl_skylint_no_dangerous_stmt.clas.abap) | Dangerous Statements (abaplint dangerous_statement) | `DANGER_STM` | `"#EC DANGEROUS_STMT"` | — |
| `prefer-auth-check` | [ZCL_SKYLINT_PREF_AUTH_CHECK](src/checks/zcl_skylint_pref_auth_check.clas.abap) | Call Transaction Authority Check | `AUTH_CHECK` | `"#EC AUTH_CHECK"` | ⚡ Ready |
| `prefer-order-by` | [ZCL_SKYLINT_PREF_ORDER_BY](src/checks/zcl_skylint_pref_order_by.clas.abap) | SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `"#EC ORDER_BY"` | — |
| `max-cyclomatic-complexity` | [ZCL_SKYLINT_MAX_CYCLO_COMP](src/checks/zcl_skylint_max_cyclo_comp.clas.abap) | Cyclomatic Complexity Threshold | `CYCLO_COMP` | `"#EC CYCLO_COMP"` | — |
| `prefer-final-class` | [ZCL_SKYLINT_PREF_FINAL_CLS](src/checks/zcl_skylint_pref_final_cls.clas.abap) | Prefer FINAL classes and methods by default | `NOT_FINAL` | `"#EC FINAL_CLS"` | ⚡ Ready |
| `no-magic-numbers` | [ZCL_SKYLINT_NO_MAGIC_NUMBERS](src/checks/zcl_skylint_no_magic_numbers.clas.abap) | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `"#EC MAGIC_NUMBERS"` | — |
| `prefer-insert-into` | [ZCL_SKYLINT_PREF_INSERT](src/checks/zcl_skylint_pref_insert.clas.abap) | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `"#EC INSERT_INTO"` | ⚡ Ready |
| `no-like-objects` | [ZCL_SKYLINT_NO_LIKE_OBJECTS](src/checks/zcl_skylint_no_like_objects.clas.abap) | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `"#EC LIKE_OBJECTS"` | — |
| `max-constructor-statements` | [ZCL_SKYLINT_MAX_CTOR_STMTS](src/checks/zcl_skylint_max_ctor_stmts.clas.abap) | Keep constructors clean; avoid heavy logic and DB | `CTOR_LOGIC` | `"#EC CLEAN_CTOR"` | — |
| `no-static-classes` | [ZCL_SKYLINT_NO_STATIC_CLS](src/checks/zcl_skylint_no_static_cls.clas.abap) | Avoid static-only classes; use instantiable classes | `STAT_CLASS` | `"#EC STATIC_CLS"` | — |
| `prefer-predicate-names` | [ZCL_SKYLINT_PREF_PRED_NAME](src/checks/zcl_skylint_pref_pred_name.clas.abap) | Enforce predicate naming (IS_, HAS_) on boolean methods | `BOOL_NAME` | `"#EC PRED_NAME"` | — |
| `max-inheritance-depth` | [ZCL_SKYLINT_MAX_INHERIT](src/checks/zcl_skylint_max_inherit.clas.abap) | Avoid deep class inheritance hierarchies | `DEEP_INHRT` | `"#EC INHERIT_DEPTH"` | — |
| `max-attributes` | [ZCL_SKYLINT_MAX_ATTRIBUTES](src/checks/zcl_skylint_max_attributes.clas.abap) | Limit class member attributes to prevent God Classes | `ATTR_COUNT` | `"#EC ATTRIBUTES"` | — |
| `no-interface-data` | [ZCL_SKYLINT_NO_INTF_DATA](src/checks/zcl_skylint_no_intf_data.clas.abap) | Avoid mutable DATA in interfaces; allow only CONSTANTS | `INTF_DATA` | `"#EC INTF_DATA"` | — |
| `no-catch-cx-root` | [ZCL_SKYLINT_NO_CATCH_ROOT](src/checks/zcl_skylint_no_catch_root.clas.abap) | Catch specific exceptions instead of generic cx_root | `CATCH_ROOT` | `"#EC CATCH_ROOT"` | — |
| `no-message-raising` | [ZCL_SKYLINT_NO_MSG_RAISING](src/checks/zcl_skylint_no_msg_raising.clas.abap) | Avoid MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `"#EC MSG_RAISING"` | — |
| `no-nested-try` | [ZCL_SKYLINT_NO_NESTED_TRY](src/checks/zcl_skylint_no_nested_try.clas.abap) | Avoid nested TRY blocks; extract to helper methods | `NESTED_TRY` | `"#EC NESTED_TRY"` | — |
| `no-raise-cx-sy` | [ZCL_SKYLINT_NO_RAISE_CX_SY](src/checks/zcl_skylint_no_raise_cx_sy.clas.abap) | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `"#EC RAISE_CX_SY"` | — |
| `prefer-subrc-check` | [ZCL_SKYLINT_PREF_CHECK_SUBRC](src/checks/zcl_skylint_pref_check_subrc.clas.abap) | Check sy-subrc after DB, table and string operations | `CHECKSUBRC` | `"#EC CHECK_SUBRC"` | — |
| `no-client-specified` | [ZCL_SKYLINT_NO_CLIENT_SPEC](src/checks/zcl_skylint_no_client_spec.clas.abap) | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPE` | `"#EC CLIENT_SPEC"` | ⚡ Ready |
| `no-commit-work` | [ZCL_SKYLINT_NO_COMMIT_WORK](src/checks/zcl_skylint_no_commit_work.clas.abap) | Avoid COMMIT and ROLLBACK in application logic | `NO_COMMIT` | `"#EC COMMIT_WORK"` | — |
| `prefer-transporting` | [ZCL_SKYLINT_PREF_TRANSPORT](src/checks/zcl_skylint_pref_transport.clas.abap) | Avoid MODIFY itab in LOOP without TRANSPORTING clause | `FULL_MODIF` | `"#EC TRANSPORTING"` | — |
| `prefer-string-functions` | [ZCL_SKYLINT_PREF_STR_FUNC](src/checks/zcl_skylint_pref_str_func.clas.abap) | Detect obsolete string statements; prefer built-in functions | `CONDENSE_S` | `"#EC STR_FUNC"` | ⚡ Ready |
| `prefer-calc-assign-op` | [ZCL_SKYLINT_PREF_CALC_OP](src/checks/zcl_skylint_pref_calc_op.clas.abap) | Prefer calculation assignment operators (+=, -=, *=, /=) | `CALC_ASSGN` | `"#EC CALC_ASSIGN"` | ⚡ Ready |
| `prefer-early-return` | [ZCL_SKYLINT_PREF_EARLY_RET](src/checks/zcl_skylint_pref_early_ret.clas.abap) | Prefer early return or continue over nested IF blocks | `GUARD_METH` | `"#EC EARLY_RETURN"` | — |
| `no-unused-variables` | [ZCL_SKYLINT_NO_UNUSED_VARS](src/checks/zcl_skylint_no_unused_vars.clas.abap) | Detect unused local variables and field symbols | `UNUSED_VAR` | `"#EC NEEDED"` | — |
| `prefer-decl-order` | [ZCL_SKYLINT_PREF_DECL_ORDER](src/checks/zcl_skylint_pref_decl_order.clas.abap) | Enforce declaration order (TYPES, CONSTANTS, DATA, FS) | `DECL_ORDER` | `"#EC DECL_ORDER"` | — |
| `no-param-escape` | [ZCL_SKYLINT_NO_PARAM_ESCAPE](src/checks/zcl_skylint_no_param_escape.clas.abap) | Avoid unnecessary parameter escape (!param) | `PARAM_ESCP` | `"#EC PARAM_ESCAPE"` | ⚡ Ready |
| `prefer-case` | [ZCL_SKYLINT_PREF_CASE](src/checks/zcl_skylint_pref_case.clas.abap) | Use CASE instead of IF when checking multiple values | `USE_CASE` | `"#EC PREF_CASE"` | — |
| `no-inline-length` | [ZCL_SKYLINT_NO_INLINE_LEN](src/checks/zcl_skylint_no_inline_len.clas.abap) | Avoid inline length specification in declarations | `PAREN_LEN` | `"#EC PAREN_LEN"` | ⚡ Ready |
| `max-one-statement` | [ZCL_SKYLINT_MAX_ONE_STMT](src/checks/zcl_skylint_max_one_stmt.clas.abap) | Max One Statement Per Line | `ONE_STMT` | `"#EC ONE_STMT"` | — |
| `no-dash-in-names` | [ZCL_SKYLINT_NO_DASH_IN_NAMES](src/checks/zcl_skylint_no_dash_in_names.clas.abap) | No Dashes in Variable and Form Names | `NO_DASH` | `"#EC NO_DASH"` | — |
| `prefer-inline` | [ZCL_SKYLINT_PREF_INLINE](src/checks/zcl_skylint_pref_inline.clas.abap) | Prefer Inline Declarations | `PREF_INL` | `"#EC PREFER_INLINE"` | — |
| `prefer-final-data` | [ZCL_SKYLINT_PREF_FINAL_DATA](src/checks/zcl_skylint_pref_final_data.clas.abap) | Declare inline variables as FINAL when never written again | `PREF_FIN` | `"#EC PREF_FINAL"` | ⚡ Ready |
| `no-friends` | [ZCL_SKYLINT_NO_FRIENDS](src/checks/zcl_skylint_no_friends.clas.abap) | Avoid FRIENDS in class definitions | `NO_FRIENDS` | `"#EC FRIENDS"` | — |
| `prefer-message-class` | [ZCL_SKYLINT_PREF_MSG_CLS](src/checks/zcl_skylint_pref_msg_cls.clas.abap) | Use a message class instead of inline message text | `PREF_MSG` | `"#EC MSG_CLASS"` | — |
| `prefer-inline-cast` | [ZCL_SKYLINT_PREF_INL_CAST](src/checks/zcl_skylint_pref_inl_cast.clas.abap) | Inline a CAST helper that is only read once | `PREF_ICST` | `"#EC INLINE_CAST"` | ⚡ Ready |
| `no-exception-overlap` | [ZCL_SKYLINT_NO_EXC_OVERLAP](src/checks/zcl_skylint_no_exc_overlap.clas.abap) | Classic EXCEPTIONS must not overlap | `NO_EXC_OVL` | `"#EC EXC_OVERLAP"` | — |
| `no-rfc-error-handling` | [ZCL_SKYLINT_NO_RFC_ERR](src/checks/zcl_skylint_no_rfc_err.clas.abap) | RFC calls must handle system failures | `NO_RFC_ERR` | `"#EC RFC_ERR"` | — |
| `no-many-parentheses` | [ZCL_SKYLINT_NO_MANY_PARENS](src/checks/zcl_skylint_no_many_parens.clas.abap) | Remove redundant parentheses | `MANY_PAREN` | `"#EC MANY_PARENS"` | ⚡ Ready |
| `prefer-pass-by-reference` | [ZCL_SKYLINT_PREF_PASS_BY_REF](src/checks/zcl_skylint_pref_pass_by_ref.clas.abap) | Slow Parameter Passing | `SLOW_PASS` | `"#EC SLOW_PARAM"` | — |
| `no-modify-standard-tables` | [ZCL_SKYLINT_NO_MOD_STD_TABLE](src/checks/zcl_skylint_no_mod_std_table.clas.abap) | Modify Only Own Database Tables | `NOT_OWN_TB` | `"#EC OWN_TABLES"` | — |
| `no-dynamic-stuff` | [ZCL_SKYLINT_NO_DYNAMIC_STMT](src/checks/zcl_skylint_no_dynamic_stmt.clas.abap) | No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.) | `DYN_STUFF` | `"#EC NO_DYNAMIC"` | — |
| `prefer-public-constructor` | [ZCL_SKYLINT_PREF_PUB_CTOR](src/checks/zcl_skylint_pref_pub_ctor.clas.abap) | Declare Constructor in PUBLIC SECTION | `CTOR_PUB` | `"#EC PUB_CTOR"` | — |
| `prefer-definitions-top` | [ZCL_SKYLINT_PREF_DEF_TOP](src/checks/zcl_skylint_pref_def_top.clas.abap) | Place definitions at beginning of routine | `DEF_TOP` | `"#EC DEF_TOP"` | — |
| `no-unnecessary-return` | [ZCL_SKYLINT_NO_UNNEC_RETURN](src/checks/zcl_skylint_no_unnec_return.clas.abap) | Omit unnecessary RETURN at end of routine | `UNNEC_RET` | `"#EC NO_UNNEC_RETURN"` | ⚡ Ready |
| `mix-returning` | [ZCL_SKYLINT_NO_MIX_RETURNING](src/checks/zcl_skylint_no_mix_returning.clas.abap) | Do not mix RETURNING with EXPORTING or CHANGING | `MIX_RET` | `"#EC NO_MIX_RETURNING"` | — |
| `method-overwrites-builtin` | [ZCL_SKYLINT_NO_OVERW_BUILTIN](src/checks/zcl_skylint_no_overw_builtin.clas.abap) | Method name overwrites built-in SAP function | `BUILTIN` | `"#EC NO_OVERW_BUILTIN"` | — |
| `max-one-method-parameter-per-line` | [ZCL_SKYLINT_MAX_PARAM_LINE](src/checks/zcl_skylint_max_param_line.clas.abap) | Max one method parameter definition per line | `PARAM_LINE` | `"#EC MAX_PARAM_LINE"` | — |
| `prefer-is-initial` | [ZCL_SKYLINT_PREF_IS_INITIAL](src/checks/zcl_skylint_pref_is_initial.clas.abap) | Prefer IS [NOT] INITIAL over lines( ) or empty literals | `PREF_INIT` | `"#EC PREF_INIT"` | ⚡ Ready |
| `no-ignored-return-value` | [ZCL_SKYLINT_NO_IGNORED_RETURN](src/checks/zcl_skylint_no_ignored_return.clas.abap) | Disallow ignoring the return value of functional methods | `IGNRET` | `"#EC NO_IGNORED_RET"` | — |
| `prefer-cast` | [ZCL_SKYLINT_PREF_CAST](src/checks/zcl_skylint_pref_cast.clas.abap) | Prefer modern CAST #( ) expression over ?= | `PREFCAST` | `"#EC PREF_CAST"` | ⚡ Ready |
| `no-redundant-clear` | [ZCL_SKYLINT_NO_REDUNDANT_CLEAR](src/checks/zcl_skylint_no_redundant_clear.clas.abap) | Do not CLEAR or FREE variables redundantly | `REDUNCLEAR` | `"#EC REDUNDANT_CLEAR"` | ⚡ Ready |
| `no-modify-loop-table` | [ZCL_SKYLINT_NO_MOD_LOOP_TAB](src/checks/zcl_skylint_no_mod_loop_tab.clas.abap) | Avoid mutating or sorting tables inside loops | `MOD_LOOPTB` | `"#EC LOOP_MODIFY"` | — |
| `no-hardcoded-env-checks` | [ZCL_SKYLINT_NO_HARDCODED_ENV](src/checks/zcl_skylint_no_hardcoded_env.clas.abap) | Avoid reading environment system fields (sy-sysid, etc.) | `ENV_CHECK` | `"#EC HARDCODED_ENV"` | — |
| `max-line-length` | [ZCL_SKYLINT_MAX_LINE_LEN](src/checks/zcl_skylint_max_line_len.clas.abap) | Maximum Line Length | `LINE_LEN` | `"#EC LINE_LEN"` | — |
| `prefer-naming` | [ZCL_SKYLINT_PREF_NAMING](src/checks/zcl_skylint_pref_naming.clas.abap) | Standard Naming Conventions | `ATTR_NAME` | `"#EC NAMING"` | — |

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

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CHECK'.
        CONTINUE.
      ENDIF.

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

Skylint is built directly on the native SAP ATC framework:

1. **`src/core/`**: Base check engine (`zcl_skylint_check_base` implementing `if_ci_atc_check`), shared metadata (`zcl_skylint_check_meta_data`), and AST/RTTI traversal utilities.
2. **`src/checks/`**: 94 modular check classes, each directly selectable in ATC Check Variants (`CHKV`).
3. **`src/atc/`**: Standard ATC category (`CHKC`), check (`CHKO`), and variant (`CHKV`) definitions.
4. **`deps/atc/src/`**: Local ATC framework stubs for offline abaplint validation (excluded from abapGit transports).

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

