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

## 📋 Clean ABAP & Cloud Rule Catalog (106 Rules)

All Clean ABAP, security, and cloud-native rules are organized across 11 focused levels:

### 🟢 Level 1: Beginner / Direct Pattern Matching (001 - 010)
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

### 🟡 Level 2: Intermediate / Block Scope & Control Statements (011 - 025)
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

### 🔵 Level 3: Modern ABAP & OO Architecture (026 - 035)
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

### 🔴 Level 4: Database Performance & Scope Hygiene (036 - 040)
Cloud database integrity, SQL performance optimization, and variable scope safety.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **036** | [zcl_skylint_check_036](src/checks/zcl_skylint_check_036.clas.abap) | Detect SQL statements (`SELECT`, `MODIFY`, `INSERT`, `DELETE`) inside loop constructs (`LOOP`, `DO`, `WHILE`) | `DB_IN_LOOP` | `"#EC DB_IN_LOOP"` | ✅ Done | — |
| **037** | [zcl_skylint_check_037](src/checks/zcl_skylint_check_037.clas.abap) | Detect `FOR ALL ENTRIES IN itab` without preceding `IF itab IS NOT INITIAL` check | `FAE_EMPTY` | `"#EC FAE_EMPTY_CHECK"` | ✅ Done | ⚡ Ready |
| **038** | [zcl_skylint_check_038](src/checks/zcl_skylint_check_038.clas.abap) | Detect `SELECT *` without column projection and `SELECT ... ENDSELECT` cursor loops | `SEL_PERF` | `"#EC SELECT_PERF"` | ✅ Done | — |
| **039** | [zcl_skylint_check_039](src/checks/zcl_skylint_check_039.clas.abap) | Detect unverified `sy-subrc` directly following `READ TABLE`, `ASSIGN`, `AUTHORITY-CHECK`, and `SELECT SINGLE` | `SUBRC_UNV` | `"#EC CHECK_SYSUBRC"` | ✅ Done | — |
| **040** | [zcl_skylint_check_040](src/checks/zcl_skylint_check_040.clas.abap) | Detect variables declared inside inner loop/condition blocks referenced outside their block scope | `VAR_SCOPE` | `"#EC VAR_SCOPE_LEAK"` | ✅ Done | — |

---

### 🟣 Level 5: Code Quality, Complexity & Structure (041 - 050)
Procedural limits, nesting depth control, typing clarity, and method length.

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

### 🟡 Level 6: Security, Authority & Robust Error Handling (051 - 060)
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

### 🟧 Level 7: Modern Data Types, Literals & Expressions (061 - 070)
Modern literal forms, table expressions, functional constructs, and typing cleanliness.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **061** | [zcl_skylint_check_061](src/checks/zcl_skylint_check_061.clas.abap) | Prefer backtick string literals (``` `text` ```) over single quotes (`'text'`) for `STRING` types | `BACKTICK` | `"#EC STRING_BACKTICK"` | ✅ Done | ⚡ Ready |
| **062** | [zcl_skylint_check_062](src/checks/zcl_skylint_check_062.clas.abap) | Avoid hardcoded magic numbers (`IF status = 4.`); recommend named constants | `MAGIC_NUM` | `"#EC MAGIC_NUMBER"` | ✅ Done | — |
| **063** | [zcl_skylint_check_063](src/checks/zcl_skylint_check_063.clas.abap) | Prefer modern table expressions (`wa = itab[ 1 ]`) over `READ TABLE itab INDEX 1` | `TAB_EXPR` | `"#EC TABLE_EXPR"` | ✅ Done | ⚡ Ready |
| **064** | [zcl_skylint_check_064](src/checks/zcl_skylint_check_064.clas.abap) | Prefer `INSERT ... INTO TABLE` over `APPEND` for generic/hashed/sorted table safety | `PREF_INSRT` | `"#EC PREFER_INSERT"` | ✅ Done | ⚡ Ready |
| **065** | [zcl_skylint_check_065](src/checks/zcl_skylint_check_065.clas.abap) | Avoid obsolete control statements (`ON CHANGE OF`, `SUM`, `AT NEW`) inside `LOOP` | `OBS_L_CTRL` | `"#EC AVOID_LOOP_CTRL"` | ✅ Done | — |
| **066** | [zcl_skylint_check_066](src/checks/zcl_skylint_check_066.clas.abap) | Prefer `COND #( ... )` / `SWITCH #( ... )` expressions over verbose multi-branch variable assignments | `COND_SWTCH` | `"#EC PREFER_COND"` | ✅ Done | ⚡ Ready |
| **067** | [zcl_skylint_check_067](src/checks/zcl_skylint_check_067.clas.abap) | Avoid `LIKE` referencing internal data types; enforce explicit `TYPE` | `AVOID_LIKE` | `"#EC AVOID_LIKE_TYPE"` | ✅ Done | ⚡ Ready |
| **068** | [zcl_skylint_check_068](src/checks/zcl_skylint_check_068.clas.abap) | Keep constructors clean; avoid heavy business logic/loops/DB access (configurable max statements) | `CTOR_LOGIC` | `"#EC CONSTRUCTOR_LOGIC"` | ✅ Done | ⚡ Ready |
| **069** | [zcl_skylint_check_069](src/checks/zcl_skylint_check_069.clas.abap) | Prefer functional `REDUCE #( ... )` expression over manual loop aggregation (arithmetic/string/bitwise) | `PREF_REDUC` | `"#EC PREFER_REDUCE"` | ✅ Done | ⚡ Ready |
| **070** | [zcl_skylint_check_070](src/checks/zcl_skylint_check_070.clas.abap) | Avoid generic `FIELD-SYMBOLS` types (`ANY`, `DATA`, `CLIKE`, `CSEQUENCE`, generic tables); declare concrete type | `GEN_FS_TYP` | `"#EC GENERIC_FS"` | ✅ Done | — |

---

### 🟫 Level 8: Object-Oriented Design & Clean Interfaces (071 - 080)
Encapsulation, component coupling, exception handling, and clean interface design.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **071** | [zcl_skylint_check_071](src/checks/zcl_skylint_check_071.clas.abap) | Avoid static-only classes; promote instantiable interface-based design | `STAT_CLASS` | `"#EC AVOID_STATIC_CLS"` | ✅ Done | — |
| **072** | [zcl_skylint_check_072](src/checks/zcl_skylint_check_072.clas.abap) | Avoid unmodified `CHANGING` parameters in procedures; convert to `IMPORTING` | `UNCHG_PARM` | `"#EC UNMODIFIED_CHANGING"` | ✅ Done | ⚡ Ready |
| **073** | [zcl_skylint_check_073](src/checks/zcl_skylint_check_073.clas.abap) | Enforce predicate naming (`IS_`, `HAS_`, `CAN_`, `CHECK_`) on boolean-returning methods | `BOOL_NAME` | `"#EC BOOL_METHOD_NAME"` | ✅ Done | — |
| **074** | [zcl_skylint_check_074](src/checks/zcl_skylint_check_074.clas.abap) | Avoid deep class inheritance hierarchies (inheritance depth > 3) | `DEEP_INHRT` | `"#EC DEEP_INHERITANCE"` | ✅ Done | — |
| **075** | [zcl_skylint_check_075](src/checks/zcl_skylint_check_075.clas.abap) | Limit total number of member attributes in a class (configurable, default 15) | `ATTR_COUNT` | `"#EC MAX_CLASS_ATTR"` | ✅ Done | — |
| **076** | [zcl_skylint_check_076](src/checks/zcl_skylint_check_076.clas.abap) | Avoid mutable `DATA` declarations in interfaces; allow only `CONSTANTS` | `INTF_DATA` | `"#EC INTERFACE_DATA"` | ✅ Done | — |
| **077** | [zcl_skylint_check_077](src/checks/zcl_skylint_check_077.clas.abap) | Avoid generic `CATCH cx_root`; catch specific exception classes instead | `CATCH_ROOT` | `"#EC AVOID_CX_ROOT"` | ✅ Done | — |
| **078** | [zcl_skylint_check_078](src/checks/zcl_skylint_check_078.clas.abap) | Avoid obsolete `MESSAGE ... RAISING`; raise class-based exceptions | `MSG_RAISE` | `"#EC AVOID_MSG_RAISING"` | ✅ Done | ⚡ Ready |
| **079** | [zcl_skylint_check_079](src/checks/zcl_skylint_check_079.clas.abap) | Avoid nested `TRY ... ENDTRY` blocks; extract inner error handling to helper methods | `NESTED_TRY` | `"#EC AVOID_NESTED_TRY"` | ✅ Done | — |
| **080** | [zcl_skylint_check_080](src/checks/zcl_skylint_check_080.clas.abap) | Avoid raising SAP internal system exceptions (`cx_sy_*`); use application exceptions | `RAISE_SYS` | `"#EC AVOID_RAISE_SY_EXC"` | ✅ Done | — |

---

### 🟦 Level 9: Error Handling, Exception Design & Cloud Safety (081 - 090)
Exception handling, resource disposal, RAP transactional consistency, and Cloud-safe modularization.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **081** | [zcl_skylint_check_081](src/checks/zcl_skylint_check_081.clas.abap) | Ensure `TRY` blocks handling external resources include a `CLEANUP` section | `TRY_CLEAN` | `"#EC MISSING_CLEANUP"` | ✅ Done | ⚡ Ready |
| **082** | [zcl_skylint_check_082](src/checks/zcl_skylint_check_082.clas.abap) | Enforce explicit `sy-subrc` verification directly after `FIND` / `SEARCH` operations | `FIND_SUBRC` | `"#EC CHECK_FIND_SUBRC"` | ✅ Done | — |
| **083** | [zcl_skylint_check_083](src/checks/zcl_skylint_check_083.clas.abap) | Avoid obsolete modularization constructs (`FORM ... ENDFORM`) in ABAP Cloud | `AVOID_FORM` | `"#EC AVOID_FORM_ROUTINE"` | ✅ Done | — |
| **084** | [zcl_skylint_check_084](src/checks/zcl_skylint_check_084.clas.abap) | Avoid hardcoded user name comparisons (`IF sy-uname = 'ADMIN'`); enforce authorizations | `HARD_UNAME` | `"#EC AVOID_HARDCODED_USER"` | ✅ Done | — |
| **085** | [zcl_skylint_check_085](src/checks/zcl_skylint_check_085.clas.abap) | Avoid direct client specifications (`USING CLIENT`, `CLIENT SPECIFIED`) in ABAP SQL | `CLIENT_SPEC`| `"#EC AVOID_CLIENT_SPEC"` | ✅ Done | ⚡ Ready |
| **086** | [zcl_skylint_check_086](src/checks/zcl_skylint_check_086.clas.abap) | Avoid `COMMIT WORK` or `ROLLBACK WORK` in RAP entity behavior implementations | `NO_COMMIT` | `"#EC AVOID_COMMIT_WORK"` | ✅ Done | — |
| **087** | [zcl_skylint_check_087](src/checks/zcl_skylint_check_087.clas.abap) | Prefer modern `FILTER #( ... )` operator over manual filtering copy loops | `PREF_FILTR` | `"#EC PREFER_FILTER"` | ✅ Done | ⚡ Ready |
| **088** | [zcl_skylint_check_088](src/checks/zcl_skylint_check_088.clas.abap) | Avoid full-line `MODIFY itab FROM wa` inside `LOOP` without `TRANSPORTING` clause | `FULL_MODIF` | `"#EC AVOID_FULL_MODIFY"` | ✅ Done | ⚡ Ready |
| **089** | [zcl_skylint_check_089](src/checks/zcl_skylint_check_089.clas.abap) | Enforce test method naming convention (`TEST_` or `SHOULD_`) in ABAP Unit classes | `TEST_NAME` | `"#EC TEST_METHOD_NAME"` | ✅ Done | — |
| **090** | [zcl_skylint_check_090](src/checks/zcl_skylint_check_090.clas.abap) | Avoid magic offset substring expressions (`var+0(2)`); suggest named constants | `OFFST_MAG` | `"#EC MAGIC_OFFSET"` | ✅ Done | — |

---

### 🟪 Level 10: Clean Methods, Security & Modern Syntax (091 - 100)
Method modifiers, modern string built-ins, calculation operators, guard clauses, and dynamic SQL safety.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **091** | [zcl_skylint_check_091](src/checks/zcl_skylint_check_091.clas.abap) | Avoid unescaped dynamic SQL clauses (`SELECT (cols) FROM (dbtab)`) without sanitization | `DYN_SQL` | `"#EC AVOID_DYNAMIC_SQL"` | ✅ Done | — |
| **092** | [zcl_skylint_check_092](src/checks/zcl_skylint_check_092.clas.abap) | Prefer marking non-overridden public class methods as `FINAL` | `PREF_FINAL` | `"#EC PREFER_FINAL_METHOD"` | ✅ Done | ⚡ Ready |
| **093** | [zcl_skylint_check_093](src/checks/zcl_skylint_check_093.clas.abap) | Detect `CONDENSE` statement; suggest built-in `condense( ... )` string function | `CONDENSE_S` | `"#EC CONDENSE_STMT"` | ✅ Done | ⚡ Ready |
| **094** | [zcl_skylint_check_094](src/checks/zcl_skylint_check_094.clas.abap) | Detect `TRANSLATE ... TO UPPER/LOWER CASE`; suggest `to_upper( ... )` / `to_lower( ... )` | `TRANSLATE_` | `"#EC TRANSLATE_STMT"` | ✅ Done | ⚡ Ready |
| **095** | [zcl_skylint_check_095](src/checks/zcl_skylint_check_095.clas.abap) | Prefer calculation assignment operators (`+=`, `-=`, `*=`, `/=`) over `i = i + 1` | `CALC_ASSGN` | `"#EC PREFER_CALC_ASSIGN"` | ✅ Done | ⚡ Ready |
| **096** | [zcl_skylint_check_096](src/checks/zcl_skylint_check_096.clas.abap) | Replace long `IF` block wrapping loop body end with early `IF NOT ... CONTINUE` guard clause | `GUARD_LOOP` | `"#EC GUARD_IN_LOOP"` | ✅ Done | ⚡ Ready |
| **097** | [zcl_skylint_check_097](src/checks/zcl_skylint_check_097.clas.abap) | Replace long `IF` block wrapping method body end with early `IF NOT ... RETURN` guard clause | `GUARD_METH` | `"#EC GUARD_IN_METHOD"` | ✅ Done | ⚡ Ready |
| **098** | [zcl_skylint_check_098](src/checks/zcl_skylint_check_098.clas.abap) | Detect native `ASSERT <condition>` in production logic; recommend exceptions | `PROD_ASSRT` | `"#EC PROD_ASSERT"` | ✅ Done | ⚡ Ready |
| **099** | [zcl_skylint_check_099](src/checks/zcl_skylint_check_099.clas.abap) | Detect unused local variables and field symbols (`DATA`, `FIELD-SYMBOLS`) | `UNUSED_VAR` | `"#EC UNUSED_VAR"` | ✅ Done | ⚡ Ready |
| **100** | [zcl_skylint_check_100](src/checks/zcl_skylint_check_100.clas.abap) | Detect unnecessary `CLEAR` on newly declared variables or immediately before method exit | `NEEDLES_CL` | `"#EC NEEDLESS_CLEAR"` | ✅ Done | ⚡ Ready |

---

### 🟧 Level 11: Declarations, Modern Table Operations & Assignment (101 - 106)
Declaration hygiene, colon chain simplification, parameter escaping, modern table operations, and obsolete MOVE removal.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **101** | [zcl_skylint_check_101](src/checks/zcl_skylint_check_101.clas.abap) | Enforce standard local declaration order (`TYPES` -> `CONSTANTS` -> `DATA` -> `FIELD-SYMBOLS`) | `DECL_ORDER` | `"#EC LOCAL_DECL_ORDER"` | ✅ Done | ⚡ Ready |
| **102** | [zcl_skylint_check_102](src/checks/zcl_skylint_check_102.clas.abap) | Simplify single-element colon declaration chain (`DATA: lv_a TYPE i.` -> `DATA lv_a TYPE i.`) | `CHAIN_ONE` | `"#EC SINGLE_CHAIN"` | ✅ Done | ⚡ Ready |
| **103** | [zcl_skylint_check_103](src/checks/zcl_skylint_check_103.clas.abap) | Detect unnecessary exclamation mark parameter escape (`!iv_param`) when no keyword clash exists | `PARAM_ESCP` | `"#EC UNNECESSARY_ESCAPE"` | ✅ Done | ⚡ Ready |
| **104** | [zcl_skylint_check_104](src/checks/zcl_skylint_check_104.clas.abap) | Prefer modern `line_exists( ... )` over `READ TABLE ... TRANSPORTING NO FIELDS` | `PREF_EXST` | `"#EC PREFER_LINE_EXISTS"` | ✅ Done | ⚡ Ready |
| **105** | [zcl_skylint_check_105](src/checks/zcl_skylint_check_105.clas.abap) | Prefer modern `line_index( ... )` over `READ TABLE ...` to retrieve row index | `PREF_INDX` | `"#EC PREFER_LINE_INDEX"` | ✅ Done | ⚡ Ready |
| **106** | [zcl_skylint_check_106](src/checks/zcl_skylint_check_106.clas.abap) | Avoid obsolete `MOVE ... TO` statement; use modern assignment operator `=` | `AVOID_MOVE` | `"#EC AVOID_MOVE_STMT"` | ✅ Done | ⚡ Ready |

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
