# 🤖 Skylint Agent Development Guidelines & Standards (`AGENTS.md`)

This document outlines the mandatory engineering guidelines, architectural design patterns, Clean ABAP standards, and testing workflows for any AI agent or contributor developing check rules in **Skylint**.

---

## 🏛️ Core Philosophy & Architecture

1. **ABAP Cloud Native (Language Version 5 / Steampunk / BTP):**
   - All check rules implement standard SAP ATC Cloud interfaces via our zero-boilerplate base class `zcl_skylint_check_base`.
   - Do not use obsolete classic SAP NetWeaver statements or tables.

2. **Inheritance & Separation of Concerns:**
   - Every ATC check rule **MUST** be implemented in its own isolated class named `zcl_skylint_check_XXX`.
   - Subclasses only need to implement:
     - `constructor`: Metadata configuration (description, finding codes, pseudo-comments, and attributes).
     - `check( is_procedure )`: Procedure inspection logic.
   - All finding reporting, location calculation, checksum generation, and pseudo-comment filtering are delegated to `zcl_skylint_check_base` helpers (`lcl_reporter`, `lcl_quickfix`).

3. **Code Pal for ABAP & Robust Parsing (Minimum Magic Index Coupling):**
   - **Avoid magic token index assumptions** (e.g. do not assume `tokens[ 4 ]` is always the target identifier; syntax can contain extra spaces, comments, pragmas, or modifiers).
   - Use token stream traversal, lexeme matching, pattern comparisons (`CP`), keyword filters (`WHERE keyword = ...`), and depth tracking (`(`, `[`, `{`).
   - Treat dynamic expressions, table expressions, and complex constructors safely without hard crashes.

---

## 📐 Clean ABAP & Code Style Rules

All ABAP code in `src/` **MUST** strictly pass `abaplint` validation with **0 warnings / 0 errors**:

1. **No Inline Declarations:**
   - **FORBIDDEN:** `DATA(lv_var) = ...` or `ASSIGN ... TO FIELD-SYMBOL(<fs>)`.
   - **REQUIRED:** Explicit `DATA` and `FIELD-SYMBOLS` declarations at the top of the method implementation.

2. **Variable Naming Conventions:**
   - Local data: `lv_*` (e.g., `lv_lexeme`, `lv_count`).
   - Local structures: `ls_*` (e.g., `ls_statement`, `ls_token`).
   - Local internal tables: `lt_*` (e.g., `lt_tokens`, `lt_procedures`).
   - Field symbols: `<ls_*>`, `<lv_*>`.
   - Member attributes: `mv_*`, `mt_*`, `mo_*`.
   - Constants: `c_*` or structured constants `BEGIN OF c_finding_codes ... END OF c_finding_codes`.

3. **Control Structure Hygiene:**
   - **No `if_in_if`:** Combine nested conditionals using `IF cond1 AND cond2.` instead of nesting `IF` within `IF`.
   - **Use `CASE` for Multi-Branch Keyword Dispatches:** Satisfy `change_if_to_case`.
   - **No Trailing Dots / Formatting Errors:** Keep line lengths under 120 characters, align `TYPE` expressions to the same column, and use uppercase ABAP keywords.

---

## 🛠️ Anatomy of an ATC Check Rule

Each check consists of exactly 5 files:

```text
src/
├── checks/
│   ├── zcl_skylint_check_XXX.clas.abap         # 1. Main check implementation
│   ├── zcl_skylint_check_XXX.clas.xml          # 2. abapGit XML (MUST include <WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>)
│   └── zcl_skylint_check_XXX.clas.testclasses.abap # 3. ABAP Unit test execution
└── tests/
    ├── zcl_skylint_test_XXX.clas.abap          # 4. Target test fixture object
    └── zcl_skylint_test_XXX.clas.xml           # 5. abapGit XML for test fixture
```

### 1. Main Check Implementation Pattern

```abap
CLASS zcl_skylint_check_XXX DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        my_finding_code TYPE if_ci_atc_check=>ty_finding_code VALUE 'FINDINGCD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MY_RULE_SUPPRESSION'.

    " Configurable ATC Attributes
    DATA mv_custom_option TYPE abap_bool VALUE abap_false.

ENDCLASS.


CLASS zcl_skylint_check_XXX IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detailed rule description'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-my_finding_code
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Clear finding message explaining why and how to fix'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'CUSTOM_OPTION'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                       value = REF #( mv_custom_option ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_custom_opt TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'CUSTOM_OPTION'
                   IMPORTING ev_value = lv_custom_opt ).

    IF lv_custom_opt IS INITIAL.
      lv_custom_opt = mv_custom_option.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'TARGET_KEYWORD'.
      " Inspection logic
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-my_finding_code ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

### 2. Main Check XML (`src/checks/zcl_skylint_check_XXX.clas.xml`)
Always ensure `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` is present when `.clas.testclasses.abap` exists:

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>ZCL_SKYLINT_CHECK_XXX</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>skylint: Rule Description (XXX)</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
    <WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### 3. Test Fixture Object (`src/tests/zcl_skylint_test_XXX.clas.abap`)
Every test fixture must contain:
1. `without_pseudo_comments`: Non-compliant statements that trigger findings.
2. `with_pseudo_comments`: Non-compliant statements suppressed with `"#EC <PSEUDO_COMMENT>"`.
3. `valid_code` / `dynamic_calls`: Compliant and edge-case code that must NOT trigger findings.

```abap
CLASS zcl_skylint_test_XXX DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_XXX IMPLEMENTATION.
  METHOD without_pseudo_comments.
    " Non-compliant code
  ENDMETHOD.

  METHOD with_pseudo_comments.
    " Non-compliant code "#EC MY_RULE_SUPPRESSION
  ENDMETHOD.

  METHOD valid_code.
    " Compliant clean ABAP code
  ENDMETHOD.
ENDCLASS.
```

### 4. Unit Test Class (`src/checks/zcl_skylint_check_XXX.clas.testclasses.abap`)
Test execution utilizes `cl_ci_atc_unit_driver` to assert expected finding locations:

```abap
CLASS ltcl_check_XXX DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZCL_SKYLINT_TEST_XXX'.
    CONSTANTS:
      BEGIN OF c_methods,
        without_pseudo_comments TYPE c LENGTH 30 VALUE 'WITHOUT_PSEUDO_COMMENTS',
        with_pseudo_comments    TYPE c LENGTH 30 VALUE 'WITH_PSEUDO_COMMENTS',
      END OF c_methods.

    METHODS execute_test_class FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_XXX IMPLEMENTATION.
  METHOD execute_test_class.
    DATA ls_loc_no_pc TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_with_pc TYPE if_ci_atc_check=>ty_location.

    ls_loc_no_pc = VALUE #(
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
        check             = NEW zcl_skylint_check_XXX( )
        object            = VALUE #( type = 'CLAS' name = c_test_class )
        expected_findings = VALUE #( ( code     = zcl_skylint_check_XXX=>c_finding_codes-my_finding_code
                                       location = ls_loc_no_pc )
                                     ( code     = zcl_skylint_check_XXX=>c_finding_codes-my_finding_code
                                       location = ls_loc_with_pc ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
```

---

## 🧪 Verification & CI Cycle

After creating or modifying any check, **ALWAYS** run the full test and linter suite:

```bash
# Run both abaplint and open-abap transpiler AUnit tests
npm test
```

### Success Criteria:
1. `npm run unit` passes with all check test classes running and succeeding (`Exit code 0`).
2. `npm run lint` reports `0 issue(s) found`.
3. Update [README.md](file:///Users/furkancosgun/Downloads/skylint/README.md) roadmap checklist by marking the implemented check with `[x]`.
