# 🤖 Skylint Agent Development Guidelines & Standards (`AGENTS.md`)

This document outlines the mandatory engineering guidelines, architectural design patterns, Clean ABAP standards, testing workflows, and parser internals for any AI agent or contributor developing check rules in **Skylint**.

---

## 🏛️ Core Philosophy & Architecture

1. **ABAP Cloud Native (Language Version 5 / Steampunk / BTP):**
   - All check rules implement standard SAP ATC Cloud interfaces via our zero-boilerplate base class `zcl_skylint_check_base`.
   - Obsolete classic SAP NetWeaver statements, obsolete tables, and legacy Code Inspector APIs (`CL_CI_TEST_ABAP_COMP_PROCS`) are strictly forbidden.

2. **Reference Architecture: Code Pal for ABAP Cloud (`code-pal-for-cloud`):**
   - **Skylint** follows the design principles and best practices of SAP's official **Code Pal for ABAP Cloud** (`code-pal-for-cloud`).
   - Prioritize semantic information provided by the compiler over brittle textual heuristics.
   - Delegate finding creation, location mapping, checksum calculation, and quickfix generation to framework helpers.

3. **Mandatory Use of `IF_CI_ATC_SOURCE_CODE_PROVIDER`:**
   - `if_ci_atc_source_code_provider` is the single source of truth for source code representation (statements, procedures, tokens, and compiler references).
   - All types, structures, and enumerations for AST analysis **MUST** reference `if_ci_atc_source_code_provider`.

4. **Inheritance & Separation of Concerns:**
   - Every ATC check rule **MUST** be implemented in its own isolated class named `zcl_skylint_check_XXX`.
   - Subclasses only need to implement:
     - `constructor`: Metadata configuration (description, finding codes, pseudo-comments, and attributes).
     - `check( is_procedure )`: Procedure inspection logic.
   - All finding reporting, location calculation, checksum generation, and pseudo-comment filtering are delegated to `zcl_skylint_check_base` helpers (`lcl_reporter`, `lcl_quickfix`).

---

## ⚙️ How the ATC Code Provider & Parser Works (`cl_ci_atc_unit_driver.clas.locals_imp`)

Understanding how the ATC source code provider parses and normalizes code is essential for writing accurate rules without false positives or redundant logic.

### 1. Chain Statement Normalization (No Chains in AST)
In ABAP source code, developers frequently write chained statements:
```abap
DATA: lv_a TYPE i,
      lv_b TYPE string.
```
In the ATC AST, **chains do not exist**:
- The driver detects `,` separators, buffers the chain header token (`DATA`), and automatically prepends it to each subsequent statement.
- The statements delivered to your check method are completely unrolled and normalized:
  1. `DATA lv_a TYPE i.`
  2. `DATA lv_b TYPE string.`
- **Agent Rule:** Never write check rules looking for colons `:` or chained commas `,`. Every statement is delivered as an independent, fully qualified statement.

### 2. Implicit Assignments Become `COMPUTE`
Modern ABAP assignments like `lv_val = 10.` or `ls_data-field = 'X'.` do not have an explicit keyword in the text.
- The parser tracks delimiter depth (`(`, `[`, `{`). If an unnested `=` assignment operator is found at top level (`lv_paren_depth = 0`), the statement's `keyword` is set to **`COMPUTE`**.
- **Agent Rule:** To inspect value assignments, computations, or constructor expressions assigned to a variable, filter directly by:
  ```abap
  LOOP AT is_procedure-statements ASSIGNING <ls_statement>
       WHERE keyword = 'COMPUTE'.
  ```

### 3. Functional Method Calls Become `+CALL_METHOD`
Functional calls like `lo_instance->do_work( )` or `cl_helper=>execute( )` do not start with the classic `CALL METHOD` keyword.
- The parser detects method invocations with `(` and assigns the special keyword **`+CALL_METHOD`**.
- **Agent Rule:** When inspecting method calls, look for both `keyword = '+CALL_METHOD'` and `keyword = 'CALL'`.

### 4. Compiler References (`is_statement-tokens-references`)
During tokenization, the driver resolves compiler symbols and attaches them directly to each token:
- Method calls (`=>`, `->`) automatically have references of kind `compiler_reference_kinds-method` with usage mode `READ`.
- Inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`) have references of kind `compiler_reference_kinds-data` with usage mode `DEFINITION_WITH_WRITE`.

### 5. Relative Line Numbering in Procedures
For procedure-level inspection and unit testing:
- Satır numaraları (line numbers) metot başlığına göre bağıl (relative) olarak hesaplanır:
  - Line 1: `METHOD <method_name>.`
  - Line 2: First executable line inside the method body.
- When writing unit test assertions (`expected_findings`), **always count line numbers starting from 1 at the `METHOD` statement**.

### 6. Pseudo-Comments & Pragmas
- Comments containing `"#EC <CODE>"` or pragmas `##<CODE>` are automatically stripped from executable tokens and added to `is_statement-pseudo_comments`.
- Base class `zcl_skylint_check_base` automatically suppresses findings if the statement contains the configured pseudo-comment.

---

## 🧠 Semantic Analysis & AST Traversal Standards

### 1. Minimum Magic Index Coupling ("Zero Magic Token Index")
- **Never assume fixed token positions** (e.g. do NOT assume `tokens[ 3 ]` or `tokens[ 4 ]` contains the identifier; source code can contain pragmas, line breaks, colons `:`, comments, or modifier keywords).
- **Rule of Thumb:** Any hardcoded token index greater than 2 is almost always an antipattern.
- **Allowed Traversal Patterns:**
  - Token stream traversal using loops (`LOOP AT is_statement-tokens`) with index bounds checking.
  - Keyword filters on statements (`WHERE keyword = ...`).
  - Scanning relative to a matched keyword or operator (e.g., finding the token immediately following `'TYPE'` or `'INTO'`).
  - Tracking delimiter/expression depth for parentheses `( )`, brackets `[ ]`, and braces `{ }`.

### 2. Compiler References over Text Matching (`tokens-references`)
The ATC source code provider binds compiler symbol resolution directly into `is_statement-tokens-references` (of type `if_ci_atc_source_code_provider=>ty_compiler_reference`).
- **Never guess what an identifier represents by matching its text.** Inspect `token-references` to determine whether a token is a method call, variable, type definition, database read, or database write.
- Traversal pattern:
  ```abap
  FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
  FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

  LOOP AT is_statement-tokens ASSIGNING <ls_token>.
    LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
      " Inspect semantic references rather than guessing from lexeme strings
      IF <ls_ref>-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method
         AND <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read.
        " Verified method call
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  ```

### 3. RTTI over String Matching (Class Hierarchies & Types)
- **Never use string parsing or regex** on `is_procedure-id-name` or `INHERITING FROM` to determine class hierarchies, interfaces, or superclasses.
- **Always use ABAP Run-Time Type Identification (RTTI):**
  - Use `cl_abap_typedescr=>describe_by_name( lv_classname )`.
  - Cast to `cl_abap_classdescr` to inspect superclasses via `get_super_class_type( )`, method signatures, and implemented interfaces.
  - Always wrap RTTI operations in `TRY ... CATCH cx_root` to safely handle local or dynamic test types.
- Example Pattern (Inspecting Superclasses via RTTI):
  ```abap
  DATA lo_descr TYPE REF TO cl_abap_typedescr.
  DATA lo_class TYPE REF TO cl_abap_classdescr.
  DATA lo_super TYPE REF TO cl_abap_classdescr.

  TRY.
      lo_descr = cl_abap_typedescr=>describe_by_name( lv_class_name ).
      IF lo_descr->kind = cl_abap_typedescr=>kind_class.
        lo_class ?= lo_descr.
        lo_super = lo_class->get_super_class_type( ).
        WHILE lo_super IS BOUND.
          IF lo_super->get_relative_name( ) = 'CL_EXPECTED_PARENT'.
            " Matches parent hierarchy!
            EXIT.
          ENDIF.
          lo_super = lo_super->get_super_class_type( ).
        ENDWHILE.
      ENDIF.
    CATCH cx_root.
      " Safe fallback when class description cannot be resolved
  ENDTRY.
  ```

### 4. Typed Constants & Enums over String Literals
- **Strictly avoid magic string literals** for statement kinds, object types, reference kinds, or usage modes.
- **Mandatory Constants from `if_ci_atc_source_code_provider`:**
  - `compilation_unit_kinds` (e.g. `compilation_unit_kinds-class`, `compilation_unit_kinds-interface`)
  - `procedure_kinds` (e.g. `procedure_kinds-method`, `procedure_kinds-class_definition`)
  - `compiler_reference_kinds` (e.g. `compiler_reference_kinds-method`, `compiler_reference_kinds-data`, `compiler_reference_kinds-type`)
  - `usage_modes` (e.g. `usage_modes-read`, `usage_modes-write`, `usage_modes-read_database`, `usage_modes-write_database`, `usage_modes-redefinition`)
  - `usage_grades` (e.g. `usage_grades-definition`, `usage_grades-direct`, `usage_grades-indirect`)
- **RTTI Constants:**
  - `cl_abap_typedescr=>kind_class`, `cl_abap_typedescr=>kind_struct`, `cl_abap_typedescr=>kind_table`, etc.

### 5. Stateful Block & Control Flow Traversal (Depth Tracking)
When inspecting multi-statement structures (e.g., `IF ... ENDIF`, `LOOP ... ENDLOOP`, `TRY ... CATCH`, `SELECT ... ENDSELECT`):
- Maintain an integer depth counter (`lv_depth`) to track nesting accurately without tripping over inner blocks.
- **Pattern:**
  ```abap
  DATA lv_depth TYPE i.
  FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

  LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
    CASE <ls_statement>-keyword.
      WHEN 'LOOP' OR 'DO' OR 'WHILE'.
        lv_depth = lv_depth + 1.
        IF lv_depth > 2.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-deep_nesting ).
        ENDIF.
      WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
        IF lv_depth > 0.
          lv_depth = lv_depth - 1.
        ENDIF.
    ENDCASE.
  ENDLOOP.
  ```

---

## ⚡ Open-ABAP Transpiler & Node.js Runtime Resilience

All rules, test drivers, and fixtures run in unit tests via the **open-abap transpiler** in Node.js. Adhere to these runtime safety rules:

1. **Safe RTTI with `cx_root`:**
   - Always wrap calls to `cl_abap_typedescr=>describe_by_name( ... )` in `TRY ... CATCH cx_root.`
   - During transpiler execution, dynamic or non-existent test types will raise an exception rather than returning null.
2. **Safe Internal Table Indexing:**
   - Unchecked array reads like `tokens[ 3 ]` throw `CX_SY_ITAB_LINE_NOT_FOUND` in Open-ABAP if out of bounds.
   - Always verify table size first (`IF lines( tokens ) >= 3.`) or use `READ TABLE ... INTO ... INDEX ...`.
3. **Supported Built-in String Functions:**
   - Favor standard built-ins: `to_upper( )`, `to_lower( )`, `strlen( )`, `contains( )`, `matches( )`.
   - Avoid complex PCRE regex flags that may differ between the ABAP kernel and the V8 JavaScript regex engine.

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

### 5. QuickFix Implementation & API Pattern
When automated code replacement or removal is appropriate, use the QuickFix API provided by `zcl_skylint_check_base`:

1. **Define QuickFix Codes in `c_quickfix_codes` & register in `constructor`:**
   ```abap
   CONSTANTS:
     BEGIN OF c_quickfix_codes,
       replace_syntax TYPE zcl_skylint_check_base=>ty_quickfix_code VALUE 'REPLACE_ST',
     END OF c_quickfix_codes.

   super->constructor(
       VALUE #(
           ...
           quickfix_codes = VALUE #(
               ( code       = c_quickfix_codes-replace_syntax
                 short_text = 'Replace with modern equivalent' ) ) ) ).
   ```

2. **Generate QuickFix Details in `check` & attach to findings:**
   ```abap
   DATA lo_details TYPE if_ci_atc_check=>ty_details.

   lo_details = quickfix_replace(
       iv_quickfix_code  = c_quickfix_codes-replace_syntax
       is_procedure_id   = is_procedure-id
       iv_statement_from = <ls_statement>-position-line
       it_new_code       = VALUE #( ( 'NEW_REPLACEMENT_STATEMENT.' ) ) ).

   report_statement( is_statement    = <ls_statement>
                     iv_finding_code = c_finding_codes-my_finding_code
                     io_details      = lo_details ).
   ```

3. **Available Base QuickFix Helpers:**
   - `quickfix_replace( ... )`: Replaces lines or specific token ranges.
   - `quickfix_insert_before( ... )`: Inserts lines before the statement.
   - `quickfix_insert_after( ... )`: Inserts lines after the statement.
   - `quickfix_delete( ... )`: Completely deletes the statement.

---

## 🚫 The 5 Most Critical Anti-Patterns to Avoid

1. **Assuming Magic Token Indices (`tokens[ 3 ]`):**
   - *Why:* Line breaks, pragmas, or modifier tokens shift indices, causing test failures or `CX_SY_ITAB_LINE_NOT_FOUND` dumps.
   - *Fix:* Always loop through tokens or verify table boundaries (`IF lines( tokens ) >= N.`).

2. **Forgetting Relative Procedure Line Offsets in Unit Tests:**
   - *Why:* ATC procedures normalize lines relative to the `METHOD` header. Line 1 is always `METHOD ...`, and Line 2 is the first line of the body.
   - *Fix:* In `expected_findings`, count line numbers starting from 1 at the `METHOD` statement.

3. **Missing `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>` in XML:**
   - *Why:* Without this tag, the Open-ABAP transpiler will skip the `.testclasses.abap` include entirely.
   - *Fix:* Every check class `.clas.xml` must include `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`.

4. **Parsing Chained Statements (`:`, `,`) or Raw Text for Keywords:**
   - *Why:* The ATC code provider unrolls chains into individual statements and tags implicit assignments as `'COMPUTE'` and method calls as `'+CALL_METHOD'`.
   - *Fix:* Rely on `statement-keyword` and normalized statement streams instead of raw punctuation regex.

5. **Omitting `npm run index` After Check Lifecycle Changes:**
   - *Why:* Adding, deleting, or renaming checks changes numbering and test class bindings.
   - *Fix:* Always run `npm run index` to resequence all checks sequentially (001, 002, ...) and sync the `README.md` catalog with QuickFix badges.

---

## 🚀 Step-by-Step Workflow for Adding a Check

Follow this exact procedure when adding or modifying check rules:

1. **Create the Check Class & Files:**
   - Create `src/checks/zcl_skylint_check_XXX.clas.abap` inheriting from `zcl_skylint_check_base`.
   - Create `src/checks/zcl_skylint_check_XXX.clas.xml` with `<WITH_UNIT_TESTS>X</WITH_UNIT_TESTS>`.
   - Create `src/tests/zcl_skylint_test_XXX.clas.abap` and its corresponding `.clas.xml`.
   - Create `src/checks/zcl_skylint_check_XXX.clas.testclasses.abap`.

2. **Implement Inspection Logic:**
   - Adhere to the Zero Magic Index and Compiler References standards.
   - Use `report_statement( is_statement = <ls_statement> iv_finding_code = ... )` or `report_token(...)`.
   - Support optional QuickFixes via `quickfix_replace(...)` / `io_details` when appropriate.

3. **Re-index and Renumber:**
   - Run `npm run index`
   - The indexer automatically renumbers all checks sequentially (001, 002, ...), updates class names, test bindings, XML tags, and regenerates `README.md` with accurate QuickFix badges.

4. **Verify Linter and Tests:**
   - Run `npm test`
   - Ensure `npm run lint` yields `0 issue(s) found`.
   - Ensure all unit tests pass with `Exit code 0`.

