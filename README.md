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
│   ├── checks/                                   # 79 Modular Check Implementations (001 - 079)
│   │   ├── zcl_skylint_check_001.clas.abap       # Check class implementation
│   │   └── zcl_skylint_check_001.clas.xml        # abapGit XML metadata
│   └── deps/atc/src/                             # Local-only ATC framework stubs (never shipped)
├── test/                                         # ATC-native JS test runner & doubles
│   ├── run.mjs                                   # Main test runner (executes checks via transpiled runtime)
│   ├── roundtrip.mjs                             # QuickFix round-trip syntax validator
│   └── ...                                       # AST enricher, RTTI feed, fakes
├── tests/fixtures/                               # Test fixtures per check (source.abap + expected.json)
├── abaplint.json                                 # abaplint validation configuration & rule sets
└── package.json                                  # Lint, build, and test scripts
```

---

## 📋 Clean ABAP & Cloud Rule Catalog (79 Rules)

All Clean ABAP, security, and cloud-native rules implemented in Skylint:

| ID | Rule Name & Class | Description | Finding Code | Pseudo-Comment | Status | QuickFix |
|:---:|---|---|:---:|:---:|:---:|:---:|
| **001** | [zcl_skylint_check_001](src/checks/zcl_skylint_check_001.clas.abap) | Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES | `DESCRIBELN` | `—` | ✅ Done | ⚡ Ready |
| **002** | [zcl_skylint_check_002](src/checks/zcl_skylint_check_002.clas.abap) | Avoid static CALL METHOD statements | `CALLMETHOD` | `—` | ✅ Done | ⚡ Ready |
| **003** | [zcl_skylint_check_003](src/checks/zcl_skylint_check_003.clas.abap) | Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys | `DEFAULTKEY` | `—` | ✅ Done | — |
| **004** | [zcl_skylint_check_004](src/checks/zcl_skylint_check_004.clas.abap) | Prefer IS NOT over NOT ... IS | `PREFERISNT` | `—` | ✅ Done | ⚡ Ready |
| **005** | [zcl_skylint_check_005](src/checks/zcl_skylint_check_005.clas.abap) | Avoid self-reference ME-> | `AVOIDME` | `—` | ✅ Done | — |
| **006** | [zcl_skylint_check_006](src/checks/zcl_skylint_check_006.clas.abap) | Omit explicit EXPORTING in method calls | `OMITEXPORT` | `—` | ✅ Done | ⚡ Ready |
| **007** | [zcl_skylint_check_007](src/checks/zcl_skylint_check_007.clas.abap) | Avoid assignment chaining (a = b = c) | `ASSIGNCHN` | `—` | ✅ Done | ⚡ Ready |
| **008** | [zcl_skylint_check_008](src/checks/zcl_skylint_check_008.clas.abap) | Avoid chained declarations (DATA:, TYPES:, etc.) | `CHAINDECL` | `—` | ✅ Done | ⚡ Ready |
| **009** | [zcl_skylint_check_009](src/checks/zcl_skylint_check_009.clas.abap) | Prefer string templates over CONCATENATE | `CONCATSTR` | `—` | ✅ Done | ⚡ Ready |
| **010** | [zcl_skylint_check_010](src/checks/zcl_skylint_check_010.clas.abap) | Avoid comparing boolean method calls to boolean literals | `BOOLCOMP` | `—` | ✅ Done | ⚡ Ready |
| **011** | [zcl_skylint_check_011](src/checks/zcl_skylint_check_011.clas.abap) | Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS | `PREFLINEX` | `—` | ✅ Done | — |
| **012** | [zcl_skylint_check_012](src/checks/zcl_skylint_check_012.clas.abap) | Prefer RETURN over EXIT outside loop constructs | `EXITOUTLP` | `—` | ✅ Done | ⚡ Ready |
| **013** | [zcl_skylint_check_013](src/checks/zcl_skylint_check_013.clas.abap) | Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE) | `CHKINLOOP` | `—` | ✅ Done | ⚡ Ready |
| **014** | [zcl_skylint_check_014](src/checks/zcl_skylint_check_014.clas.abap) | Detect empty control blocks (IF, CASE, LOOP, TRY, etc.) | `EMPTYCTRL` | `—` | ✅ Done | — |
| **015** | [zcl_skylint_check_015](src/checks/zcl_skylint_check_015.clas.abap) | Detect empty CATCH blocks swallowing exceptions | `EMPTYCATCH` | `"#EC NO_HANDLER"` | ✅ Done | — |
| **016** | [zcl_skylint_check_016](src/checks/zcl_skylint_check_016.clas.abap) | Detect identical branch conditions in IF/ELSEIF and CASE/WHEN | `DUPCOND` | `—` | ✅ Done | — |
| **017** | [zcl_skylint_check_017](src/checks/zcl_skylint_check_017.clas.abap) | Detect consecutive nested IF blocks that can be merged with AND | `NESTEDIF` | `—` | ✅ Done | — |
| **018** | [zcl_skylint_check_018](src/checks/zcl_skylint_check_018.clas.abap) | Detect unreachable code following unconditional jump statements | `UNREACHCD` | `—` | ✅ Done | ⚡ Ready |
| **019** | [zcl_skylint_check_019](src/checks/zcl_skylint_check_019.clas.abap) | Avoid short CASE constructs with only one WHEN branch; prefer IF | `SHORTCASE` | `—` | ✅ Done | — |
| **020** | [zcl_skylint_check_020](src/checks/zcl_skylint_check_020.clas.abap) | Avoid Yoda conditions in comparison expressions | `YODACOND` | `—` | ✅ Done | ⚡ Ready |
| **021** | [zcl_skylint_check_021](src/checks/zcl_skylint_check_021.clas.abap) | Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords | `PREFEROP` | `—` | ✅ Done | ⚡ Ready |
| **022** | [zcl_skylint_check_022](src/checks/zcl_skylint_check_022.clas.abap) | Prefer NEW #( ) constructor expression over legacy CREATE OBJECT | `PREFERNEW` | `—` | ✅ Done | ⚡ Ready |
| **023** | [zcl_skylint_check_023](src/checks/zcl_skylint_check_023.clas.abap) | Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE | `RAISEEXCNE` | `—` | ✅ Done | ⚡ Ready |
| **024** | [zcl_skylint_check_024](src/checks/zcl_skylint_check_024.clas.abap) | Prefer xsdbool( ) expression over manual IF-ELSE assignment | `PREFERXSDB` | `—` | ✅ Done | ⚡ Ready |
| **025** | [zcl_skylint_check_025](src/checks/zcl_skylint_check_025.clas.abap) | Omit RECEIVING in method calls | `OMITRECEIV` | `—` | ✅ Done | ⚡ Ready |
| **026** | [zcl_skylint_check_026](src/checks/zcl_skylint_check_026.clas.abap) | Avoid calling static methods via instance arrow (->) | `STATICVIAI` | `—` | ✅ Done | ⚡ Ready |
| **027** | [zcl_skylint_check_027](src/checks/zcl_skylint_check_027.clas.abap) | Avoid mutable public attributes in classes | `NOPUBATTR` | `—` | ✅ Done | — |
| **028** | [zcl_skylint_check_028](src/checks/zcl_skylint_check_028.clas.abap) | Avoid obsolete statements (MOVE, REFRESH, etc.) | `OBSOLETE` | `—` | ✅ Done | ⚡ Ready |
| **029** | [zcl_skylint_check_029](src/checks/zcl_skylint_check_029.clas.abap) | Method signature cleanliness (excessive parameter count) | `PARAMCOUNT` | `—` | ✅ Done | — |
| **030** | [zcl_skylint_check_030](src/checks/zcl_skylint_check_030.clas.abap) | Avoid database access inside loop iterations | `DBINLOOP` | `—` | ✅ Done | — |
| **031** | [zcl_skylint_check_031](src/checks/zcl_skylint_check_031.clas.abap) | Unsecure FOR ALL ENTRIES (Missing empty itab check) | `FAENOCHECK` | `—` | ✅ Done | ⚡ Ready |
| **032** | [zcl_skylint_check_032](src/checks/zcl_skylint_check_032.clas.abap) | Select performance (Avoid SELECT * and SELECT ... ENDSELECT) | `SELECTSTAR` | `—` | ✅ Done | — |
| **033** | [zcl_skylint_check_033](src/checks/zcl_skylint_check_033.clas.abap) | Scope of variable (avoid variable leaking outside control blocks) | `SCOPELEAK` | `—` | ✅ Done | — |
| **034** | [zcl_skylint_check_034](src/checks/zcl_skylint_check_034.clas.abap) | Detect Identical Self Assignments | `IDENTMOVE` | `—` | ✅ Done | ⚡ Ready |
| **035** | [zcl_skylint_check_035](src/checks/zcl_skylint_check_035.clas.abap) | Enforce fully typed constant declarations | `FULLYTYPED` | `—` | ✅ Done | — |
| **036** | [zcl_skylint_check_036](src/checks/zcl_skylint_check_036.clas.abap) | Omit parameter name in single parameter method call | `OMITPARM` | `—` | ✅ Done | ⚡ Ready |
| **037** | [zcl_skylint_check_037](src/checks/zcl_skylint_check_037.clas.abap) | Detect TRY without CATCH | `TRYWITHOUT` | `—` | ✅ Done | — |
| **038** | [zcl_skylint_check_038](src/checks/zcl_skylint_check_038.clas.abap) | Prefer CORRESPONDING Expression over MOVE-CORRESPONDING | `PREFER_COR` | `—` | ✅ Done | ⚡ Ready |
| **039** | [zcl_skylint_check_039](src/checks/zcl_skylint_check_039.clas.abap) | Method Length Limit (excessive statement count) | `METHOD_LEN` | `—` | ✅ Done | — |
| **040** | [zcl_skylint_check_040](src/checks/zcl_skylint_check_040.clas.abap) | Nesting Depth Limit (excessive control block nesting) | `NESTING_DP` | `—` | ✅ Done | — |
| **041** | [zcl_skylint_check_041](src/checks/zcl_skylint_check_041.clas.abap) | Avoid sy-* System Variable Modification | `SYS_VAR_MD` | `—` | ✅ Done | — |
| **042** | [zcl_skylint_check_042](src/checks/zcl_skylint_check_042.clas.abap) | Prefer RETURNING over single EXPORTING | `PREFER_RET` | `—` | ✅ Done | — |
| **043** | [zcl_skylint_check_043](src/checks/zcl_skylint_check_043.clas.abap) | Prefer Class-Based Exceptions over Classic EXCEPTIONS | `CLASS_EXC` | `—` | ✅ Done | — |
| **044** | [zcl_skylint_check_044](src/checks/zcl_skylint_check_044.clas.abap) | Dangerous / Unmanaged Dynamic Statements | `DANGER_STM` | `—` | ✅ Done | — |
| **045** | [zcl_skylint_check_045](src/checks/zcl_skylint_check_045.clas.abap) | Call Transaction Authority Check | `AUTH_CHECK` | `—` | ✅ Done | ⚡ Ready |
| **046** | [zcl_skylint_check_046](src/checks/zcl_skylint_check_046.clas.abap) | SELECT UP TO 1 ROWS requires ORDER BY | `SELECT_UP` | `—` | ✅ Done | — |
| **047** | [zcl_skylint_check_047](src/checks/zcl_skylint_check_047.clas.abap) | Cyclomatic Complexity Threshold | `CYCLO_COMP` | `—` | ✅ Done | — |
| **048** | [zcl_skylint_check_048](src/checks/zcl_skylint_check_048.clas.abap) | Prefer FINAL Classes by Default | `NOT_FINAL` | `—` | ✅ Done | — |
| **049** | [zcl_skylint_check_049](src/checks/zcl_skylint_check_049.clas.abap) | Avoid RAISE SHORTDUMP (prefer graceful exceptions) | `SHORTDUMP` | `—` | ✅ Done | — |
| **050** | [zcl_skylint_check_050](src/checks/zcl_skylint_check_050.clas.abap) | Avoid magic numbers in code; use named constants | `MAGIC_NUM` | `—` | ✅ Done | — |
| **051** | [zcl_skylint_check_051](src/checks/zcl_skylint_check_051.clas.abap) | Prefer INSERT ... INTO TABLE over APPEND for table safety | `PREF_INSRT` | `—` | ✅ Done | ⚡ Ready |
| **052** | [zcl_skylint_check_052](src/checks/zcl_skylint_check_052.clas.abap) | Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP | `OBS_L_CTRL` | `—` | ✅ Done | — |
| **053** | [zcl_skylint_check_053](src/checks/zcl_skylint_check_053.clas.abap) | Avoid LIKE referencing data objects; use explicit TYPE | `AVOID_LIKE` | `—` | ✅ Done | — |
| **054** | [zcl_skylint_check_054](src/checks/zcl_skylint_check_054.clas.abap) | Keep constructors clean; avoid heavy business logic/loops/DB access | `CTOR_LOGIC` | `—` | ✅ Done | — |
| **055** | [zcl_skylint_check_055](src/checks/zcl_skylint_check_055.clas.abap) | Avoid static-only classes; prefer instantiable interface-based design | `STAT_CLASS` | `—` | ✅ Done | — |
| **056** | [zcl_skylint_check_056](src/checks/zcl_skylint_check_056.clas.abap) | Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods | `BOOL_NAME` | `—` | ✅ Done | — |
| **057** | [zcl_skylint_check_057](src/checks/zcl_skylint_check_057.clas.abap) | Avoid deep class inheritance hierarchies | `DEEP_INHRT` | `—` | ✅ Done | — |
| **058** | [zcl_skylint_check_058](src/checks/zcl_skylint_check_058.clas.abap) | Limit number of member attributes in a class (God Class smell) | `ATTR_COUNT` | `—` | ✅ Done | — |
| **059** | [zcl_skylint_check_059](src/checks/zcl_skylint_check_059.clas.abap) | Avoid mutable DATA declarations in interfaces; allow only CONSTANTS | `INTF_DATA` | `—` | ✅ Done | — |
| **060** | [zcl_skylint_check_060](src/checks/zcl_skylint_check_060.clas.abap) | Avoid generic CATCH cx_root; catch specific exception classes | `CATCH_ROOT` | `—` | ✅ Done | — |
| **061** | [zcl_skylint_check_061](src/checks/zcl_skylint_check_061.clas.abap) | Avoid obsolete MESSAGE ... RAISING; use class-based exceptions | `MSG_RAISE` | `—` | ✅ Done | — |
| **062** | [zcl_skylint_check_062](src/checks/zcl_skylint_check_062.clas.abap) | Avoid nested TRY blocks; extract inner error handling to helper methods | `NESTED_TRY` | `—` | ✅ Done | — |
| **063** | [zcl_skylint_check_063](src/checks/zcl_skylint_check_063.clas.abap) | Avoid raising SAP internal system exceptions (cx_sy_*) | `RAISE_SYS` | `—` | ✅ Done | — |
| **064** | [zcl_skylint_check_064](src/checks/zcl_skylint_check_064.clas.abap) | Check sy-subrc after DB, table and string operations | `CHECKSUBRC` | `—` | ✅ Done | — |
| **065** | [zcl_skylint_check_065](src/checks/zcl_skylint_check_065.clas.abap) | Avoid obsolete FORM routines; use modern methods in ABAP Cloud | `AVOID_FORM` | `—` | ✅ Done | — |
| **066** | [zcl_skylint_check_066](src/checks/zcl_skylint_check_066.clas.abap) | Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL | `CLIENT_SPE` | `—` | ✅ Done | ⚡ Ready |
| **067** | [zcl_skylint_check_067](src/checks/zcl_skylint_check_067.clas.abap) | Avoid COMMIT WORK / ROLLBACK WORK in behavior implementations | `NO_COMMIT` | `—` | ✅ Done | — |
| **068** | [zcl_skylint_check_068](src/checks/zcl_skylint_check_068.clas.abap) | Avoid full-line MODIFY itab inside LOOP without TRANSPORTING clause | `FULL_MODIF` | `—` | ✅ Done | — |
| **069** | [zcl_skylint_check_069](src/checks/zcl_skylint_check_069.clas.abap) | Enforce test method naming convention (TEST_, SHOULD_) in AUnit | `TEST_NAME` | `—` | ✅ Done | — |
| **070** | [zcl_skylint_check_070](src/checks/zcl_skylint_check_070.clas.abap) | Avoid dynamic SQL table or clause names without sanitization | `DYN_SQL` | `—` | ✅ Done | — |
| **071** | [zcl_skylint_check_071](src/checks/zcl_skylint_check_071.clas.abap) | Prefer marking non-overridden methods as FINAL | `PREF_FINAL` | `—` | ✅ Done | ⚡ Ready |
| **072** | [zcl_skylint_check_072](src/checks/zcl_skylint_check_072.clas.abap) | Detect obsolete string statements; prefer built-in functions | `CONDENSE_S` | `—` | ✅ Done | ⚡ Ready |
| **073** | [zcl_skylint_check_073](src/checks/zcl_skylint_check_073.clas.abap) | Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1 | `CALC_ASSGN` | `—` | ✅ Done | ⚡ Ready |
| **074** | [zcl_skylint_check_074](src/checks/zcl_skylint_check_074.clas.abap) | Use early CONTINUE guard clause instead of wrapping loop in IF block | `GUARD_LOOP` | `—` | ✅ Done | — |
| **075** | [zcl_skylint_check_075](src/checks/zcl_skylint_check_075.clas.abap) | Use early RETURN guard clause instead of wrapping method in IF block | `GUARD_METH` | `—` | ✅ Done | — |
| **076** | [zcl_skylint_check_076](src/checks/zcl_skylint_check_076.clas.abap) | Detect native ASSERT in production code; use exceptions instead | `PROD_ASSRT` | `—` | ✅ Done | — |
| **077** | [zcl_skylint_check_077](src/checks/zcl_skylint_check_077.clas.abap) | Detect unused local variables and field symbols | `UNUSED_VAR` | `"#EC NEEDED"` | ✅ Done | — |
| **078** | [zcl_skylint_check_078](src/checks/zcl_skylint_check_078.clas.abap) | Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS) | `DECL_ORDER` | `—` | ✅ Done | — |
| **079** | [zcl_skylint_check_079](src/checks/zcl_skylint_check_079.clas.abap) | Detect unnecessary exclamation mark parameter escape (!iv_param) | `PARAM_ESCP` | `—` | ✅ Done | ⚡ Ready |

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

### Step 2: Add Test Fixtures (`tests/fixtures/check_002/`)

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

" 3. Verify findings via the fixture (`tests/fixtures/check_002/expected.json`).
```

---

## 🛠️ Available Base APIs (`zcl_skylint_check_base`)

| Method | Description |
|---|---|
| `report_statement( is_statement, iv_finding_code, is_quickfix )` | Reports a finding for a statement with auto checksum/location and pseudo-comment suppression. |
| `report_token( is_token, is_statement, iv_finding_code, is_quickfix )` | Reports a finding pinpointing a specific token column. |
| `get_attribute( iv_name, IMPORTING ev_value )` | Safely dereferences and retrieves dynamic check configuration attributes. |
| `quickfix_replace( iv_quickfix_code, iv_statement_from, it_new_code, ... )` | Constructs a standardized QuickFix replacement descriptor. |

---

## 🏛️ Architecture

Single-branch, ATC-native delivery — no adapters, no platform branches:

```
           ┌──────────────────────────────────────────────┐
           │              main (ATC-Native)               │
           │  • 79 Rules (if_ci_atc_check)               │
           │  • Framework Types (if_ci_atc_*)            │
           │  • Shared Base + Metadata (core/)           │
           └──────────────────────────────────────────────┘
```

1. **`src/core/`**: `zcl_skylint_check_base` (implements `if_ci_atc_check`: procedure loop, checksum/location, quickfix contexts), `zcl_skylint_check_meta_data` (shared `if_ci_atc_check_meta_data`), AST/RTTI utilities.
2. **`src/checks/`**: 79 rule classes, each directly selectable in ATC check variants.
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
node test/run.mjs 001

# Re-index check rules and synchronize the rule catalog
npm run index
```

> **Testing Architecture:** The test harness (`test/run.mjs`) is ATC-native. Fixtures are parsed into `ty_procedure` values and run through the actual transpiled `if_ci_atc_check~run` methods using JS test doubles for the SAP boundary. Every registered QuickFix is re-parsed via `@abaplint/core` (`test/roundtrip.mjs`) to verify syntax validity.

---

## 📦 Deployment via abapGit

1. Clone **`main`** via **abapGit** in your BTP ABAP Environment or S/4HANA system.
2. Activate all objects and add the check classes (`ZCL_SKYLINT_CHECK_*`) to your ATC Check Variant.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

