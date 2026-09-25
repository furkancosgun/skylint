# ☁️ Skylint

> **Modern, Minimal & Cloud-Native ABAP Linter for SAP BTP & S/4HANA Public Cloud (ATC)**

**Skylint** is an extensible ABAP Test Cockpit (ATC) check framework tailored specifically for **ABAP Cloud** (Language Version 5 / Steampunk). It provides a clean, zero-boilerplate base architecture to easily author, test, and maintain custom Clean ABAP rules with native QuickFix support.

---

## ⚡ Highlights

- **ABAP Cloud Native:** Built upon standard SAP ATC Cloud interfaces (`if_ci_atc_check`, `if_ci_atc_source_code_provider`, `cl_ci_atc_assistant_factory`).
- **Zero Boilerplate Architecture:** Base class (`zcl_skylint_check_base`) encapsulates all lifecycle, procedural iteration, finding construction, and quickfix delegations. Subclasses only require `constructor` and `check`.
- **Stateless Static Engine:** High-performance local helpers (`lcl_reporter`, `lcl_quickfix`) handle location extraction, checksum generation, and pseudo-comment resolution without instance or casting overhead.
- **Enterprise Testing Workflow:** Follows the official SAP ATC testing standard (`cl_ci_atc_unit_driver`), executing checks against dedicated test dummy objects in `src/tests/`.
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
│   ├── checks/                                   # Numeric ATC Check Implementations
│   │   ├── zcl_skylint_check_001.clas.abap      # Check 001: Avoid TEST-SEAM
│   │   └── zcl_skylint_check_001.clas.testclasses.abap # ABAP Unit test (ATC driver)
│   │
│   └── tests/                                    # Target Test Objects for ATC Unit Tests
│       └── zcl_skylint_test_001.clas.abap       # Code fixtures for Check 001
│
├── mock/                                         # Open-ABAP ATC Test Driver & Asserter Mocks
│   ├── cl_ci_atc_unit_driver.clas.abap          # Native ATC driver factory mock
│   └── if_ci_atc_unit_asserter.intf.abap        # Standard ATC Asserter interface mock
│
├── abaplint.json                                 # abaplint configuration & rule sets
└── package.json                                  # Project scripts & tooling
```

---

## 📋 Rule Roadmap & Implementation Checklist (Easiest to Hardest)

The rules are systematically ordered by AST/parsing complexity. Each rule includes its designated numeric ID, category, description, and status.

### 🟢 Level 1: Beginner / Direct Pattern Matching (Keyword & Single Statement)
Direct single-statement keyword matching or simple token replacement with minimal index complexity.

- [x] **`001: Avoid TEST-SEAM`** - Detect `TEST-SEAM` statements; recommend ABAP OO Test Doubles / Interfaces.
- [x] **`002: Prefer lines( ) over DESCRIBE TABLE`** - Detect `DESCRIBE TABLE ... LINES ...`; suggest modern `lines( ... )`.
- [x] **`003: Avoid CALL METHOD`** - Detect legacy `CALL METHOD lo->meth( )`; suggest functional `lo->meth( )`.
- [x] **`004: Avoid DEFAULT KEY`** - Detect `WITH DEFAULT KEY` on internal tables; recommend `EMPTY KEY` or explicit keys.
- [x] **`005: Prefer IS NOT over NOT IS`** - Detect `NOT ... IS INITIAL` / `NOT ... IS BOUND`; suggest `IS NOT INITIAL` / `IS NOT BOUND`.
- [x] **`006: Avoid ME-> Self Reference`** - Detect unnecessary `me->` references when no ambiguity exists.
- [x] **`007: Omit EXPORTING in Calls`** - Detect explicit `EXPORTING` in single-parameter / functional method calls.
- [x] **`008: Avoid Assignment Chaining`** - Detect multiple assignment chains (`a = b = c = 0.`).
- [x] **`009: Avoid Chained Declarations`** - Detect legacy chained declarations (`DATA: a, b.`); promote discrete `DATA`.
- [x] **`010: Prefer String Templates over CONCATENATE`** - Detect legacy `CONCATENATE ... INTO ...`; suggest string templates `|...|`.

### 🟡 Level 2: Intermediate / Block Scope & Control Statements
Structure boundaries, control blocks (`IF`, `CASE`, `LOOP`, `TRY`), and condition evaluation.

- [ ] **`011: Avoid Boolean Comparison`** - Detect `IF bool = abap_true` / `IF bool = 'X'`; promote direct `IF bool`.
- [ ] **`012: Prefer line_exists( ) over READ TABLE NO FIELDS`** - Detect `READ TABLE ... TRANSPORTING NO FIELDS`; suggest `line_exists( ... )`.
- [ ] **`013: EXIT Outside Loop -> Prefer RETURN`** - Detect `EXIT` statements in procedures outside loop constructs; suggest `RETURN`.
- [ ] **`014: Avoid CHECK in Iterations`** - Detect `CHECK` inside `LOOP` / `DO` / `WHILE`; promote explicit `IF ... CONTINUE`.
- [ ] **`015: Constant-Only Interfaces`** - Detect interfaces containing only `CONSTANTS`; suggest global classes or domain types.
- [ ] **`016: Empty Control Blocks`** - Detect empty `IF`, `CASE`, `LOOP`, `TRY` statement bodies.
- [ ] **`017: Empty CATCH Block`** - Detect empty `CATCH` blocks swallowing exceptions without logging or re-raising.
- [ ] **`018: Missing Assert in Test Class`** - Detect AUnit test methods missing any `cl_abap_unit_assert` verification.
- [ ] **`019: Identical Conditions in IF/CASE`** - Detect duplicate branch conditions in `IF ... ELSEIF` or `CASE ... WHEN`.
- [ ] **`020: Nested IF Simplification`** - Detect consecutive nested single-line `IF` blocks that can be merged with `AND`.

### 🔴 Level 3: Advanced / Data Flow, Security & Lifecycle
Cross-statement flow, data access boundaries, exception propagation, and signature sizing.

- [ ] **`021: DB Access Inside Loops`** - Detect SQL queries (`SELECT`, `MODIFY`, `INSERT`, `DELETE`) within loop iterations.
- [ ] **`022: Avoid DB Access in Unit Tests`** - Detect direct database table access inside AUnit test methods (`FOR TESTING`).
- [ ] **`023: Lost Previous Exception in CATCH`** - Detect re-raised exceptions missing `PREVIOUS = lx_exc` parameter.
- [ ] **`024: Scope of Variable (Variable Leaking)`** - Detect variables declared in inner blocks referenced outside their intended scope.
- [ ] **`025: Method Signature Cleanliness`** - Detect excessive parameter signatures (> 8 parameters); suggest structure or object parameters.

---

---

## 🚀 How to Create a New Check

Writing a new rule in Skylint is as simple as creating a subclass of `zcl_skylint_check_base`.

### Step 1: Define the Check Class (`src/checks/zcl_skylint_check_002.clas.abap`)

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

### Step 2: Create a Test Fixture (`src/tests/zcl_skylint_test_002.clas.abap`)

Create an ABAP class that includes code examples for both non-compliant code and pseudo-comment suppressed code:

```abap
CLASS zcl_skylint_test_002 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
ENDCLASS.

CLASS zcl_skylint_test_002 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    CHECK 1 = 2.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    CHECK 1 = 2. "#EC PREFER_IS_NOT
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
        expected_findings = VALUE #( code = zcl_skylint_check_002=>c_finding_codes-prefer_is_not
                                     ( location = ls_loc_without_pc )
                                     ( location = ls_loc_with_pc ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
```

---

## 🛠️ Available APIs for Check Subclasses

Inheriting from `zcl_skylint_check_base` gives you instant access to:

| Method | Description |
|---|---|
| `report_statement( is_statement, iv_finding_code, ... )` | Reports an ATC finding for a whole statement with auto location, checksum & pseudo comment check. |
| `report_token( is_token, is_statement, iv_finding_code, ... )` | Reports an ATC finding specifically highlighting a token position. |
| `report_finding( is_finding )` | Directly appends a custom `if_ci_atc_check=>ty_finding` structure. |
| `get_attribute( iv_name, IMPORTING ev_value )` | Safely dereferences and retrieves dynamic ATC check attributes. |
| `quickfix_replace( ... )` | Constructs a QuickFix context and generates replacement code. |
| `quickfix_insert_before( ... )` | Inserts new statements before the specified statement index. |
| `quickfix_insert_after( ... )` | Inserts new statements after the specified statement index. |
| `quickfix_delete( ... )` | Generates a quickfix to delete a statement. |

---

## 🧪 Development & CI

```bash
# Install dependencies
npm install

# Run abaplint validation across repository
npm test

# Auto-fix fixable formatting/style issues
npm run fix
```

---

## 📦 Deployment via abapGit

1. Clone or import this repository in your SAP BTP ABAP Environment or S/4HANA Cloud system using **abapGit**.
2. Activate all objects.
3. Configure the check classes in your ATC Check Variant (`transaction ATC` or ADT).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
