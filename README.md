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

## 📋 Comprehensive 173-Rule Catalog & Roadmap

All 173 Clean ABAP, ABAP Cleaner & Cloud rules are systematically organized across 16 progressive levels without duplication.

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

### 🟧 Level 7: Modern Data Types, Literals & Expressions (061 - 070)
Modern literal forms, table expressions, functional constructs, and typing cleanliness.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **061** | `zcl_skylint_check_061` | Prefer backtick string literals (``` `text` ```) over single quotes (`'text'`) for `STRING` types | `BACKTICK` | `"#EC STRING_BACKTICK"` | 📋 Planned | ⚡ Ready |
| **062** | `zcl_skylint_check_062` | Avoid hardcoded magic numbers (`IF status = 4.`); recommend named constants | `MAGIC_NUM` | `"#EC MAGIC_NUMBER"` | 📋 Planned | — |
| **063** | `zcl_skylint_check_063` | Prefer modern table expressions (`wa = itab[ 1 ]`) over `READ TABLE itab INDEX 1` | `TAB_EXPR` | `"#EC TABLE_EXPR"` | 📋 Planned | ⚡ Ready |
| **064** | `zcl_skylint_check_064` | Prefer `INSERT ... INTO TABLE` over `APPEND` for generic/hashed/sorted table safety | `PREF_INSRT` | `"#EC PREFER_INSERT"` | 📋 Planned | ⚡ Ready |
| **065** | `zcl_skylint_check_065` | Avoid obsolete control statements (`ON CHANGE OF`, `SUM`, `AT NEW`) inside `LOOP` | `OBS_L_CTRL` | `"#EC AVOID_LOOP_CTRL"` | 📋 Planned | — |
| **066** | `zcl_skylint_check_066` | Prefer `COND #( ... )` / `SWITCH #( ... )` expressions over verbose multi-branch variable assignments | `COND_SWTCH` | `"#EC PREFER_COND"` | 📋 Planned | ⚡ Ready |
| **067** | `zcl_skylint_check_067` | Avoid `LIKE` referencing internal data types; enforce explicit `TYPE` | `AVOID_LIKE` | `"#EC AVOID_LIKE_TYPE"` | 📋 Planned | ⚡ Ready |
| **068** | `zcl_skylint_check_068` | Ensure `constructor` redefinition explicitly calls `super->constructor( )` | `SUPER_CALL` | `"#EC CONSTRUCTOR_SUPER"` | 📋 Planned | ⚡ Ready |
| **069** | `zcl_skylint_check_069` | Prefer `REDUCE #( ... )` expression over manual loop aggregation into scalar variables | `PREF_REDUC` | `"#EC PREFER_REDUCE"` | 📋 Planned | ⚡ Ready |
| **070** | `zcl_skylint_check_070` | Avoid generic `FIELD-SYMBOLS <fs> TYPE ANY` when specific data type is statically known | `GEN_FS_TYP` | `"#EC GENERIC_FS"` | 📋 Planned | — |

---

### 🟫 Level 8: Object-Oriented Design & Clean Interfaces (071 - 080)
Encapsulation, component coupling, dependency injection, and signature naming conventions.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **071** | `zcl_skylint_check_071` | Avoid direct instantiation (`NEW cl_service( )`) in business logic; promote Constructor Injection | `NO_DIRECT_` | `"#EC AVOID_DIRECT_NEW"` | 📋 Planned | — |
| **072** | `zcl_skylint_check_072` | Enforce class definition section ordering (`PUBLIC` -> `PROTECTED` -> `PRIVATE`) | `SECT_ORDER` | `"#EC SECTION_ORDER"` | 📋 Planned | ⚡ Ready |
| **073** | `zcl_skylint_check_073` | Avoid static-only global classes; promote instantiable interface-based design | `STAT_CLASS` | `"#EC AVOID_STATIC_CLS"` | 📋 Planned | — |
| **074** | `zcl_skylint_check_074` | Prefer interface methods over direct public class methods for decoupling | `INTF_METH` | `"#EC PREFER_INTERFACE"` | 📋 Planned | — |
| **075** | `zcl_skylint_check_075` | Avoid deep class inheritance hierarchies (inheritance depth > 3) | `DEEP_INHRT` | `"#EC DEEP_INHERITANCE"` | 📋 Planned | — |
| **076** | `zcl_skylint_check_076` | Ensure test double classes in program includes are marked `FOR TESTING` | `TEST_SCOPE` | `"#EC TEST_DOUBLE_SCOPE"` | 📋 Planned | ⚡ Ready |
| **077** | `zcl_skylint_check_077` | Avoid unmodified `CHANGING` parameters in procedures; convert to `IMPORTING` | `UNCHG_PARM` | `"#EC UNMODIFIED_CHANGING"` | 📋 Planned | ⚡ Ready |
| **078** | `zcl_skylint_check_078` | Enforce predicate naming (`IS_`, `HAS_`, `CAN_`, `CHECK_`) on boolean-returning methods | `BOOL_NAME` | `"#EC BOOL_METHOD_NAME"` | 📋 Planned | — |
| **079** | `zcl_skylint_check_079` | Avoid passing `me` self-reference outside constructor during object initialization | `ME_IN_INIT` | `"#EC ME_IN_CONSTRUCTOR"` | 📋 Planned | — |
| **080** | `zcl_skylint_check_080` | Limit total number of member attributes in a class (<= 15 attributes) | `ATTR_COUNT` | `"#EC MAX_CLASS_ATTR"` | 📋 Planned | — |

---

### 🟦 Level 9: Error Handling, Exception Design & Logging (081 - 090)
Exception inheritance hierarchy, granularity, resource disposal, and messaging cleanliness.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **081** | `zcl_skylint_check_081` | Avoid generic `CATCH cx_root`; catch specific exception subclasses | `CATCH_ROOT` | `"#EC AVOID_CX_ROOT"` | 📋 Planned | — |
| **082** | `zcl_skylint_check_082` | Avoid `CATCH cx_err` without `INTO lx_err` when error details or propagation are needed | `NO_CATCH_V` | `"#EC CATCH_NO_VAR"` | 📋 Planned | ⚡ Ready |
| **083** | `zcl_skylint_check_083` | Ensure `TRY` blocks handling external resources include a `CLEANUP` section | `TRY_CLEAN` | `"#EC MISSING_CLEANUP"` | 📋 Planned | ⚡ Ready |
| **084** | `zcl_skylint_check_084` | Avoid non-static mutable `DATA` declarations in interfaces; allow only `CONSTANTS` | `INTF_DATA` | `"#EC INTERFACE_DATA"` | 📋 Planned | — |
| **085** | `zcl_skylint_check_085` | Ensure custom exception classes inherit from `CX_STATIC_CHECK` or `CX_NO_CHECK` | `EXC_BASE` | `"#EC CUSTOM_EXC_BASE"` | 📋 Planned | — |
| **086** | `zcl_skylint_check_086` | Avoid manually raising SAP internal system exceptions (`RAISE EXCEPTION TYPE cx_sy_*`) | `RAISE_SYS` | `"#EC AVOID_RAISE_SY_EXC"` | 📋 Planned | — |
| **087** | `zcl_skylint_check_087` | Enforce explicit `sy-subrc` verification directly after `FIND` / `SEARCH` operations | `FIND_SUBRC` | `"#EC CHECK_FIND_SUBRC"` | 📋 Planned | — |
| **088** | `zcl_skylint_check_088` | Avoid nested `TRY ... ENDTRY` blocks; extract inner handling to dedicated helper methods | `NESTED_TRY` | `"#EC AVOID_NESTED_TRY"` | 📋 Planned | — |
| **089** | `zcl_skylint_check_089` | Avoid legacy `MESSAGE ... RAISING`; enforce modern `RAISE EXCEPTION` | `MSG_RAISE` | `"#EC AVOID_MSG_RAISING"` | 📋 Planned | ⚡ Ready |
| **090** | `zcl_skylint_check_090` | Ensure T100 exception instances provide `TEXTID` or required message parameter mapping | `MSG_TEXTID` | `"#EC MISSING_MSG_TEXTID"` | 📋 Planned | — |

---

### 🟪 Level 10: Cloud Ready, Secure Coding & Clean Syntax (091 - 100)
Multi-tenancy isolation, RAP transactional consistency, and modern table filtering.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **091** | `zcl_skylint_check_091` | Avoid obsolete modularization constructs (`FORM ... ENDFORM`, `FUNCTION`) in ABAP Cloud | `AVOID_FORM` | `"#EC AVOID_FORM_ROUTINE"` | 📋 Planned | — |
| **092** | `zcl_skylint_check_092` | Avoid hardcoded user name comparisons (`IF sy-uname = 'ADMIN'`); enforce authorizations | `HARD_UNAME` | `"#EC AVOID_HARDCODED_USER"` | 📋 Planned | — |
| **093** | `zcl_skylint_check_093` | Avoid direct client specifications (`USING CLIENT`, `CLIENT SPECIFIED`) in ABAP SQL | `CLIENT_SPEC`| `"#EC AVOID_CLIENT_SPEC"` | 📋 Planned | ⚡ Ready |
| **094** | `zcl_skylint_check_094` | Avoid `COMMIT WORK` or `ROLLBACK WORK` in RAP entity behavior implementations | `NO_COMMIT` | `"#EC AVOID_COMMIT_WORK"` | 📋 Planned | — |
| **095** | `zcl_skylint_check_095` | Prefer modern `FILTER #( ... )` operator over manual filtering copy loops | `PREF_FILTR` | `"#EC PREFER_FILTER"` | 📋 Planned | ⚡ Ready |
| **096** | `zcl_skylint_check_096` | Avoid full-line `MODIFY itab FROM wa` inside `LOOP` without `TRANSPORTING` clause | `FULL_MODIF` | `"#EC AVOID_FULL_MODIFY"` | 📋 Planned | ⚡ Ready |
| **097** | `zcl_skylint_check_097` | Enforce test method naming convention (`TEST_` or `SHOULD_`) in ABAP Unit classes | `TEST_NAME` | `"#EC TEST_METHOD_NAME"` | 📋 Planned | — |
| **098** | `zcl_skylint_check_098` | Avoid magic offset substring expressions (`var+0(2)`); suggest named constants or regex | `OFFST_MAG` | `"#EC MAGIC_OFFSET"` | 📋 Planned | — |
| **099** | `zcl_skylint_check_099` | Avoid unescaped dynamic SQL clauses (`SELECT (cols) FROM (dbtab)`) without sanitization | `DYN_SQL` | `"#EC AVOID_DYNAMIC_SQL"` | 📋 Planned | — |
| **100** | `zcl_skylint_check_100` | Prefer marking non-overridden public class methods as `FINAL` | `PREF_FINAL` | `"#EC PREFER_FINAL_METHOD"` | 📋 Planned | ⚡ Ready |

---

### 🟧 Level 11: Modern ABAP Statements & Control Flow Enhancements (101 - 106)
Modern string built-in functions, calculation assignments, guard clauses, and testable assertion patterns.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **101** | `zcl_skylint_check_101` | Detect `CONDENSE` statement; suggest built-in `condense( ... )` string function | `CONDENSE_S` | `"#EC CONDENSE_STMT"` | 📋 Planned | ⚡ Ready |
| **102** | `zcl_skylint_check_102` | Detect `TRANSLATE ... TO UPPER/LOWER CASE`; suggest `to_upper( ... )` / `to_lower( ... )` | `TRANSLATE_` | `"#EC TRANSLATE_STMT"` | 📋 Planned | ⚡ Ready |
| **103** | `zcl_skylint_check_103` | Prefer calculation assignment operators (`+=`, `-=`, `*=`, `/=`) over `i = i + 1` | `CALC_ASSGN` | `"#EC PREFER_CALC_ASSIGN"` | 📋 Planned | ⚡ Ready |
| **104** | `zcl_skylint_check_104` | Replace long `IF` block wrapping loop body end with early `IF NOT ... CONTINUE` guard clause | `GUARD_LOOP` | `"#EC GUARD_IN_LOOP"` | 📋 Planned | ⚡ Ready |
| **105** | `zcl_skylint_check_105` | Replace long `IF` block wrapping method body end with early `IF NOT ... RETURN` guard clause | `GUARD_METH` | `"#EC GUARD_IN_METHOD"` | 📋 Planned | ⚡ Ready |
| **106** | `zcl_skylint_check_106` | Detect native `ASSERT <condition>` in production logic; recommend testable assertion helper / exception | `PROD_ASSRT` | `"#EC PROD_ASSERT"` | 📋 Planned | ⚡ Ready |

---

### 🟨 Level 12: Declarations, Variable Hygiene & Documentation (107 - 113)
Dead variable elimination, declaration ordering, redundant clears, and ABAP Doc standardization.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **107** | `zcl_skylint_check_107` | Detect unused local variables and field symbols (`DATA`, `FIELD-SYMBOLS`) | `UNUSED_VAR` | `"#EC UNUSED_VAR"` | 📋 Planned | ⚡ Ready |
| **108** | `zcl_skylint_check_108` | Detect unnecessary `CLEAR` on newly declared variables or immediately before method exit | `NEEDLES_CL` | `"#EC NEEDLESS_CLEAR"` | 📋 Planned | ⚡ Ready |
| **109** | `zcl_skylint_check_109` | Enforce standard local declaration order (`TYPES` -> `CONSTANTS` -> `DATA` -> `FIELD-SYMBOLS`) | `DECL_ORDER` | `"#EC LOCAL_DECL_ORDER"` | 📋 Planned | ⚡ Ready |
| **110** | `zcl_skylint_check_110` | Simplify single-element colon declaration chain (`DATA: lv_a TYPE i.` -> `DATA lv_a TYPE i.`) | `CHAIN_ONE` | `"#EC SINGLE_CHAIN"` | 📋 Planned | ⚡ Ready |
| **111** | `zcl_skylint_check_111` | Detect unnecessary exclamation mark parameter escape (`!iv_param`) when no keyword clash exists | `PARAM_ESCP` | `"#EC UNNECESSARY_ESCAPE"` | 📋 Planned | ⚡ Ready |
| **112** | `zcl_skylint_check_112` | Detect obsolete `lang="en"` / `lang="..."` tag inside ABAP Doc comments | `ADOC_LANG` | `"#EC ABAP_DOC_LANG"` | 📋 Planned | ⚡ Ready |
| **113** | `zcl_skylint_check_113` | Ensure all method parameters and exceptions are documented in corresponding ABAP Doc header | `ADOC_PARAM` | `"#EC ABAP_DOC_PARAMS"` | 📋 Planned | ⚡ Ready |

---

### 🟩 Level 13: Comments, Pragmas & Syntax Standardization (114 - 120)
Pragma positioning, legacy pseudo-comment migration, redundant comment cleanup, and typo detection.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **114** | `zcl_skylint_check_114` | Detect legacy pseudo-comments (`"#EC ...`) replaceable by standard compiler pragmas (`##...`) | `MIG_PRAGMA` | `"#EC MIGRATE_PRAGMA"` | 📋 Planned | ⚡ Ready |
| **115** | `zcl_skylint_check_115` | Ensure pragmas are placed before the closing period/comma rather than after or on separate lines | `PRAGMA_POS` | `"#EC PRAGMA_POSITION"` | 📋 Planned | ⚡ Ready |
| **116** | `zcl_skylint_check_116` | Detect redundant end-of-block comments repeating construct name (`" ENDMETHOD lv_name`) | `END_COMMNT` | `"#EC REDUNDANT_END_COMMENT"` | 📋 Planned | ⚡ Ready |
| **117** | `zcl_skylint_check_117` | Detect empty statements consisting only of redundant period or colon tokens (`.`, `::`) | `EMPTY_STMT` | `"#EC EMPTY_STATEMENT"` | 📋 Planned | ⚡ Ready |
| **118** | `zcl_skylint_check_118` | Prefer `"` inline comments over legacy full-line asterisk `*` comments | `COMM_STYLE` | `"#EC PREFER_QUOTE_COMMENT"` | 📋 Planned | ⚡ Ready |
| **119** | `zcl_skylint_check_119` | Move Boolean logical operators (`AND`, `OR`, `EQUIV`) from line end to start of next line | `LOG_OP_POS` | `"#EC OPERATOR_AT_LINE_START"` | 📋 Planned | ⚡ Ready |
| **120** | `zcl_skylint_check_120` | Detect frequent typos in ABAP comments, documentation strings, and message literals | `TYPO_CHECK` | `"#EC COMMON_TYPO"` | 📋 Planned | ⚡ Ready |

---

### 🟪 Level 14: Whitespace, Indentation & Formatting Hygiene (121 - 134)
Spacing, bracket positioning, line formatting, casing consistency, and blank line density.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **121** | `zcl_skylint_check_121` | Enforce closing brackets (`)`, `]`) at line end rather than isolated on standalone lines | `BRACKET_PO` | `"#EC BRACKET_POSITION"` | 📋 Planned | ⚡ Ready |
| **122** | `zcl_skylint_check_122` | Detect needless consecutive whitespace inside statements where no alignment intent exists | `NEEDLS_SPC` | `"#EC NEEDLESS_SPACE"` | 📋 Planned | ⚡ Ready |
| **123** | `zcl_skylint_check_123` | Ensure at least one space before and after the comment symbol `"` | `COMM_SPACE` | `"#EC SPACE_AROUND_COMMENT"` | 📋 Planned | ⚡ Ready |
| **124** | `zcl_skylint_check_124` | Ensure proper space separation around text literals (`'...'`, `` `...` ``) | `LIT_SPACE` | `"#EC SPACE_AROUND_LITERAL"` | 📋 Planned | ⚡ Ready |
| **125** | `zcl_skylint_check_125` | Remove invalid space preceding commas and period statement terminators (` ,`, ` .`) | `TERM_SPACE` | `"#EC SPACE_BEFORE_PERIOD"` | 📋 Planned | ⚡ Ready |
| **126** | `zcl_skylint_check_126` | Enforce consistent 2-space indentation depth across ABAP statements and block scopes | `INDENT_ERR` | `"#EC INDENTATION"` | 📋 Planned | ⚡ Ready |
| **127** | `zcl_skylint_check_127` | Enforce uppercase keywords and lowercase identifier casing standards | `CASE_STYLE` | `"#EC KEYWORD_CASING"` | 📋 Planned | ⚡ Ready |
| **128** | `zcl_skylint_check_128` | Enforce CamelCase naming conventions for known CDS view entities and fields in ABAP | `CAMEL_CASE` | `"#EC CAMEL_CASE_NAME"` | 📋 Planned | ⚡ Ready |
| **129** | `zcl_skylint_check_129` | Enforce CamelCase naming for CDS views in ABAP Unit test class doubles and test methods | `CDS_UT_CC` | `"#EC CDS_TEST_CAMEL_CASE"` | 📋 Planned | ⚡ Ready |
| **130** | `zcl_skylint_check_130` | Detect multiple ABAP statements on a single line; enforce one statement per line | `STMT_P_LIN` | `"#EC ONE_STMT_PER_LINE"` | 📋 Planned | ⚡ Ready |
| **131** | `zcl_skylint_check_131` | Standardize empty line spacing between sections inside `CLASS ... DEFINITION` | `DEF_EMPT_L` | `"#EC CLASS_DEF_EMPTY_LINES"` | 📋 Planned | ⚡ Ready |
| **132** | `zcl_skylint_check_132` | Standardize empty line spacing outside method implementations (between methods/classes) | `OUT_METH_L` | `"#EC EMPTY_LINES_OUTSIDE"` | 📋 Planned | ⚡ Ready |
| **133** | `zcl_skylint_check_133` | Detect excessive consecutive empty lines (> 1 empty line) within method bodies | `IN_METH_L` | `"#EC EMPTY_LINES_INSIDE"` | 📋 Planned | ⚡ Ready |
| **134** | `zcl_skylint_check_134` | Standardize blank line structure within CDS test double class definitions | `CDS_TST_LN` | `"#EC CDS_TEST_EMPTY_LINES"` | 📋 Planned | ⚡ Ready |

---

### 🟦 Level 15: Code Alignment & Layout Formatting (135 - 150)
Columnar alignment of declarations, assignments, parameters, logical clauses, and SQL queries.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **135** | `zcl_skylint_check_135` | Align parameter descriptions and exception tags in ABAP Doc header blocks | `ALGN_ABDOC` | `"#EC ALIGN_ABAP_DOC"` | 📋 Planned | ⚡ Ready |
| **136** | `zcl_skylint_check_136` | Align consecutive `ALIASES ... FOR ...` interface component declarations | `ALGN_ALIAS` | `"#EC ALIGN_ALIASES"` | 📋 Planned | ⚡ Ready |
| **137** | `zcl_skylint_check_137` | Align consecutive assignments to components of the same target structure/object | `ALGN_ASSGN` | `"#EC ALIGN_ASSIGNMENTS"` | 📋 Planned | ⚡ Ready |
| **138** | `zcl_skylint_check_138` | Align variable lists across chained `CLEAR:`, `FREE:`, `SORT ... BY`, and `CATCH` blocks | `ALGN_CLRFR` | `"#EC ALIGN_CLEAR_FREE"` | 📋 Planned | ⚡ Ready |
| **139** | `zcl_skylint_check_139` | Align `WHEN ... THEN ... ELSE` branches in `COND #( ... )` and `SWITCH #( ... )` expressions | `ALGN_CONDS` | `"#EC ALIGN_COND_EXPR"` | 📋 Planned | ⚡ Ready |
| **140** | `zcl_skylint_check_140` | Align `TYPE`, `VALUE`, and `READ-ONLY` columns across consecutive `DATA`/`CONSTANTS` declarations | `ALGN_DECLS` | `"#EC ALIGN_DECLARATIONS"` | 📋 Planned | ⚡ Ready |
| **141** | `zcl_skylint_check_141` | Align multi-line Boolean logical expressions to visually reflect operator precedence | `ALGN_LOGEX` | `"#EC ALIGN_LOGICAL_EXPR"` | 📋 Planned | ⚡ Ready |
| **142** | `zcl_skylint_check_142` | Align parameter types and default values across `METHODS` and `CLASS-METHODS` declarations | `ALGN_METHD` | `"#EC ALIGN_METHODS"` | 📋 Planned | ⚡ Ready |
| **143** | `zcl_skylint_check_143` | Align consecutive `METHODS ... FOR TESTING` declarations in unit test includes | `ALGN_TSTMT` | `"#EC ALIGN_TEST_METHODS"` | 📋 Planned | ⚡ Ready |
| **144** | `zcl_skylint_check_144` | Align consecutive `METHODS ... [FINAL] REDEFINITION` declarations | `ALGN_REDEF` | `"#EC ALIGN_REDEFINITIONS"` | 📋 Planned | ⚡ Ready |
| **145** | `zcl_skylint_check_145` | Align parameter assignments in method invocations and constructor component expressions | `ALGN_PARAM` | `"#EC ALIGN_PARAMETERS"` | 📋 Planned | ⚡ Ready |
| **146** | `zcl_skylint_check_146` | Align main ABAP SQL query clauses (`SELECT`, `FROM`, `FIELDS`, `WHERE`, `GROUP BY`, `ORDER BY`) | `ALGN_SQLCL` | `"#EC ALIGN_SQL_CLAUSES"` | 📋 Planned | ⚡ Ready |
| **147** | `zcl_skylint_check_147` | Align SQL `FROM` clause data sources, `JOIN` types, and `ON` condition predicates | `ALGN_SQLFR` | `"#EC ALIGN_SQL_FROM"` | 📋 Planned | ⚡ Ready |
| **148** | `zcl_skylint_check_148` | Align projected field list items following `SELECT`, `FIELDS`, and `INTO ( ... )` | `ALGN_SQLLS` | `"#EC ALIGN_SQL_LISTS"` | 📋 Planned | ⚡ Ready |
| **149** | `zcl_skylint_check_149` | Align secondary keyword continuation lines with the second word of the initial statement | `ALGN_SECWD` | `"#EC ALIGN_SECOND_WORD"` | 📋 Planned | ⚡ Ready |
| **150** | `zcl_skylint_check_150` | Align parameters and interface definitions in legacy `FORM` / `PERFORM` subroutines | `ALGN_SUBRT` | `"#EC ALIGN_SUBROUTINES"` | 📋 Planned | ⚡ Ready |

---

### 🟫 Level 16: Core Data Services (CDS / DDL) Clean Architecture & Layout (151 - 173)
Comprehensive DDL / CDS view formatting, annotation layout, clause positioning, and join alignments.

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **151** | `zcl_skylint_check_151` | Standardize empty line spacing between major sections in CDS / DDL view definitions | `DDL_SEC_LN` | `"#EC DDL_EMPTY_SECTIONS"` | 📋 Planned | ⚡ Ready |
| **152** | `zcl_skylint_check_152` | Standardize empty line spacing within select and join sections of CDS views | `DDL_WIN_LN` | `"#EC DDL_EMPTY_WITHIN"` | 📋 Planned | ⚡ Ready |
| **153** | `zcl_skylint_check_153` | Enforce line breaks before `association` declarations in CDS view data sources | `DDL_BRK_AS` | `"#EC DDL_BREAK_ASSOC"` | 📋 Planned | ⚡ Ready |
| **154** | `zcl_skylint_check_154` | Enforce line break and indentation before opening curly braces `{` in CDS select lists | `DDL_BRK_BR` | `"#EC DDL_BREAK_BRACES"` | 📋 Planned | ⚡ Ready |
| **155** | `zcl_skylint_check_155` | Enforce line break before major CDS view clauses (`where`, `group by`, `having`, `union`) | `DDL_BRK_CL` | `"#EC DDL_BREAK_CLAUSES"` | 📋 Planned | ⚡ Ready |
| **156** | `zcl_skylint_check_156` | Standardize line break and position in `define view / custom entity` header statements | `DDL_POS_DF` | `"#EC DDL_POS_DEFINE"` | 📋 Planned | ⚡ Ready |
| **157** | `zcl_skylint_check_157` | Standardize line break and positioning before `join` keywords in CDS entity sources | `DDL_POS_JN` | `"#EC DDL_POS_JOIN"` | 📋 Planned | ⚡ Ready |
| **158** | `zcl_skylint_check_158` | Standardize line break and positioning of `select from` clause in CDS entities | `DDL_POS_SL` | `"#EC DDL_POS_SELECT"` | 📋 Planned | ⚡ Ready |
| **159** | `zcl_skylint_check_159` | Enforce CamelCase naming conventions for CDS entity and element identifier names | `DDL_CAMEL_` | `"#EC DDL_CAMEL_CASE"` | 📋 Planned | ⚡ Ready |
| **160** | `zcl_skylint_check_160` | Enforce consistent spacing around brackets `(`, `)`, `[`, `]` in CDS view definitions | `DDL_SPC_BR` | `"#EC DDL_SPACE_BRACKET"` | 📋 Planned | ⚡ Ready |
| **161** | `zcl_skylint_check_161` | Enforce consistent spacing around operators and symbols (`:`, `.`, `$`, `+`, `-`) in CDS | `DDL_SPC_SG` | `"#EC DDL_SPACE_SIGNS"` | 📋 Planned | ⚡ Ready |
| **162** | `zcl_skylint_check_162` | Detect frequent typos in CDS view comments and header documentation | `DDL_TYPO_C` | `"#EC DDL_TYPO_CHECK"` | 📋 Planned | ⚡ Ready |
| **163** | `zcl_skylint_check_163` | Standardize CDS annotation layout and multi-line formatting (`@EndUserText.label`, etc.) | `DDL_ANNO_L` | `"#EC DDL_ANNO_LAYOUT"` | 📋 Planned | ⚡ Ready |
| **164** | `zcl_skylint_check_164` | Rearrange and consolidate nested CDS annotations into hierarchical structure | `DDL_ANNO_N` | `"#EC DDL_ANNO_NESTING"` | 📋 Planned | ⚡ Ready |
| **165** | `zcl_skylint_check_165` | Align `join` and `association` aliases and `on` conditions in CDS data sources | `DDL_ALN_DS` | `"#EC DDL_ALIGN_SOURCES"` | 📋 Planned | ⚡ Ready |
| **166** | `zcl_skylint_check_166` | Align parameter declarations in CDS parameterized view definitions (`with parameters ...`) | `DDL_ALN_EP` | `"#EC DDL_ALIGN_PARAMS"` | 📋 Planned | ⚡ Ready |
| **167** | `zcl_skylint_check_167` | Align element name list and `group by` field lists in CDS view entities | `DDL_ALN_FL` | `"#EC DDL_ALIGN_FIELDS"` | 📋 Planned | ⚡ Ready |
| **168** | `zcl_skylint_check_168` | Align built-in SQL function parameters after arrow `=>` notation in CDS calculations | `DDL_ALN_FP` | `"#EC DDL_ALIGN_FUNC_PARAM"` | 📋 Planned | ⚡ Ready |
| **169** | `zcl_skylint_check_169` | Align complex multi-line logical conditions (`and`, `or`) in CDS `where` and `on` clauses | `DDL_ALN_LE` | `"#EC DDL_ALIGN_LOGIC"` | 📋 Planned | ⚡ Ready |
| **170** | `zcl_skylint_check_170` | Align key elements, non-key fields, and `as` aliases in CDS select projection list | `DDL_ALN_SL` | `"#EC DDL_ALIGN_SELECT"` | 📋 Planned | ⚡ Ready |
| **171** | `zcl_skylint_check_171` | Align parameterized data source input parameters in CDS view `from` clauses | `DDL_ALN_SP` | `"#EC DDL_ALIGN_SRC_PARAM"` | 📋 Planned | ⚡ Ready |
| **172** | `zcl_skylint_check_172` | Standardize CDS Cardinality specifications (`[1..1]`, `[0..*]`, `[1..*]`) for associations | `DDL_CARDIN` | `"#EC DDL_CARDINALITY"` | 📋 Planned | ⚡ Ready |
| **173** | `zcl_skylint_check_173` | Detect obsolete `DEFINE VIEW` syntax; enforce modern `DEFINE VIEW ENTITY` in ABAP Cloud CDS | `DDL_V_ENTI` | `"#EC DDL_VIEW_ENTITY"` | 📋 Planned | ⚡ Ready |

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
