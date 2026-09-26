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
│   ├── checks/                                   # 60 Modular ATC Check Implementations (001 - 060)
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
│
├── abaplint.json                                 # abaplint validation configuration & rule sets
└── package.json                                  # Build, transpile, lint, and unit test scripts
```

---

## 📋 Comprehensive Rule Catalog (60 Checks)

All 60 rules are systematically grouped across 6 progressive complexity levels.

### 🟢 Level 1: Beginner / Direct Pattern Matching
Direct single-statement keyword matching and literal replacements.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **001** | [zcl_skylint_check_001](src/checks/zcl_skylint_check_001.clas.abap) | Detect `TEST-SEAM` statements; recommend ABAP OO Test Doubles / Interfaces | `TEST_SEAM` | `"#EC TEST_SEAM"` | ✅ Done | ⚡ Ready |
| **002** | [zcl_skylint_check_002](src/checks/zcl_skylint_check_002.clas.abap) | Detect `DESCRIBE TABLE ... LINES ...`; suggest modern `lines( ... )` | `DESCRIBE_T` | `"#EC DESCRIBE_TABLE"` | ✅ Done | ⚡ Ready |
| **003** | [zcl_skylint_check_003](src/checks/zcl_skylint_check_003.clas.abap) | Detect legacy `CALL METHOD lo->meth( )`; suggest functional `lo->meth( )` | `CALL_METH` | `"#EC CALL_METHOD"` | ✅ Done | ⚡ Ready |
| **004** | [zcl_skylint_check_004](src/checks/zcl_skylint_check_004.clas.abap) | Detect `WITH DEFAULT KEY` on internal tables; recommend `EMPTY KEY` or explicit keys | `DEFAULT_K` | `"#EC DEFAULT_KEY"` | ✅ Done | ⚡ Ready |
| **005** | [zcl_skylint_check_005](src/checks/zcl_skylint_check_005.clas.abap) | Detect `NOT ... IS INITIAL` / `NOT ... IS BOUND`; suggest `IS NOT INITIAL` / `IS NOT BOUND` | `PREFER_IS` | `"#EC PREFER_IS_NOT"` | ✅ Done | ⚡ Ready |
| **006** | [zcl_skylint_check_006](src/checks/zcl_skylint_check_006.clas.abap) | Detect unnecessary `me->` references when no naming ambiguity exists | `ME_REF` | `"#EC AVOID_ME"` | ✅ Done | ⚡ Ready |
| **007** | [zcl_skylint_check_007](src/checks/zcl_skylint_check_007.clas.abap) | Detect explicit `EXPORTING` in single-parameter or functional method calls | `OMIT_EXP` | `"#EC OMIT_EXPORTING"` | ✅ Done | ⚡ Ready |
| **008** | [zcl_skylint_check_008](src/checks/zcl_skylint_check_008.clas.abap) | Detect multiple assignment chaining (`a = b = c = 0.`) | `CHAIN_EQ` | `"#EC CHAIN_ASSIGN"` | ✅ Done | ⚡ Ready |
| **009** | [zcl_skylint_check_009](src/checks/zcl_skylint_check_009.clas.abap) | Detect legacy chained declarations (`DATA: a, b.`); promote discrete declarations | `CHAIN_DECL` | `"#EC CHAINED_DECL"` | ✅ Done | ⚡ Ready |
| **010** | [zcl_skylint_check_010](src/checks/zcl_skylint_check_010.clas.abap) | Detect legacy `CONCATENATE ... INTO ...`; suggest string templates `\|...\|` | `CONCAT_STR` | `"#EC STRING_TEMPL"` | ✅ Done | ⚡ Ready |

---

### 🟡 Level 2: Intermediate / Block Scope & Control Statements
Structure boundaries, control blocks (`IF`, `CASE`, `LOOP`, `TRY`), and condition evaluation.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **011** | [zcl_skylint_check_011](src/checks/zcl_skylint_check_011.clas.abap) | Detect `IF bool = abap_true` / `IF bool = 'X'`; promote direct `IF bool` | `BOOL_COMP` | `"#EC BOOL_COMPARISON"` | ✅ Done | ⚡ Ready |
| **012** | [zcl_skylint_check_012](src/checks/zcl_skylint_check_012.clas.abap) | Detect `READ TABLE ... TRANSPORTING NO FIELDS`; suggest `line_exists( ... )` | `LINE_EXIST` | `"#EC LINE_EXISTS"` | ✅ Done | ⚡ Ready |
| **013** | [zcl_skylint_check_013](src/checks/zcl_skylint_check_013.clas.abap) | Detect `EXIT` statements in procedures outside loop constructs; suggest `RETURN` | `EXIT_LOOP` | `"#EC EXIT_NOT_IN_LOOP"` | ✅ Done | ⚡ Ready |
| **014** | [zcl_skylint_check_014](src/checks/zcl_skylint_check_014.clas.abap) | Detect `CHECK` inside `LOOP` / `DO` / `WHILE`; promote explicit `IF ... CONTINUE` | `CHECK_LOOP` | `"#EC CHECK_IN_LOOP"` | ✅ Done | ⚡ Ready |
| **015** | [zcl_skylint_check_015](src/checks/zcl_skylint_check_015.clas.abap) | Detect interfaces containing only `CONSTANTS`; suggest global classes or types | `CONST_INTF` | `"#EC CONST_ONLY_INTF"` | ✅ Done | — |
| **016** | [zcl_skylint_check_016](src/checks/zcl_skylint_check_016.clas.abap) | Detect empty `IF`, `CASE`, `LOOP`, `TRY` statement bodies | `EMPTY_BLCK` | `"#EC EMPTY_BLOCK"` | ✅ Done | ⚡ Ready |
| **017** | [zcl_skylint_check_017](src/checks/zcl_skylint_check_017.clas.abap) | Detect empty `CATCH` blocks swallowing exceptions without handling or re-raising | `EMPTY_CAT` | `"#EC EMPTY_CATCH"` | ✅ Done | — |
| **018** | [zcl_skylint_check_018](src/checks/zcl_skylint_check_018.clas.abap) | Detect invalid unit test assertions where actual and expected parameters are identical (`act = exp`) | `IDENT_ASSR` | `"#EC IDENTICAL_ASSERT"` | ✅ Done | — |
| **019** | [zcl_skylint_check_019](src/checks/zcl_skylint_check_019.clas.abap) | Detect duplicate branch conditions in `IF ... ELSEIF` or `CASE ... WHEN` | `DUP_COND` | `"#EC IDENTICAL_COND"` | ✅ Done | — |
| **020** | [zcl_skylint_check_020](src/checks/zcl_skylint_check_020.clas.abap) | Detect consecutive nested single-line `IF` blocks that can be merged with `AND` | `NESTED_IF` | `"#EC MERGE_NESTED_IF"` | ✅ Done | ⚡ Ready |
| **021** | [zcl_skylint_check_021](src/checks/zcl_skylint_check_021.clas.abap) | Detect `WHEN OTHERS` positioned before specific `WHEN` branches in `CASE` | `OTHERS_POS` | `"#EC WHEN_OTHERS_LAST"` | ✅ Done | ⚡ Ready |
| **022** | [zcl_skylint_check_022](src/checks/zcl_skylint_check_022.clas.abap) | Detect dead statements directly following unconditional `RETURN`, `EXIT`, `RAISE EXCEPTION` | `UNREACH` | `"#EC UNREACHABLE_CODE"` | ✅ Done | ⚡ Ready |
| **023** | [zcl_skylint_check_023](src/checks/zcl_skylint_check_023.clas.abap) | Detect `CASE` statements containing only a single `WHEN` branch; suggest `IF ... ELSE` | `SHORT_CASE` | `"#EC PREFER_IF_OVER_CASE"` | ✅ Done | ⚡ Ready |
| **024** | [zcl_skylint_check_024](src/checks/zcl_skylint_check_024.clas.abap) | Detect inverted comparisons (`IF 'X' = lv_var`); promote natural order (`IF lv_var = 'X'`) | `YODA_COND` | `"#EC AVOID_YODA"` | ✅ Done | ⚡ Ready |
| **025** | [zcl_skylint_check_025](src/checks/zcl_skylint_check_025.clas.abap) | Detect legacy comparison keywords (`EQ`, `NE`, `GT`, `LT`, `GE`, `LE`); enforce modern `=`, `<>`, `>`, `<`, `>=`, `<=` | `OBS_COMP` | `"#EC MODERN_OPERATOR"` | ✅ Done | ⚡ Ready |

---

### 🔵 Level 3: Modern ABAP & OO Architecture
Modern expression syntax, encapsulation, test double design, and exception hygiene.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **026** | [zcl_skylint_check_026](src/checks/zcl_skylint_check_026.clas.abap) | Detect legacy `CREATE OBJECT lo_obj`; recommend constructor expression `lo_obj = NEW #( )` | `PREFER_NEW` | `"#EC PREFER_NEW"` | ✅ Done | ⚡ Ready |
| **027** | [zcl_skylint_check_027](src/checks/zcl_skylint_check_027.clas.abap) | Detect legacy `RAISE EXCEPTION TYPE cx_xyz EXPORTING ...`; recommend `RAISE EXCEPTION NEW cx_xyz( ... )` | `RAISE_NEW` | `"#EC RAISE_EXC_NEW"` | ✅ Done | ⚡ Ready |
| **028** | [zcl_skylint_check_028](src/checks/zcl_skylint_check_028.clas.abap) | Detect manual `IF cond. b = abap_true. ELSE. b = abap_false. ENDIF.`; suggest `b = xsdbool( cond )` | `XSD_BOOL` | `"#EC PREFER_XSDBOOL"` | ✅ Done | ⚡ Ready |
| **029** | [zcl_skylint_check_029](src/checks/zcl_skylint_check_029.clas.abap) | Detect explicit `RECEIVING rv_out = lv_out` in functional method calls; suggest direct assignment | `OMIT_RCV` | `"#EC OMIT_RECEIVING"` | ✅ Done | ⚡ Ready |
| **030** | [zcl_skylint_check_030](src/checks/zcl_skylint_check_030.clas.abap) | Detect static class methods called through instance variables (`lo_inst->static_m( )`); enforce `cl_class=>static_m( )` | `STAT_INST` | `"#EC AVOID_STATIC_INST"` | ✅ Done | ⚡ Ready |
| **031** | [zcl_skylint_check_031](src/checks/zcl_skylint_check_031.clas.abap) | Detect mutable `PUBLIC` instance/static attributes; enforce encapsulation with `READ-ONLY` or methods | `PUB_ATTR` | `"#EC NO_PUBLIC_ATTR"` | ✅ Done | — |
| **032** | [zcl_skylint_check_032](src/checks/zcl_skylint_check_032.clas.abap) | Detect legacy `MOVE a TO b`, `REFRESH itab`, `ADD 1 TO i`; enforce modern `=`, `CLEAR` | `OBS_STMT` | `"#EC AVOID_OBSOLETE"` | ✅ Done | ⚡ Ready |
| **033** | [zcl_skylint_check_033](src/checks/zcl_skylint_check_033.clas.abap) | Detect re-raised exceptions missing `PREVIOUS = lx_exc` parameter inside `CATCH` blocks | `LOST_PREV` | `"#EC LOST_PREV_EXC"` | ✅ Done | ⚡ Ready |
| **034** | [zcl_skylint_check_034](src/checks/zcl_skylint_check_034.clas.abap) | Detect excessive parameter signatures (> 8 parameters); suggest structure or object parameters | `SIG_PARAMS` | `"#EC PARAM_COUNT"` | ✅ Done | — |
| **035** | [zcl_skylint_check_035](src/checks/zcl_skylint_check_035.clas.abap) | Detect direct database table access inside ABAP Unit test methods (`FOR TESTING`) | `DB_IN_UT` | `"#EC AVOID_DB_IN_UT"` | ✅ Done | — |

---

### 🔴 Level 6: Database Performance & Security (SQL & Cloud)
Cloud database integrity, SQL performance optimization, and sy-subrc validation.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **036** | [zcl_skylint_check_036](src/checks/zcl_skylint_check_036.clas.abap) | Detect SQL statements (`SELECT`, `MODIFY`, `INSERT`, `DELETE`) inside loop constructs (`LOOP`, `DO`, `WHILE`) | `DB_IN_LOOP` | `"#EC DB_IN_LOOP"` | ✅ Done | — |
| **037** | [zcl_skylint_check_037](src/checks/zcl_skylint_check_037.clas.abap) | Detect `FOR ALL ENTRIES IN itab` without preceding `IF itab IS NOT INITIAL` check | `FAE_EMPTY` | `"#EC FAE_EMPTY_CHECK"` | ✅ Done | ⚡ Ready |
| **038** | [zcl_skylint_check_038](src/checks/zcl_skylint_check_038.clas.abap) | Detect `SELECT *` without column projection and `SELECT ... ENDSELECT` cursor loops | `SEL_PERF` | `"#EC SELECT_PERF"` | ✅ Done | — |
| **039** | [zcl_skylint_check_039](src/checks/zcl_skylint_check_039.clas.abap) | Detect unverified `sy-subrc` directly following `READ TABLE`, `ASSIGN`, `AUTHORITY-CHECK`, and `SELECT SINGLE` | `SUBRC_UNV` | `"#EC CHECK_SYSUBRC"` | ✅ Done | — |
| **040** | [zcl_skylint_check_040](src/checks/zcl_skylint_check_040.clas.abap) | Detect variables declared inside inner loop/condition blocks referenced outside their block scope | `VAR_SCOPE` | `"#EC VAR_SCOPE_LEAK"` | ✅ Done | — |

---

### 🟣 Level 4: Code Quality, Complexity & Structure
Procedural limits, nesting depth control, dead comments cleanup, and constructor hygiene.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **041** | [zcl_skylint_check_041](src/checks/zcl_skylint_check_041.clas.abap) | Detect redundant `VALUE #( ... )` wrapping when target type is identical | `EXTRA_VAL` | `"#EC SUPERFLUOUS_VALUE"` | ✅ Done | ⚡ Ready |
| **042** | [zcl_skylint_check_042](src/checks/zcl_skylint_check_042.clas.abap) | Detect redundant self-assignments (`lv_var = lv_var.`) | `SELF_ASSIGN` | `"#EC SELF_ASSIGNMENT"` | ✅ Done | ⚡ Ready |
| **043** | [zcl_skylint_check_043](src/checks/zcl_skylint_check_043.clas.abap) | Detect constants declared without explicit `TYPE` or length specification | `UNTYPED_C` | `"#EC UNTYPED_CONSTANT"` | ✅ Done | ⚡ Ready |
| **044** | [zcl_skylint_check_044](src/checks/zcl_skylint_check_044.clas.abap) | Detect explicit single parameter name passing when not needed (`lo->m( 1 )` vs `lo->m( iv_val = 1 )`) | `OMIT_PNAME` | `"#EC OMIT_PARAM_NAME"` | ✅ Done | ⚡ Ready |
| **045** | [zcl_skylint_check_045](src/checks/zcl_skylint_check_045.clas.abap) | Detect `TRY ... ENDTRY` blocks missing both `CATCH` and `CLEANUP` sections | `TRY_NO_CAT` | `"#EC TRY_WITHOUT_CATCH"` | ✅ Done | ⚡ Ready |
| **046** | [zcl_skylint_check_046](src/checks/zcl_skylint_check_046.clas.abap) | Detect legacy `TABLES:` statement in local scopes | `LOC_TABLES` | `"#EC AVOID_LOC_TABLES"` | ✅ Done | ⚡ Ready |
| **047** | [zcl_skylint_check_047](src/checks/zcl_skylint_check_047.clas.abap) | Detect legacy `MOVE-CORRESPONDING` statements; suggest functional `CORRESPONDING #( ... )` | `PREF_CORR` | `"#EC PREFER_CORRESPONDING"` | ✅ Done | ⚡ Ready |
| **048** | [zcl_skylint_check_048](src/checks/zcl_skylint_check_048.clas.abap) | Detect long methods exceeding statement limit (> 60 statements) | `METH_LEN` | `"#EC METHOD_LENGTH"` | ✅ Done | — |
| **049** | [zcl_skylint_check_049](src/checks/zcl_skylint_check_049.clas.abap) | Detect excessive control block nesting depth (> 5 levels) | `NEST_DEPTH` | `"#EC MAX_NESTING_DEPTH"` | ✅ Done | — |
| **050** | [zcl_skylint_check_050](src/checks/zcl_skylint_check_050.clas.abap) | Detect methods with multiple `EXPORTING`/`CHANGING` output parameters | `MULTI_OUT` | `"#EC MULTI_OUTPUT_PARAMS"` | ✅ Done | — |

---

### 🟡 Level 5: Security, Authority & Robust Error Handling
Authorization enforcement, system variable safety, SQL host escaping, and class-based exceptions.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **051** | [zcl_skylint_check_051](src/checks/zcl_skylint_check_051.clas.abap) | Detect manual assignments to system variables (`sy-subrc = 0`, `sy-mandt = ...`) | `SY_MOD` | `"#EC AVOID_SY_MOD"` | ✅ Done | — |
| **052** | [zcl_skylint_check_052](src/checks/zcl_skylint_check_052.clas.abap) | Detect methods with a single `EXPORTING` parameter; recommend `RETURNING` | `PREF_RET` | `"#EC PREFER_RETURNING"` | ✅ Done | ⚡ Ready |
| **053** | [zcl_skylint_check_053](src/checks/zcl_skylint_check_053.clas.abap) | Detect classic non-class-based `EXCEPTIONS` in method definitions | `NON_CB_EXC` | `"#EC CLASS_BASED_EXC"` | ✅ Done | — |
| **054** | [zcl_skylint_check_054](src/checks/zcl_skylint_check_054.clas.abap) | Detect risky dynamic/unmanaged statements (`GENERATE SUBROUTINE POOL`, `INSERT REPORT`, `SYSTEM-CALL`) | `DANGER_STM` | `"#EC DANGEROUS_STMT"` | ✅ Done | — |
| **055** | [zcl_skylint_check_055](src/checks/zcl_skylint_check_055.clas.abap) | Detect `CALL TRANSACTION` without prior `AUTHORITY-CHECK` | `AUTH_CHECK` | `"#EC CALL_TRANSACTION"` | ✅ Done | ⚡ Ready |
| **056** | [zcl_skylint_check_056](src/checks/zcl_skylint_check_056.clas.abap) | Enforce `@` prefix on host variables in ABAP SQL (`INTO TABLE @lt_data`, `WHERE col = @lv_val`) | `SQL_HOST_E` | `"#EC SQL_HOST_VAR"` | ✅ Done | ⚡ Ready |
| **057** | [zcl_skylint_check_057](src/checks/zcl_skylint_check_057.clas.abap) | Detect `SELECT ... UP TO 1 ROWS` missing explicit `ORDER BY` clause | `SELECT_UP` | `"#EC SELECT_UP_TO_1"` | ✅ Done | ⚡ Ready |
| **058** | [zcl_skylint_check_058](src/checks/zcl_skylint_check_058.clas.abap) | Detect procedures exceeding cyclomatic complexity limit (CC > 15) | `CYCLO_COMP` | `"#EC CYCLOMATIC_COMPLEXITY"` | ✅ Done | — |
| **059** | [zcl_skylint_check_059](src/checks/zcl_skylint_check_059.clas.abap) | Enforce `FINAL` or explicit inheritance design on helper/utility classes | `NOT_FINAL` | `"#EC CLASS_NOT_FINAL"` | ✅ Done | ⚡ Ready |
| **060** | [zcl_skylint_check_060](src/checks/zcl_skylint_check_060.clas.abap) | Detect `RAISE SHORTDUMP` statements; recommend graceful class-based exceptions | `SHORTDUMP` | `"#EC AVOID_SHORTDUMP"` | ✅ Done | ⚡ Ready |

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
