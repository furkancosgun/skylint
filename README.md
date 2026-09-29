# ☁️ Skylint

> **Modern, Minimal & Cloud-Native ABAP Linter for SAP BTP & S/4HANA Public Cloud (ATC)**

**Skylint** is an extensible ABAP Test Cockpit (ATC) check framework tailored specifically for **ABAP Cloud** (Language Version 5 / Steampunk / BTP). It provides a clean, zero-boilerplate base architecture to author, execute, and maintain custom Clean ABAP & Security rules with native QuickFix support.

---

## ⚡ Highlights

- **ABAP Cloud Native:** Built upon standard SAP ATC Cloud interfaces (`if_ci_atc_check`, `if_ci_atc_source_code_provider`, `cl_ci_atc_assistant_factory`).
- **Zero Boilerplate Architecture:** Base class (`zcl_skylint_check_base`) encapsulates all lifecycle, procedural iteration, finding construction, and quickfix delegations. Subclasses only require `constructor` and `check`.
- **Stateless Static Engine:** High-performance local helpers (`lcl_reporter`, `lcl_quickfix`) handle location extraction, checksum generation, and pseudo-comment resolution without instance or casting overhead.
- **Enterprise Testing Workflow:** Follows the official SAP ATC testing standard (`cl_ci_atc_unit_driver`), executing checks against dedicated test fixtures in `src/tests/`.
- **QuickFix Ready:** Built-in helper APIs for code replacement, insertion (`insert_before`, `insert_after`), and statement deletion.

---

## 📁 Repository Structure

```text
skylint/
├── src/
│   ├── core/                                     # Core infrastructure & Base classes
│   │   ├── zcl_skylint_check_base.clas.abap     # Abstract Base Check class (if_ci_atc_check)
│   │   ├── zcl_skylint_check_base.clas.locals_imp.abap # Static reporter & quickfix engines
│   │   ├── zcl_skylint_check_meta_data.clas.abap# ATC metadata descriptor & pseudo-comment resolver
│   │   └── zcx_skylint_error.clas.abap          # Core exception class
│   │
│   ├── checks/                                   # 80 Modular ATC Check Implementations (001 - 080)
│   │   ├── zcl_skylint_check_001.clas.abap      # Check class implementation
│   │   ├── zcl_skylint_check_001.clas.xml       # abapGit XML metadata (<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>)
│   │   └── zcl_skylint_check_001.clas.testclasses.abap # ATC Unit Test Driver assertion
│   │
│   └── tests/                                    # Target Test Fixtures
│       ├── zcl_skylint_test_001.clas.abap       # Test fixture with positive, negative & suppressed cases
│       └── zcl_skylint_test_001.clas.xml        # abapGit XML metadata
│
├── mock/                                         # Open-ABAP Transpiler ATC Test Driver & Asserter Mocks
│   ├── cl_ci_atc_unit_driver.clas.abap          # Native ATC driver factory mock
│   └── if_ci_atc_unit_asserter.intf.abap        # Standard ATC Asserter interface mock
├── abaplint.json                                 # abaplint validation configuration & rule sets
└── package.json                                  # Build, transpile, lint, and unit test scripts
```

---

## 📋 Clean ABAP & Cloud Rule Catalog (104 Rules)

All Clean ABAP, security, and cloud-native rules implemented in Skylint:

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **001** | [zcl_skylint_check_001](src/checks/zcl_skylint_check_001.clas.abap) | Usage of TEST-SEAM | `TESTSEAMUS` | `"#EC TEST_SEAM_USAGE"` | ✅ Done | — |
| **002** | [zcl_skylint_check_002](src/checks/zcl_skylint_check_002.clas.abap) | Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `"#EC DESCRIBE_LINES"` | ✅ Done | — |
| **003** | [zcl_skylint_check_003](src/checks/zcl_skylint_check_003.clas.abap) | Avoid static CALL METHOD statements | `CALLMETHOD` | `"#EC CALL_METHOD"` | ✅ Done | — |
| **004** | [zcl_skylint_check_004](src/checks/zcl_skylint_check_004.clas.abap) | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `"#EC DEFAULT_KEY"` | ✅ Done | — |
| **005** | [zcl_skylint_check_005](src/checks/zcl_skylint_check_005.clas.abap) | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `"#EC PREFER_IS_NOT"` | ✅ Done | — |
| **006** | [zcl_skylint_check_006](src/checks/zcl_skylint_check_006.clas.abap) | Avoid self-reference ME-> | `AVOIDME` | `"#EC AVOID_ME"` | ✅ Done | — |
| **007** | [zcl_skylint_check_007](src/checks/zcl_skylint_check_007.clas.abap) | Omit explicit EXPORTING in method calls | `OMITEXPORT` | `"#EC OMIT_EXPORTING"` | ✅ Done | — |
| **008** | [zcl_skylint_check_008](src/checks/zcl_skylint_check_008.clas.abap) | Avoid assignment chaining (a = b = c) | `ASSIGNCHN` | `"#EC ASSIGN_CHAIN"` | ✅ Done | — |
| **009** | [zcl_skylint_check_009](src/checks/zcl_skylint_check_009.clas.abap) | Avoid chained declarations (DATA:, TYPES:, etc.) | `CHAINDECL` | `"#EC CHAIN_DECL"` | ✅ Done | — |
| **010** | [zcl_skylint_check_010](src/checks/zcl_skylint_check_010.clas.abap) | Prefer string templates over CONCATENATE | `CONCATSTR` | `"#EC PREFER_STR_TMPL"` | ✅ Done | — |
| **011** | [zcl_skylint_check_011](src/checks/zcl_skylint_check_011.clas.abap) | Avoid direct comparison against boolean literals (abap_true, | `BOOLCOMP` | `"#EC AVOID_BOOL_COMP"` | ✅ Done | — |
| **012** | [zcl_skylint_check_012](src/checks/zcl_skylint_check_012.clas.abap) | Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS | `PREFLINEX` | `"#EC PREFER_LINE_EXISTS"` | ✅ Done | — |
| **013** | [zcl_skylint_check_013](src/checks/zcl_skylint_check_013.clas.abap) | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `"#EC EXIT_OUTSIDE_LOOP"` | ✅ Done | — |
| **014** | [zcl_skylint_check_014](src/checks/zcl_skylint_check_014.clas.abap) | Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE) | `CHKINLOOP` | `"#EC CHECK_IN_LOOP"` | ✅ Done | — |
| **015** | [zcl_skylint_check_015](src/checks/zcl_skylint_check_015.clas.abap) | Avoid interfaces containing only constants | `CONSTINTF` | `"#EC CONS_INTF"` | ✅ Done | — |
| **016** | [zcl_skylint_check_016](src/checks/zcl_skylint_check_016.clas.abap) | Detect empty control blocks (IF, CASE, LOOP, TRY, etc.) | `EMPTYCTRL` | `"#EC EMPTY_CONTROL_BLOCK"` | ✅ Done | — |
| **017** | [zcl_skylint_check_017](src/checks/zcl_skylint_check_017.clas.abap) | Detect empty CATCH blocks swallowing exceptions | `EMPTYCATCH` | `"#EC NO_HANDLER"` | ✅ Done | — |
| **018** | [zcl_skylint_check_018](src/checks/zcl_skylint_check_018.clas.abap) | Validate unit test assertions (avoid identical act and exp parameters) | `UTASSERT` | `"#EC UT_ASSERT"` | ✅ Done | — |
| **019** | [zcl_skylint_check_019](src/checks/zcl_skylint_check_019.clas.abap) | Detect identical branch conditions in IF/ELSEIF and CASE/WHEN | `DUPCOND` | `"#EC IDENTICAL_CONDITIONS"` | ✅ Done | — |
| **020** | [zcl_skylint_check_020](src/checks/zcl_skylint_check_020.clas.abap) | Detect consecutive nested IF blocks that can be merged with AND | `NESTEDIF` | `"#EC NESTED_IF"` | ✅ Done | — |
| **021** | [zcl_skylint_check_021](src/checks/zcl_skylint_check_021.clas.abap) | Enforce WHEN OTHERS to be the last branch in CASE construct | `WHENOTHERS` | `"#EC WHEN_OTHERS_LAST"` | ✅ Done | — |
| **022** | [zcl_skylint_check_022](src/checks/zcl_skylint_check_022.clas.abap) | Detect unreachable code following unconditional jump statements | `UNREACHCD` | `"#EC UNREACHABLE_CODE"` | ✅ Done | — |
| **023** | [zcl_skylint_check_023](src/checks/zcl_skylint_check_023.clas.abap) | Avoid short CASE constructs with only one WHEN branch; prefer IF | `SHORTCASE` | `"#EC SHORT_CASE"` | ✅ Done | — |
| **024** | [zcl_skylint_check_024](src/checks/zcl_skylint_check_024.clas.abap) | Avoid Yoda conditions in comparison expressions | `YODACOND` | `"#EC NO_YODA_CONDITIONS"` | ✅ Done | — |
| **025** | [zcl_skylint_check_025](src/checks/zcl_skylint_check_025.clas.abap) | Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords | `PREFEROP` | `"#EC PREFER_OPERATORS"` | ✅ Done | — |
| **026** | [zcl_skylint_check_026](src/checks/zcl_skylint_check_026.clas.abap) | Prefer NEW #( ) constructor expression over legacy CREATE OBJECT | `PREFERNEW` | `"#EC PREF_NEW"` | ✅ Done | — |
| **027** | [zcl_skylint_check_027](src/checks/zcl_skylint_check_027.clas.abap) | Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE | `RAISEEXCNEW` | `"#EC RAISE_EXC_NEW"` | ✅ Done | — |
| **028** | [zcl_skylint_check_028](src/checks/zcl_skylint_check_028.clas.abap) | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDBOOL` | `"#EC PREFER_XSDBOOL"` | ✅ Done | — |
| **029** | [zcl_skylint_check_029](src/checks/zcl_skylint_check_029.clas.abap) | Omit RECEIVING in method calls | `OMITRECEIV` | `"#EC RECEIVING_USAGE"` | ✅ Done | — |
| **030** | [zcl_skylint_check_030](src/checks/zcl_skylint_check_030.clas.abap) | Avoid calling static methods via instance arrow (->) | `STATICVIAINST` | `"#EC STATIC_CALL"` | ✅ Done | — |
| **031** | [zcl_skylint_check_031](src/checks/zcl_skylint_check_031.clas.abap) | Avoid mutable public attributes in classes | `NOPUBATTR` | `"#EC NUM_PUBLIC_ATTR"` | ✅ Done | — |
| **032** | [zcl_skylint_check_032](src/checks/zcl_skylint_check_032.clas.abap) | Avoid obsolete statements (MOVE, REFRESH, ADD, etc.) | `OBSOLETE` | `"#EC DEPRECATED_KEY"` | ✅ Done | — |
| **033** | [zcl_skylint_check_033](src/checks/zcl_skylint_check_033.clas.abap) | Lost PREVIOUS exception parameter in CATCH block | `LOSTPREV` | `"#EC LOST_PREVIOUS"` | ✅ Done | — |
| **034** | [zcl_skylint_check_034](src/checks/zcl_skylint_check_034.clas.abap) | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `"#EC PARAM_COUNT"` | ✅ Done | — |
| **035** | [zcl_skylint_check_035](src/checks/zcl_skylint_check_035.clas.abap) | Avoid direct database access in unit tests | `DBACCESSUT` | `"#EC DB_ACCESS_UT"` | ✅ Done | — |
| **036** | [zcl_skylint_check_036](src/checks/zcl_skylint_check_036.clas.abap) | Avoid database access inside loop iterations | `DBINLOOP` | `"#EC DB_IN_LOOP"` | ✅ Done | — |
| **037** | [zcl_skylint_check_037](src/checks/zcl_skylint_check_037.clas.abap) | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `"#EC FAE_NO_CHECK"` | ✅ Done | — |
| **038** | [zcl_skylint_check_038](src/checks/zcl_skylint_check_038.clas.abap) | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `"#EC SELECT_PERF"` | ✅ Done | — |
| **039** | [zcl_skylint_check_039](src/checks/zcl_skylint_check_039.clas.abap) | Check sy-subrc after DB & table operations | `CHECKSUBRC` | `"#EC CHECK_SUBRC"` | ✅ Done | — |
| **040** | [zcl_skylint_check_040](src/checks/zcl_skylint_check_040.clas.abap) | Scope of variable (avoid variable leaking outside control blocks) | `SCOPELEAK` | `"#EC SCOPE_OF_VAR"` | ✅ Done | — |
| **041** | [zcl_skylint_check_041](src/checks/zcl_skylint_check_041.clas.abap) | skylint: Avoid Superfluous VALUE Operator | `SUPERFLUOUS` | `"#EC SUPERFLUOUS_VAL"` | ✅ Done | — |
| **042** | [zcl_skylint_check_042](src/checks/zcl_skylint_check_042.clas.abap) | skylint: Detect Identical Self Assignments | `IDENTMOVE` | `"#EC IDENTICAL_MOVE"` | ✅ Done | — |
| **043** | [zcl_skylint_check_043](src/checks/zcl_skylint_check_043.clas.abap) | Enforce fully typed constant declarations | `FULLYTYPED` | `"#EC FULLY_TYPED_CONST"` | ✅ Done | — |
| **044** | [zcl_skylint_check_044](src/checks/zcl_skylint_check_044.clas.abap) | Omit parameter name in single parameter method call | `OMITPARM` | `"#EC OMIT_PARAM_NAME"` | ✅ Done | — |
| **045** | [zcl_skylint_check_045](src/checks/zcl_skylint_check_045.clas.abap) | Detect TRY without CATCH or CLEANUP | `TRYWITHOUTC` | `"#EC TRY_WITHOUT_CATCH"` | ✅ Done | — |
| **046** | [zcl_skylint_check_046](src/checks/zcl_skylint_check_046.clas.abap) | Avoid local TABLES declaration | `LOCALTAB` | `"#EC LOCAL_TABLES"` | ✅ Done | — |
| **047** | [zcl_skylint_check_047](src/checks/zcl_skylint_check_047.clas.abap) | skylint: Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `"#EC PREFER_CORRESPONDING"` | ✅ Done | — |
| **048** | [zcl_skylint_check_048](src/checks/zcl_skylint_check_048.clas.abap) | skylint: Method Length Limit (excessive statement count) | `METHOD_LEN` | `"#EC METHOD_LENGTH"` | ✅ Done | — |
| **049** | [zcl_skylint_check_049](src/checks/zcl_skylint_check_049.clas.abap) | skylint: Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `"#EC NESTING_DEPTH"` | ✅ Done | — |
| **050** | [zcl_skylint_check_050](src/checks/zcl_skylint_check_050.clas.abap) | skylint: Avoid Multiple Output Parameters (prefer single RETURNING) | `OUT_PARAM` | `"#EC OUTPUT_PARAMS"` | ✅ Done | — |
| **051** | [zcl_skylint_check_051](src/checks/zcl_skylint_check_051.clas.abap) | skylint: Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `"#EC AVOID_SY_MOD"` | ✅ Done | — |
| **052** | [zcl_skylint_check_052](src/checks/zcl_skylint_check_052.clas.abap) | skylint: Prefer RETURNING over single EXPORTING | `PREFER_RET` | `"#EC PREFER_RETURNING"` | ✅ Done | — |
| **053** | [zcl_skylint_check_053](src/checks/zcl_skylint_check_053.clas.abap) | skylint: Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `"#EC CLASS_EXCEPTIONS"` | ✅ Done | — |
| **054** | [zcl_skylint_check_054](src/checks/zcl_skylint_check_054.clas.abap) | skylint: Dangerous / Unmanaged Dynamic Statements | `DANGER_STM` | `"#EC DANGEROUS_STMT"` | ✅ Done | — |
| **055** | [zcl_skylint_check_055](src/checks/zcl_skylint_check_055.clas.abap) | skylint: Call Transaction Authority Check | `AUTH_CHECK` | `"#EC CALL_TRANSACTION"` | ✅ Done | — |
| **056** | [zcl_skylint_check_056](src/checks/zcl_skylint_check_056.clas.abap) | skylint: SQL Escape Host Variables (@) | `SQL_HOST_E` | `"#EC SQL_HOST_VAR"` | ✅ Done | — |
| **057** | [zcl_skylint_check_057](src/checks/zcl_skylint_check_057.clas.abap) | skylint: SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `"#EC SELECT_UP_TO_1"` | ✅ Done | — |
| **058** | [zcl_skylint_check_058](src/checks/zcl_skylint_check_058.clas.abap) | skylint: Cyclomatic Complexity Threshold | `CYCLO_COMP` | `"#EC CYCLOMATIC_COMPLEXITY"` | ✅ Done | — |
| **059** | [zcl_skylint_check_059](src/checks/zcl_skylint_check_059.clas.abap) | skylint: Prefer FINAL Classes by Default | `NOT_FINAL` | `"#EC CLASS_FINAL"` | ✅ Done | — |
| **060** | [zcl_skylint_check_060](src/checks/zcl_skylint_check_060.clas.abap) | skylint: Avoid RAISE SHORTDUMP (prefer graceful exceptions) | `SHORTDUMP` | `"#EC AVOID_SHORTDUMP"` | ✅ Done | — |
| **061** | [zcl_skylint_check_061](src/checks/zcl_skylint_check_061.clas.abap) | Prefer backtick string literals over single quotes for STRING | `BACKTICK` | `"#EC STRING_BACKTICK"` | ✅ Done | — |
| **062** | [zcl_skylint_check_062](src/checks/zcl_skylint_check_062.clas.abap) | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `"#EC MAGIC_NUMBER"` | ✅ Done | — |
| **063** | [zcl_skylint_check_063](src/checks/zcl_skylint_check_063.clas.abap) | Prefer modern table expressions over READ TABLE statements | `TAB_EXPR` | `"#EC TABLE_EXPR"` | ✅ Done | — |
| **064** | [zcl_skylint_check_064](src/checks/zcl_skylint_check_064.clas.abap) | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `"#EC PREFER_INSERT"` | ✅ Done | — |
| **065** | [zcl_skylint_check_065](src/checks/zcl_skylint_check_065.clas.abap) | Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP | `OBS_L_CTRL` | `"#EC AVOID_LOOP_CTRL"` | ✅ Done | — |
| **066** | [zcl_skylint_check_066](src/checks/zcl_skylint_check_066.clas.abap) | Prefer COND / SWITCH expressions over multi-branch variable assignment | `COND_SWTCH` | `"#EC PREFER_COND"` | ✅ Done | — |
| **067** | [zcl_skylint_check_067](src/checks/zcl_skylint_check_067.clas.abap) | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `"#EC AVOID_LIKE_TYPE"` | ✅ Done | — |
| **068** | [zcl_skylint_check_068](src/checks/zcl_skylint_check_068.clas.abap) | Keep constructors clean; avoid heavy business logic/loops/DB access | `CTOR_LOGIC` | `"#EC CONSTRUCTOR_LOGIC"` | ✅ Done | — |
| **069** | [zcl_skylint_check_069](src/checks/zcl_skylint_check_069.clas.abap) | Prefer REDUCE expression over manual loop aggregation | `PREF_REDUC` | `"#EC PREFER_REDUCE"` | ✅ Done | — |
| **070** | [zcl_skylint_check_070](src/checks/zcl_skylint_check_070.clas.abap) | Avoid generic FIELD-SYMBOLS declarations (ANY/DATA/CLIKE/TABLE) | `GEN_FS_TYP` | `"#EC GENERIC_FS"` | ✅ Done | — |
| **071** | [zcl_skylint_check_071](src/checks/zcl_skylint_check_071.clas.abap) | Avoid static-only classes; prefer instantiable interface-based design | `STAT_CLASS` | `"#EC AVOID_STATIC_CLS"` | ✅ Done | — |
| **072** | [zcl_skylint_check_072](src/checks/zcl_skylint_check_072.clas.abap) | Avoid unmodified CHANGING parameters; prefer IMPORTING | `UNCHG_PARM` | `"#EC UNMODIFIED_CHANGING"` | ✅ Done | — |
| **073** | [zcl_skylint_check_073](src/checks/zcl_skylint_check_073.clas.abap) | Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods | `BOOL_NAME` | `"#EC BOOL_METHOD_NAME"` | ✅ Done | — |
| **074** | [zcl_skylint_check_074](src/checks/zcl_skylint_check_074.clas.abap) | Avoid deep class inheritance hierarchies (> 3 levels) | `DEEP_INHRT` | `"#EC DEEP_INHERITANCE"` | ✅ Done | — |
| **075** | [zcl_skylint_check_075](src/checks/zcl_skylint_check_075.clas.abap) | Limit number of member attributes in a class (God Class smell) | `ATTR_COUNT` | `"#EC MAX_CLASS_ATTR"` | ✅ Done | — |
| **076** | [zcl_skylint_check_076](src/checks/zcl_skylint_check_076.clas.abap) | Avoid mutable DATA declarations in interfaces; allow only CONSTANTS | `INTF_DATA` | `"#EC INTERFACE_DATA"` | ✅ Done | — |
| **077** | [zcl_skylint_check_077](src/checks/zcl_skylint_check_077.clas.abap) | Avoid generic CATCH cx_root; catch specific exception classes | `CATCH_ROOT` | `"#EC AVOID_CX_ROOT"` | ✅ Done | — |
| **078** | [zcl_skylint_check_078](src/checks/zcl_skylint_check_078.clas.abap) | Avoid obsolete MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `"#EC AVOID_MSG_RAISING"` | ✅ Done | — |
| **079** | [zcl_skylint_check_079](src/checks/zcl_skylint_check_079.clas.abap) | Avoid nested TRY blocks; extract inner error handling to helper methods | `NESTED_TRY` | `"#EC AVOID_NESTED_TRY"` | ✅ Done | — |
| **080** | [zcl_skylint_check_080](src/checks/zcl_skylint_check_080.clas.abap) | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `"#EC AVOID_RAISE_SY_EXC"` | ✅ Done | — |
| **081** | [zcl_skylint_check_081](src/checks/zcl_skylint_check_081.clas.abap) | Ensure TRY blocks handling resources include a CLEANUP section | `TRY_CLEAN` | `"#EC MISSING_CLEANUP"` | ✅ Done | — |
| **082** | [zcl_skylint_check_082](src/checks/zcl_skylint_check_082.clas.abap) | Enforce explicit sy-subrc check directly after FIND or SEARCH | `FIND_SUBRC` | `"#EC CHECK_FIND_SUBRC"` | ✅ Done | — |
| **083** | [zcl_skylint_check_083](src/checks/zcl_skylint_check_083.clas.abap) | Avoid obsolete FORM routines; use modern methods in ABAP Cloud | `AVOID_FORM` | `"#EC AVOID_FORM_ROUTINE"` | ✅ Done | — |
| **084** | [zcl_skylint_check_084](src/checks/zcl_skylint_check_084.clas.abap) | Avoid hardcoded user name comparisons; enforce authorization checks | `HARD_UNAME` | `"#EC AVOID_HARDCODED_USER"` | ✅ Done | — |
| **085** | [zcl_skylint_check_085](src/checks/zcl_skylint_check_085.clas.abap) | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPEC` | `"#EC AVOID_CLIENT_SPEC"` | ✅ Done | — |
| **086** | [zcl_skylint_check_086](src/checks/zcl_skylint_check_086.clas.abap) | Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations | `NO_COMMIT` | `"#EC AVOID_COMMIT_WORK"` | ✅ Done | — |
| **087** | [zcl_skylint_check_087](src/checks/zcl_skylint_check_087.clas.abap) | Prefer FILTER #( ) table operator over manual filter copy loops | `PREF_FILTR` | `"#EC PREFER_FILTER"` | ✅ Done | — |
| **088** | [zcl_skylint_check_088](src/checks/zcl_skylint_check_088.clas.abap) | Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause | `FULL_MODIF` | `"#EC AVOID_FULL_MODIFY"` | ✅ Done | — |
| **089** | [zcl_skylint_check_089](src/checks/zcl_skylint_check_089.clas.abap) | Enforce test method naming convention (TEST_, SHOULD_) in AUnit | `TEST_NAME` | `"#EC TEST_METHOD_NAME"` | ✅ Done | — |
| **090** | [zcl_skylint_check_090](src/checks/zcl_skylint_check_090.clas.abap) | Avoid magic offset/length substring expressions (var+0(2)) | `OFFST_MAG` | `"#EC MAGIC_OFFSET"` | ✅ Done | — |
| **091** | [zcl_skylint_check_091](src/checks/zcl_skylint_check_091.clas.abap) | Avoid dynamic SQL table or clause names without sanitization | `DYN_SQL` | `"#EC AVOID_DYNAMIC_SQL"` | ✅ Done | — |
| **092** | [zcl_skylint_check_092](src/checks/zcl_skylint_check_092.clas.abap) | Prefer marking non-overridden methods as FINAL | `PREF_FINAL` | `"#EC PREFER_FINAL_METHOD"` | ✅ Done | — |
| **093** | [zcl_skylint_check_093](src/checks/zcl_skylint_check_093.clas.abap) | Detect CONDENSE statement; suggest built-in condense( ... ) function | `CONDENSE_S` | `"#EC CONDENSE_STMT"` | ✅ Done | — |
| **094** | [zcl_skylint_check_094](src/checks/zcl_skylint_check_094.clas.abap) | Detect TRANSLATE statement; suggest to_upper() / to_lower() | `TRANSLATE_` | `"#EC TRANSLATE_STMT"` | ✅ Done | — |
| **095** | [zcl_skylint_check_095](src/checks/zcl_skylint_check_095.clas.abap) | Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1 | `CALC_ASSGN` | `"#EC PREFER_CALC_ASSIGN"` | ✅ Done | — |
| **096** | [zcl_skylint_check_096](src/checks/zcl_skylint_check_096.clas.abap) | Use early CONTINUE guard clause instead of wrapping loop in IF block | `GUARD_LOOP` | `"#EC GUARD_IN_LOOP"` | ✅ Done | — |
| **097** | [zcl_skylint_check_097](src/checks/zcl_skylint_check_097.clas.abap) | Use early RETURN guard clause instead of wrapping method in IF block | `GUARD_METH` | `"#EC GUARD_IN_METHOD"` | ✅ Done | — |
| **098** | [zcl_skylint_check_098](src/checks/zcl_skylint_check_098.clas.abap) | Detect native ASSERT in production code; use exceptions instead | `PROD_ASSRT` | `"#EC PROD_ASSERT"` | ✅ Done | — |
| **099** | [zcl_skylint_check_099](src/checks/zcl_skylint_check_099.clas.abap) | Detect unused local variables and field symbols | `UNUSED_VAR` | `"#EC UNUSED_VAR"` | ✅ Done | — |
| **100** | [zcl_skylint_check_100](src/checks/zcl_skylint_check_100.clas.abap) | Detect needless CLEAR on newly declared variable or before exit | `NEEDLES_CL` | `"#EC NEEDLESS_CLEAR"` | ✅ Done | — |
| **101** | [zcl_skylint_check_101](src/checks/zcl_skylint_check_101.clas.abap) | Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS) | `DECL_ORDER` | `"#EC LOCAL_DECL_ORDER"` | ✅ Done | — |
| **102** | [zcl_skylint_check_102](src/checks/zcl_skylint_check_102.clas.abap) | Detect unnecessary exclamation mark parameter escape (!iv_param) | `PARAM_ESCP` | `"#EC UNNECESSARY_ESCAPE"` | ✅ Done | — |
| **103** | [zcl_skylint_check_103](src/checks/zcl_skylint_check_103.clas.abap) | Prefer line_exists( ... ) over READ TABLE TRANSPORTING NO FIELDS | `PREF_EXST` | `"#EC PREFER_LINE_EXISTS"` | ✅ Done | — |
| **104** | [zcl_skylint_check_104](src/checks/zcl_skylint_check_104.clas.abap) | Prefer line_index( ... ) over READ TABLE to retrieve row index | `PREF_INDX` | `"#EC PREFER_LINE_INDEX"` | ✅ Done | — |

---

## 🚀 How to Author a Custom Skylint Check

Authoring an ATC check in Skylint requires just extending `zcl_skylint_check_base`:

### Step 1: Define Check Metadata & Inspection Logic (`src/checks/zcl_skylint_check_002.clas.abap`)

```abap
CLASS zcl_skylint_check_002 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_IS_NOT'.

ENDCLASS.


CLASS zcl_skylint_check_002 IMPLEMENTATION.
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

### Step 2: Create Test Fixture (`src/tests/zcl_skylint_test_002.clas.abap`)

```abap
CLASS zcl_skylint_test_002 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_002 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    CHECK 1 = 2.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    CHECK 1 = 2. "#EC PREFER_IS_NOT
  ENDMETHOD.

  METHOD valid_code.
    IF 1 = 2.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
```

### Step 3: Add ATC Asserter Unit Tests (`src/checks/zcl_skylint_check_002.clas.testclasses.abap`)

```abap
CLASS ltcl_check_002 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZCL_SKYLINT_TEST_002'.
    CONSTANTS:
      BEGIN OF c_methods,
        without_pseudo_comments TYPE c LENGTH 30 VALUE 'WITHOUT_PSEUDO_COMMENTS',
        with_pseudo_comments    TYPE c LENGTH 30 VALUE 'WITH_PSEUDO_COMMENTS',
      END OF c_methods.

    METHODS execute_test_class FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_002 IMPLEMENTATION.
  METHOD execute_test_class.
    DATA ls_loc_without_pc TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_with_pc    TYPE if_ci_atc_check=>ty_location.

    ls_loc_without_pc = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-without_pseudo_comments ) )
      position = VALUE #( line = 2 column = 4 ) ).

    ls_loc_with_pc = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-with_pseudo_comments ) )
      position = VALUE #( line = 2 column = 4 ) ).

    cl_ci_atc_unit_driver=>create_asserter( )->check_and_assert(
        check             = NEW zcl_skylint_check_002( )
        object            = VALUE #( type = 'CLAS' name = c_test_class )
        expected_findings = VALUE #( ( code     = zcl_skylint_check_002=>c_finding_codes-prefer_is_not
                                       location = ls_loc_without_pc )
                                     ( code     = zcl_skylint_check_002=>c_finding_codes-prefer_is_not
                                       location = ls_loc_with_pc ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
```

---

## 🛠️ Available Base APIs (`zcl_skylint_check_base`)

| Method | Description |
|---|---|
| `report_statement( is_statement, iv_finding_code, ... )` | Reports an ATC finding for a statement with auto location, checksum & pseudo-comment suppression check. |
| `report_token( is_token, is_statement, iv_finding_code, ... )` | Reports an ATC finding highlighting a specific token position. |
| `report_finding( is_finding )` | Directly appends a custom `if_ci_atc_check=>ty_finding` structure. |
| `get_attribute( iv_name, IMPORTING ev_value )` | Safely dereferences and retrieves dynamic ATC check attributes. |
| `quickfix_replace( ... )` | Constructs a QuickFix context and generates replacement code. |
| `quickfix_insert_before( ... )` | Inserts new statements before the specified statement index. |
| `quickfix_insert_after( ... )` | Inserts new statements after the specified statement index. |
| `quickfix_delete( ... )` | Generates a quickfix to delete a statement. |

---

## 🧪 Development & Verification

```bash
# Install dependencies
npm install

# Run full CI pipeline (abaplint validation + open-abap transpiler AUnit tests)
npm test

# Run abaplint separately
npm run lint

# Run AUnit tests separately
npm run unit
```

---

## 📦 Deployment via abapGit

1. Clone or import this repository in your SAP BTP ABAP Environment or S/4HANA Cloud system using **abapGit**.
2. Activate all objects.
3. Configure the check classes in your ATC Check Variant (`transaction ATC` or ADT).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
