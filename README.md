# ☁️ Skylint

> **Modern, Minimal & Universal ABAP Linter for SAP BTP, S/4HANA & Open-ABAP**

**Skylint** is an extensible, high-performance static code analysis framework for ABAP. Built with a **platform-agnostic core architecture**, Skylint decouples check domain logic from proprietary platform interfaces. The core rules operate on a clean, universal Abstract Syntax Tree (AST) model (`zif_skylint_types`), allowing the exact same Clean ABAP & Security rules to run seamlessly across:

- 🌐 **ABAP Cloud (ATC)**: SAP BTP ABAP Environment & S/4HANA Public Cloud (`if_ci_atc_check`).
- 🏢 **Classic On-Premise (Code Inspector)**: SAP NetWeaver 7.40+ and S/4HANA Private Cloud (`CL_CI_TEST_SCAN`).
- ⚡ **Open-ABAP / Node.js**: CI/CD pipelines, pre-commit hooks, and local unit test suites without requiring an SAP system.

---

## ⚡ Highlights

- **Platform-Agnostic Core (`main`):** Zero external platform dependencies. All types, tokens, statements, findings, and quickfixes are modeled cleanly in `zif_skylint_types`.
- **Zero Boilerplate Architecture:** Base class (`zcl_skylint_check_base`) encapsulates finding registration, statement/token reporting, attribute resolution, and pseudo-comment filtering. Subclasses only require `constructor` and `check`.
- **Universal Normalized AST:** Normalized statement streams with unrolled chained statements (`DATA: ...`), implicit assignments tagged as `COMPUTE`, functional method calls tagged as `+CALL_METHOD`, and compiler symbol references attached directly to tokens.
- **Modern In-Memory Testing:** Lightning-fast unit tests using `zcl_skylint_test_util` (`assert_findings`, `assert_no_findings`, `assert_quickfix`) with inline source snippets.
- **QuickFix Ready:** Built-in helper API (`quickfix_replace`) for automated code transformations and refactoring.
- **Multi-Platform Branch Strategy:**
  - `main`: Platform-agnostic core rules + universal AST engine.
  - `cloud`: Native SAP ATC Cloud adapter (`if_ci_atc_check` / Language Version 5).
  - `standard`: Classic SAP Code Inspector adapter (`CL_CI_TEST_SCAN` / NetWeaver 7.40+).

---

## 📁 Repository Structure

```text
skylint/
├── src/
│   ├── core/                                     # Platform-Agnostic Core Infrastructure
│   │   ├── zif_skylint_types.intf.abap           # Universal AST, finding & quickfix type definitions
│   │   ├── zcl_skylint_check_base.clas.abap      # Universal base check class
│   │   ├── zcl_skylint_ast_util.clas.abap        # AST & token sequence traversal utility
│   │   ├── zcl_skylint_rtti_util.clas.abap       # Safe ABAP RTTI inspection utility
│   │   ├── zcl_skylint_test_util.clas.abap       # Universal AST builder & unit test asserter
│   │   └── zcx_skylint_error.clas.abap           # Core exception class
│   │
│   ├── checks/                                   # 79 Modular Check Implementations (001 - 079)
│   │   ├── zcl_skylint_check_001.clas.abap       # Check class implementation
│   │   ├── zcl_skylint_check_001.clas.xml        # abapGit XML metadata (<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>)
│   │   └── zcl_skylint_check_001.clas.testclasses.abap # Unit test suite (zcl_skylint_test_util)
│   │
│   └── tests/                                    # Target Test Fixtures (Full Class Mocks)
│       ├── zcl_skylint_test_001.clas.abap        # Test fixture with positive, negative & suppressed cases
│       └── zcl_skylint_test_001.clas.xml         # abapGit XML metadata
│
├── abaplint.json                                 # abaplint validation configuration & rule sets
└── package.json                                  # Build, transpile, lint, and unit test scripts
```

---         # abaplint validation configuration & rule sets
└── package.json                                  # Build, transpile, lint, and unit test scripts
```

---

## 📋 Clean ABAP & Cloud Rule Catalog (79 Rules)

All Clean ABAP, security, and cloud-native rules implemented in Skylint:

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **001** | [zcl_skylint_check_001](src/checks/zcl_skylint_check_001.clas.abap) | Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `"#EC DESCRIBE_LINES"` | ✅ Done | — |
| **002** | [zcl_skylint_check_002](src/checks/zcl_skylint_check_002.clas.abap) | Avoid static CALL METHOD statements | `CALLMETHOD` | `"#EC CALL_METHOD"` | ✅ Done | — |
| **003** | [zcl_skylint_check_003](src/checks/zcl_skylint_check_003.clas.abap) | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `"#EC DEFAULT_KEY"` | ✅ Done | — |
| **004** | [zcl_skylint_check_004](src/checks/zcl_skylint_check_004.clas.abap) | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `"#EC PREFER_IS_NOT"` | ✅ Done | — |
| **005** | [zcl_skylint_check_005](src/checks/zcl_skylint_check_005.clas.abap) | Avoid self-reference ME-> | `AVOIDME` | `"#EC AVOID_ME"` | ✅ Done | — |
| **006** | [zcl_skylint_check_006](src/checks/zcl_skylint_check_006.clas.abap) | Omit explicit EXPORTING in method calls | `OMITEXPORT` | `"#EC OMIT_EXPORTING"` | ✅ Done | ⚡ Ready |
| **007** | [zcl_skylint_check_007](src/checks/zcl_skylint_check_007.clas.abap) | Avoid assignment chaining (a = b = c) | `ASSIGNCHN` | `"#EC ASSIGN_CHAIN"` | ✅ Done | — |
| **008** | [zcl_skylint_check_008](src/checks/zcl_skylint_check_008.clas.abap) | Avoid chained declarations (DATA:, TYPES:, etc.) | `CHAINDECL` | `"#EC CHAIN_DECL"` | ✅ Done | ⚡ Ready |
| **009** | [zcl_skylint_check_009](src/checks/zcl_skylint_check_009.clas.abap) | Prefer string templates over CONCATENATE | `CONCATSTR` | `"#EC PREFER_STR_TMPL"` | ✅ Done | — |
| **010** | [zcl_skylint_check_010](src/checks/zcl_skylint_check_010.clas.abap) | Avoid direct comparison against boolean literals (abap_true, | `BOOLCOMP` | `"#EC AVOID_BOOL_COMP"` | ✅ Done | — |
| **011** | [zcl_skylint_check_011](src/checks/zcl_skylint_check_011.clas.abap) | Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS | `PREFLINEX` | `"#EC PREFER_LINE_EXISTS"` | ✅ Done | — |
| **012** | [zcl_skylint_check_012](src/checks/zcl_skylint_check_012.clas.abap) | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `"#EC EXIT_OUTSIDE_LOOP"` | ✅ Done | — |
| **013** | [zcl_skylint_check_013](src/checks/zcl_skylint_check_013.clas.abap) | Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE) | `CHKINLOOP` | `"#EC CHECK_IN_LOOP"` | ✅ Done | — |
| **014** | [zcl_skylint_check_014](src/checks/zcl_skylint_check_014.clas.abap) | Detect empty control blocks (IF, CASE, LOOP, TRY, etc.) | `EMPTYCTRL` | `"#EC EMPTY_CONTROL_BLOCK"` | ✅ Done | — |
| **015** | [zcl_skylint_check_015](src/checks/zcl_skylint_check_015.clas.abap) | Detect empty CATCH blocks swallowing exceptions | `EMPTYCATCH` | `"#EC NO_HANDLER"` | ✅ Done | — |
| **016** | [zcl_skylint_check_016](src/checks/zcl_skylint_check_016.clas.abap) | Detect identical branch conditions in IF/ELSEIF and CASE/WHEN | `DUPCOND` | `"#EC IDENTICAL_CONDITIONS"` | ✅ Done | — |
| **017** | [zcl_skylint_check_017](src/checks/zcl_skylint_check_017.clas.abap) | Detect consecutive nested IF blocks that can be merged with AND | `NESTEDIF` | `"#EC NESTED_IF"` | ✅ Done | — |
| **018** | [zcl_skylint_check_018](src/checks/zcl_skylint_check_018.clas.abap) | Detect unreachable code following unconditional jump statements | `UNREACHCD` | `"#EC UNREACHABLE_CODE"` | ✅ Done | — |
| **019** | [zcl_skylint_check_019](src/checks/zcl_skylint_check_019.clas.abap) | Avoid short CASE constructs with only one WHEN branch; prefer IF | `SHORTCASE` | `"#EC SHORT_CASE"` | ✅ Done | — |
| **020** | [zcl_skylint_check_020](src/checks/zcl_skylint_check_020.clas.abap) | Avoid Yoda conditions in comparison expressions | `YODACOND` | `"#EC NO_YODA_CONDITIONS"` | ✅ Done | — |
| **021** | [zcl_skylint_check_021](src/checks/zcl_skylint_check_021.clas.abap) | Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords | `PREFEROP` | `"#EC PREFER_OPERATORS"` | ✅ Done | — |
| **022** | [zcl_skylint_check_022](src/checks/zcl_skylint_check_022.clas.abap) | Prefer NEW #( ) constructor expression over legacy CREATE OBJECT | `PREFERNEW` | `"#EC PREF_NEW"` | ✅ Done | — |
| **023** | [zcl_skylint_check_023](src/checks/zcl_skylint_check_023.clas.abap) | Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE | `RAISEEXCNEW` | `"#EC RAISE_EXC_NEW"` | ✅ Done | — |
| **024** | [zcl_skylint_check_024](src/checks/zcl_skylint_check_024.clas.abap) | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDBOOL` | `"#EC PREFER_XSDBOOL"` | ✅ Done | — |
| **025** | [zcl_skylint_check_025](src/checks/zcl_skylint_check_025.clas.abap) | Omit RECEIVING in method calls | `OMITRECEIV` | `"#EC RECEIVING_USAGE"` | ✅ Done | — |
| **026** | [zcl_skylint_check_026](src/checks/zcl_skylint_check_026.clas.abap) | Avoid calling static methods via instance arrow (->) | `STATICVIAINST` | `"#EC STATIC_CALL"` | ✅ Done | — |
| **027** | [zcl_skylint_check_027](src/checks/zcl_skylint_check_027.clas.abap) | Avoid mutable public attributes in classes | `NOPUBATTR` | `"#EC NUM_PUBLIC_ATTR"` | ✅ Done | — |
| **028** | [zcl_skylint_check_028](src/checks/zcl_skylint_check_028.clas.abap) | Avoid obsolete statements (MOVE, REFRESH, etc.) | `OBSOLETE` | `"#EC DEPRECATED_KEY"` | ✅ Done | — |
| **029** | [zcl_skylint_check_029](src/checks/zcl_skylint_check_029.clas.abap) | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `"#EC PARAM_COUNT"` | ✅ Done | — |
| **030** | [zcl_skylint_check_030](src/checks/zcl_skylint_check_030.clas.abap) | Avoid database access inside loop iterations | `DBINLOOP` | `"#EC DB_IN_LOOP"` | ✅ Done | — |
| **031** | [zcl_skylint_check_031](src/checks/zcl_skylint_check_031.clas.abap) | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `"#EC FAE_NO_CHECK"` | ✅ Done | — |
| **032** | [zcl_skylint_check_032](src/checks/zcl_skylint_check_032.clas.abap) | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `"#EC SELECT_PERF"` | ✅ Done | — |
| **033** | [zcl_skylint_check_033](src/checks/zcl_skylint_check_033.clas.abap) | Scope of variable (avoid variable leaking outside control blocks) | `SCOPELEAK` | `"#EC SCOPE_OF_VAR"` | ✅ Done | — |
| **034** | [zcl_skylint_check_034](src/checks/zcl_skylint_check_034.clas.abap) | skylint: Detect Identical Self Assignments | `IDENTMOVE` | `"#EC IDENTICAL_MOVE"` | ✅ Done | — |
| **035** | [zcl_skylint_check_035](src/checks/zcl_skylint_check_035.clas.abap) | Enforce fully typed constant declarations | `FULLYTYPED` | `"#EC FULLY_TYPED_CONST"` | ✅ Done | — |
| **036** | [zcl_skylint_check_036](src/checks/zcl_skylint_check_036.clas.abap) | Omit parameter name in single parameter method call | `OMITPARM` | `"#EC OMIT_PARAM_NAME"` | ✅ Done | — |
| **037** | [zcl_skylint_check_037](src/checks/zcl_skylint_check_037.clas.abap) | Detect TRY without CATCH | `TRYWITHOUTC` | `"#EC TRY_WITHOUT_CATCH"` | ✅ Done | — |
| **038** | [zcl_skylint_check_038](src/checks/zcl_skylint_check_038.clas.abap) | skylint: Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `"#EC PREFER_CORRESPONDING"` | ✅ Done | — |
| **039** | [zcl_skylint_check_039](src/checks/zcl_skylint_check_039.clas.abap) | skylint: Method Length Limit (excessive statement count) | `METHOD_LEN` | `"#EC METHOD_LENGTH"` | ✅ Done | — |
| **040** | [zcl_skylint_check_040](src/checks/zcl_skylint_check_040.clas.abap) | skylint: Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `"#EC NESTING_DEPTH"` | ✅ Done | — |
| **041** | [zcl_skylint_check_041](src/checks/zcl_skylint_check_041.clas.abap) | skylint: Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `"#EC AVOID_SY_MOD"` | ✅ Done | — |
| **042** | [zcl_skylint_check_042](src/checks/zcl_skylint_check_042.clas.abap) | skylint: Prefer RETURNING over single EXPORTING | `PREFER_RET` | `"#EC PREFER_RETURNING"` | ✅ Done | — |
| **043** | [zcl_skylint_check_043](src/checks/zcl_skylint_check_043.clas.abap) | skylint: Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `"#EC CLASS_EXCEPTIONS"` | ✅ Done | — |
| **044** | [zcl_skylint_check_044](src/checks/zcl_skylint_check_044.clas.abap) | skylint: Dangerous / Unmanaged Dynamic Statements | `DANGER_STM` | `"#EC DANGEROUS_STMT"` | ✅ Done | — |
| **045** | [zcl_skylint_check_045](src/checks/zcl_skylint_check_045.clas.abap) | skylint: Call Transaction Authority Check | `AUTH_CHECK` | `"#EC CALL_TRANSACTION"` | ✅ Done | — |
| **046** | [zcl_skylint_check_046](src/checks/zcl_skylint_check_046.clas.abap) | skylint: SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `"#EC SELECT_UP_TO_1"` | ✅ Done | — |
| **047** | [zcl_skylint_check_047](src/checks/zcl_skylint_check_047.clas.abap) | skylint: Cyclomatic Complexity Threshold | `CYCLO_COMP` | `"#EC CYCLOMATIC_COMPLEXITY"` | ✅ Done | — |
| **048** | [zcl_skylint_check_048](src/checks/zcl_skylint_check_048.clas.abap) | skylint: Prefer FINAL Classes by Default | `NOT_FINAL` | `"#EC CLASS_FINAL"` | ✅ Done | — |
| **049** | [zcl_skylint_check_049](src/checks/zcl_skylint_check_049.clas.abap) | skylint: Avoid RAISE SHORTDUMP (prefer graceful exceptions) | `SHORTDUMP` | `"#EC AVOID_SHORTDUMP"` | ✅ Done | — |
| **050** | [zcl_skylint_check_050](src/checks/zcl_skylint_check_050.clas.abap) | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `"#EC MAGIC_NUMBER"` | ✅ Done | — |
| **051** | [zcl_skylint_check_051](src/checks/zcl_skylint_check_051.clas.abap) | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `"#EC PREFER_INSERT"` | ✅ Done | — |
| **052** | [zcl_skylint_check_052](src/checks/zcl_skylint_check_052.clas.abap) | Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP | `OBS_L_CTRL` | `"#EC AVOID_LOOP_CTRL"` | ✅ Done | — |
| **053** | [zcl_skylint_check_053](src/checks/zcl_skylint_check_053.clas.abap) | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `"#EC AVOID_LIKE_TYPE"` | ✅ Done | — |
| **054** | [zcl_skylint_check_054](src/checks/zcl_skylint_check_054.clas.abap) | Keep constructors clean; avoid heavy business logic/loops/DB access | `CTOR_LOGIC` | `"#EC CONSTRUCTOR_LOGIC"` | ✅ Done | — |
| **055** | [zcl_skylint_check_055](src/checks/zcl_skylint_check_055.clas.abap) | Avoid static-only classes; prefer instantiable interface-based design | `STAT_CLASS` | `"#EC AVOID_STATIC_CLS"` | ✅ Done | — |
| **056** | [zcl_skylint_check_056](src/checks/zcl_skylint_check_056.clas.abap) | Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods | `BOOL_NAME` | `"#EC BOOL_METHOD_NAME"` | ✅ Done | — |
| **057** | [zcl_skylint_check_057](src/checks/zcl_skylint_check_057.clas.abap) | Avoid deep class inheritance hierarchies | `DEEP_INHRT` | `"#EC DEEP_INHERITANCE"` | ✅ Done | — |
| **058** | [zcl_skylint_check_058](src/checks/zcl_skylint_check_058.clas.abap) | Limit number of member attributes in a class (God Class smell) | `ATTR_COUNT` | `"#EC MAX_CLASS_ATTR"` | ✅ Done | — |
| **059** | [zcl_skylint_check_059](src/checks/zcl_skylint_check_059.clas.abap) | Avoid mutable DATA declarations in interfaces; allow only CONSTANTS | `INTF_DATA` | `"#EC INTERFACE_DATA"` | ✅ Done | — |
| **060** | [zcl_skylint_check_060](src/checks/zcl_skylint_check_060.clas.abap) | Avoid generic CATCH cx_root; catch specific exception classes | `CATCH_ROOT` | `"#EC AVOID_CX_ROOT"` | ✅ Done | — |
| **061** | [zcl_skylint_check_061](src/checks/zcl_skylint_check_061.clas.abap) | Avoid obsolete MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `"#EC AVOID_MSG_RAISING"` | ✅ Done | — |
| **062** | [zcl_skylint_check_062](src/checks/zcl_skylint_check_062.clas.abap) | Avoid nested TRY blocks; extract inner error handling to helper methods | `NESTED_TRY` | `"#EC AVOID_NESTED_TRY"` | ✅ Done | — |
| **063** | [zcl_skylint_check_063](src/checks/zcl_skylint_check_063.clas.abap) | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `"#EC AVOID_RAISE_SY_EXC"` | ✅ Done | — |
| **064** | [zcl_skylint_check_064](src/checks/zcl_skylint_check_064.clas.abap) | Check sy-subrc after DB, table and string operations | `CHECKSUBRC` | `"#EC CHECK_SUBRC"` | ✅ Done | — |
| **065** | [zcl_skylint_check_065](src/checks/zcl_skylint_check_065.clas.abap) | Avoid obsolete FORM routines; use modern methods in ABAP Cloud | `AVOID_FORM` | `"#EC AVOID_FORM_ROUTINE"` | ✅ Done | — |
| **066** | [zcl_skylint_check_066](src/checks/zcl_skylint_check_066.clas.abap) | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPEC` | `"#EC AVOID_CLIENT_SPEC"` | ✅ Done | — |
| **067** | [zcl_skylint_check_067](src/checks/zcl_skylint_check_067.clas.abap) | Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations | `NO_COMMIT` | `"#EC AVOID_COMMIT_WORK"` | ✅ Done | — |
| **068** | [zcl_skylint_check_068](src/checks/zcl_skylint_check_068.clas.abap) | Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause | `FULL_MODIF` | `"#EC AVOID_FULL_MODIFY"` | ✅ Done | — |
| **069** | [zcl_skylint_check_069](src/checks/zcl_skylint_check_069.clas.abap) | Enforce test method naming convention (TEST_, SHOULD_) in AUnit | `TEST_NAME` | `"#EC TEST_METHOD_NAME"` | ✅ Done | — |
| **070** | [zcl_skylint_check_070](src/checks/zcl_skylint_check_070.clas.abap) | Avoid dynamic SQL table or clause names without sanitization | `DYN_SQL` | `"#EC AVOID_DYNAMIC_SQL"` | ✅ Done | — |
| **071** | [zcl_skylint_check_071](src/checks/zcl_skylint_check_071.clas.abap) | Prefer marking non-overridden methods as FINAL | `PREF_FINAL` | `"#EC PREFER_FINAL_METHOD"` | ✅ Done | — |
| **072** | [zcl_skylint_check_072](src/checks/zcl_skylint_check_072.clas.abap) | Detect obsolete string statements; prefer built-in functions | `CONDENSE_S` | `—` | ✅ Done | — |
| **073** | [zcl_skylint_check_073](src/checks/zcl_skylint_check_073.clas.abap) | Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1 | `CALC_ASSGN` | `"#EC PREFER_CALC_ASSIGN"` | ✅ Done | — |
| **074** | [zcl_skylint_check_074](src/checks/zcl_skylint_check_074.clas.abap) | Use early CONTINUE guard clause instead of wrapping loop in IF block | `GUARD_LOOP` | `"#EC GUARD_IN_LOOP"` | ✅ Done | — |
| **075** | [zcl_skylint_check_075](src/checks/zcl_skylint_check_075.clas.abap) | Use early RETURN guard clause instead of wrapping method in IF block | `GUARD_METH` | `"#EC GUARD_IN_METHOD"` | ✅ Done | — |
| **076** | [zcl_skylint_check_076](src/checks/zcl_skylint_check_076.clas.abap) | Detect native ASSERT in production code; use exceptions instead | `PROD_ASSRT` | `"#EC PROD_ASSERT"` | ✅ Done | — |
| **077** | [zcl_skylint_check_077](src/checks/zcl_skylint_check_077.clas.abap) | Detect unused local variables and field symbols | `UNUSED_VAR` | `"#EC UNUSED_VAR"` | ✅ Done | — |
| **078** | [zcl_skylint_check_078](src/checks/zcl_skylint_check_078.clas.abap) | Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS) | `DECL_ORDER` | `"#EC LOCAL_DECL_ORDER"` | ✅ Done | — |
| **079** | [zcl_skylint_check_079](src/checks/zcl_skylint_check_079.clas.abap) | Detect unnecessary exclamation mark parameter escape (!iv_param) | `PARAM_ESCP` | `"#EC UNNECESSARY_ESCAPE"` | ✅ Done | — |

---

## 🚀 How to Author a Custom Skylint Check

Authoring a check in Skylint requires extending `zcl_skylint_check_base` and implementing two methods:

### Step 1: Define Check Metadata & Inspection Logic (`src/checks/zcl_skylint_check_002.clas.abap`)

```abap
CLASS zcl_skylint_check_002 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_is_not TYPE zif_skylint_types=>ty_finding_code VALUE 'PREFERISNT',
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
                                              severity       = zif_skylint_types=>severities-warning
                                              text           = 'Use IS NOT instead of NOT ... IS INITIAL'
                                              pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CHECK'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_is_not ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

### Step 2: Implement Unit Tests (`src/checks/zcl_skylint_check_002.clas.testclasses.abap`)

Skylint provides an in-memory test utility (`zcl_skylint_test_util`) that normalizes source code into an AST and asserts expected findings directly:

```abap
CLASS ltcl_check_002 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_002 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_002( )
        it_source   = VALUE #( ( `CHECK NOT lv_val IS INITIAL.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_002=>c_finding_codes-prefer_is_not ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_002( )
        it_source = VALUE #( ( `CHECK lv_val IS NOT INITIAL.` ) ) ).
  ENDMETHOD.
ENDCLASS.
```

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
DATA ls_quickfix TYPE zif_skylint_types=>ty_quickfix.

ls_quickfix = quickfix_replace(
    iv_quickfix_code  = c_quickfix_codes-prefer_is_not
    iv_statement_from = sy-tabix
    it_new_code       = VALUE #( ( 'CHECK lv_val IS NOT INITIAL.' ) ) ).

report_statement( is_statement    = <ls_statement>
                  iv_finding_code = c_finding_codes-prefer_is_not
                  is_quickfix     = ls_quickfix ).

" 3. Verify transformation in unit tests:
zcl_skylint_test_util=>assert_quickfix(
    io_check          = NEW zcl_skylint_check_002( )
    it_bad_source     = VALUE #( ( `CHECK NOT lv_val IS INITIAL.` ) )
    it_expected_fixed = VALUE #( ( `CHECK lv_val IS NOT INITIAL.` ) )
    iv_quickfix_code  = zcl_skylint_check_002=>c_quickfix_codes-prefer_is_not ).
```

---

## 🛠️ Available Base APIs (`zcl_skylint_check_base`)

| Method | Description |
|---|---|
| `report_statement( is_statement, iv_finding_code, is_quickfix )` | Reports a finding for a statement with auto location, line numbers, and pseudo-comment suppression. |
| `report_token( is_token, is_statement, iv_finding_code, is_quickfix )` | Reports a finding pinpointing a specific token column and length. |
| `report_finding( is_finding )` | Directly appends a custom `zif_skylint_types=>ty_finding` structure. |
| `get_attribute( iv_name, IMPORTING ev_value )` | Safely dereferences and retrieves dynamic check configuration attributes. |
| `quickfix_replace( iv_quickfix_code, iv_statement_from, it_new_code, ... )` | Constructs a standardized QuickFix replacement descriptor. |

---

## 🏛️ Multi-Platform Branch Strategy

Skylint is structured across dedicated branches to maintain a pure, zero-dependency core while delivering first-class integration with all SAP environments:

```
          ┌──────────────────────────────────────────────┐
          │               main (Core AST)                │
          │  • Pure Domain Logic (79 Rules)              │
          │  • Neutral Types (zif_skylint_types)         │
          │  • Universal Test Runner (Node.js / CI)      │
          └──────────────────────┬───────────────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 ▼                               ▼
  ┌──────────────────────────────┐ ┌──────────────────────────────┐
  │         cloud Branch         │ │       standard Branch        │
  │  • ABAP Cloud Native         │ │  • Classic SAP NetWeaver     │
  │  • if_ci_atc_check Adapter   │ │  • CL_CI_TEST_SCAN Adapter   │
  │  • BTP & S/4HANA Public ATC  │ │  • On-Prem Code Inspector    │
  └──────────────────────────────┘ └──────────────────────────────┘
```

1. **`main` (Agnostic Core):** Contains all lint rules, AST utilities, and testing drivers with zero external SAP dependencies. Fully transpilable with Open-ABAP for Node.js CI/CD pipelines.
2. **`cloud` (ABAP Cloud / Steampunk / BTP):** Adapter layer implementing standard SAP ATC Cloud interfaces (`if_ci_atc_check`, `if_ci_atc_source_code_provider`). Maps ATC procedures directly to `zif_skylint_types`.
3. **`standard` (Classic On-Premise):** Adapter layer integrating with SAP Code Inspector (`CL_CI_TEST_SCAN`, `CL_CI_TEST_ROOT`). Converts classic scan tokens into `zif_skylint_types` for execution in NetWeaver 7.40+.

---

## 🧪 Development & Verification

```bash
# Install dependencies
npm install

# Run full CI pipeline (abaplint validation + open-abap transpiler unit tests)
npm test

# Run abaplint separately
npm run lint

# Run AUnit tests separately
npm run unit
```

---

## 📦 Deployment via abapGit

1. For **ABAP Cloud / BTP**: Clone the `cloud` branch via **abapGit** in your BTP ABAP Environment or S/4HANA Cloud system.
2. For **On-Premise NetWeaver / S/4HANA**: Clone the `standard` branch via **abapGit**.
3. Activate all objects and add the check classes to your ATC or Code Inspector Check Variant.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

