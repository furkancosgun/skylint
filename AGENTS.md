# 🤖 Skylint Agent Development Guidelines & Standards (`AGENTS.md`)

This document outlines the mandatory engineering guidelines, architectural design patterns, Clean ABAP standards, testing workflows, and parser internals for any AI agent or contributor developing check rules in **Skylint**.

---

## 🏛️ Core Philosophy & Architecture

1. **Platform-Agnostic Core (`main` branch):**
   - The core checks in `src/checks/` **MUST NEVER** reference platform-specific APIs or interfaces (neither SAP ATC Cloud `if_ci_atc_*` nor classic Code Inspector `cl_ci_*`).
   - All AST structures, code block types, token representations, findings, severities, and quickfix types are defined centrally in `zif_skylint_types`.
   - The `main` branch is 100% portable and executable via Open-ABAP transpiler in Node.js, SAP NetWeaver 7.40+, S/4HANA On-Premise, and SAP BTP ABAP Environment.

2. **Multi-Platform Branch Architecture:**
   - **`main`**: Pure check domain logic + universal AST engine + JS test harness (`scripts/skylint-test/`). Zero external platform dependencies.
   - **`cloud`**: Native SAP ATC Cloud adapter branch. Implements `if_ci_atc_check` and translates `if_ci_atc_source_code_provider` procedures into `zif_skylint_types` structures for SAP BTP and S/4HANA Public Cloud.
   - **`standard`**: Classic SAP Code Inspector adapter branch. Integrates with `CL_CI_TEST_SCAN` and `CL_CI_TEST_ROOT` for classic SAP NetWeaver 7.40+ and S/4HANA Private Cloud.

3. **Mandatory Single Source of Truth (`zif_skylint_types`):**
   - All types, structures, and constants for AST analysis **MUST** reference `zif_skylint_types`:
     - AST: `ty_code_block`, `ty_statement`, `ty_token`, `ty_compiler_reference`.
     - Findings: `ty_finding`, `ty_findings`, `ty_finding_code`, `severities`.
     - QuickFixes: `ty_quickfix`, `ty_quickfixes`, `ty_quickfix_code`.
     - Constants: `object_types`, `block_kinds`, `compiler_reference_kinds`, `usage_modes`, `usage_grades`, `attribute_kinds`.

4. **Zero-Boilerplate Base Class (`zcl_skylint_check_base`):**
   - Every check rule **MUST** inherit from `zcl_skylint_check_base` in its own isolated class named `zcl_skylint_check_XXX`.
   - Subclasses only need to implement:
     - `constructor`: Metadata configuration (description, finding codes, severities, pseudo-comments, and attributes).
     - `check( is_code_block )`: Code block inspection logic over `is_code_block-statements`.
   - Finding creation, token offset mapping, pseudo-comment suppression, and quickfix formatting are automatically handled by the base class.

---

## ⚙️ Universal AST Model & Parser Normalization

Understanding how Skylint normalizes source code into an AST is essential for writing accurate rules without false positives or redundant logic.

### 1. Chain Statement Normalization (No Chains in AST)
In ABAP source code, developers frequently write chained statements:
```abap
DATA: lv_a TYPE i,
      lv_b TYPE string.
```
In Skylint's AST, **chains do not exist**:
- The parser unrolls chains and attaches the header token (`DATA`) to every statement:
  1. `DATA lv_a TYPE i.`
  2. `DATA lv_b TYPE string.`
- **Agent Rule:** Never write check rules looking for colons `:` or chained commas `,`. Every statement is delivered as an independent, fully qualified statement.

### 2. Implicit Assignments Become `COMPUTE`
Modern ABAP assignments like `lv_val = 10.` or `ls_data-field = 'X'.` do not have an explicit keyword in the text.
- When an assignment operator `=` is found at top level (`paren_depth = 0`), the statement's `keyword` is set to **`COMPUTE`**.
- **Agent Rule:** To inspect value assignments, computations, or constructor expressions assigned to a variable, filter directly by:
  ```abap
  LOOP AT is_code_block-statements ASSIGNING <ls_statement>
       WHERE keyword = 'COMPUTE'.
  ```

### 3. Functional Method Calls Become `+CALL_METHOD`
Functional calls like `lo_instance->do_work( )` or `cl_helper=>execute( )` do not start with the classic `CALL METHOD` keyword.
- The parser assigns the special keyword **`+CALL_METHOD`**.
- **Agent Rule:** When inspecting method calls, use `zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> )` or look for both `keyword = '+CALL_METHOD'` and `keyword = 'CALL'`.

### 4. Compiler References (`token-references`)
During tokenization, compiler symbols are attached to each token:
- Method calls (`=>`, `->`) have references of kind `zif_skylint_types=>compiler_reference_kinds-method` with usage mode `READ`.
- Inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`) have references of kind `zif_skylint_types=>compiler_reference_kinds-data` with usage mode `DEFINITION_WITH_WRITE`.

### 5. Relative Line Numbering in Procedures
For procedure inspection and unit testing:
- Statement line numbers are relative to the inspected procedure block:
  - Line 1: `METHOD <method_name>.`
  - Line 2: First executable line inside the method body.
- When writing fixture assertions (`expected.json`), **always count line numbers starting from 1 at the `METHOD` statement**.

### 6. Pseudo-Comments & Pragmas
- Comments containing `"#EC <CODE>"` or pragmas `##<CODE>` are automatically attached to `is_statement-pseudo_comments`.
- Base class `zcl_skylint_check_base` automatically suppresses findings if the statement contains the configured pseudo-comment.

---

## 🧠 Semantic Analysis & AST Traversal Standards

### 1. Minimum Magic Index Coupling ("Zero Magic Token Index")
- **Never assume fixed token positions** (e.g. do NOT assume `tokens[ 3 ]` or `tokens[ 4 ]` contains the identifier; source code can contain pragmas, line breaks, comments, or modifier keywords).
- **Rule of Thumb:** Any hardcoded token index greater than 2 is almost always an antipattern.
- **Allowed Traversal Patterns:**
  - Token stream traversal using loops (`LOOP AT is_statement-tokens`) with index bounds checking.
  - Keyword filters on statements (`WHERE keyword = ...`).
  - Scanning relative to a matched keyword or operator (e.g., finding the token immediately following `'TYPE'` or `'INTO'`).
  - Tracking delimiter/expression depth for parentheses `( )`, brackets `[ ]`, and braces `{ }`.
  - Using helper methods from `zcl_skylint_ast_util` (`find_token_sequence`, `statement_is_method_call`).

### 2. Compiler References over Text Matching (`tokens-references`)
Compiler symbol resolution is stored in `is_statement-tokens-references` (of type `zif_skylint_types=>ty_compiler_reference`).
- **Never guess what an identifier represents by matching its text.** Inspect `token-references` to determine whether a token is a method call, variable, type definition, database read, or database write.
- **Lexemes are untrusted for keywords too:** a user variable can be named `EQ` — a token with text `EQ` is only the operator when its references are empty (a variable `eq` carries a data reference). Always confirm via references.
- **Reserved builtin exception (only sanctioned case):** `ABAP_TRUE`, `ABAP_FALSE`, `ABAP_UNDEFINED` are matched by closed name set even with references — SAP reserves these names and they always denote the builtin constants. `SPACE` and everything else require empty references.
- **Shadowing requires declaration scan:** when a user identifier can textually equal a keyword (`ME->`, `CX_SY_*`), a reference on the usage token is not enough — scan the block with `zcl_skylint_ast_util=>is_declared_data( it_statements iv_name )` and skip when a `DA` definition with that name exists.
- **Every finding must carry a statement index.** `report_statement`/`report_token` set `statement_index` from `is_statement-index` automatically — never construct findings manually and never report synthetic statements without an index. The JS harness fails any finding with `statement_index <= 0`.
- Traversal pattern:
  ```abap
  FIELD-SYMBOLS <ls_token> TYPE zif_skylint_types=>ty_token.
  FIELD-SYMBOLS <ls_ref>   TYPE zif_skylint_types=>ty_compiler_reference.

  LOOP AT is_statement-tokens ASSIGNING <ls_token>.
    LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
      IF <ls_ref>-kind = zif_skylint_types=>compiler_reference_kinds-method
         AND <ls_ref>-usage_mode = zif_skylint_types=>usage_modes-read.
        " Verified method call
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  ```

### 3. Safe RTTI over String Matching (Class Hierarchies & Types)
- **Never use string parsing or regex** on `is_code_block-block_name` or `INHERITING FROM` to determine class hierarchies, interfaces, or superclasses.
- **Always use ABAP Run-Time Type Identification (RTTI) via `zcl_skylint_rtti_util`:**
  - Safe wrappers over `cl_abap_typedescr=>describe_by_name( lv_classname )`.
  - Always wrap raw RTTI operations in `TRY ... CATCH cx_root` to safely handle dynamic test types in Open-ABAP transpiler environments.
- Example Pattern:
  ```abap
  DATA lt_super_classes TYPE string_table.

  lt_super_classes = zcl_skylint_rtti_util=>get_super_classes( lv_class_name ).
  IF line_exists( lt_super_classes[ table_line = 'CL_EXPECTED_PARENT' ] ).
    " Matches parent hierarchy!
  ENDIF.
  ```

### 4. Typed Constants & Enums over Magic Literals
- **Strictly avoid magic string literals** for statement kinds, object types, reference kinds, severities, or usage modes.
- **Mandatory Constants from `zif_skylint_types`** (values are 1:1 with `IF_CI_ATC_SOURCE_CODE_PROVIDER` — never invent constant values, complete missing ones from that interface):
  - `object_types` (e.g. `object_types-class`, `object_types-interface`, `object_types-program`)
  - `block_kinds` (e.g. `block_kinds-method`, `block_kinds-class_definition`)
  - `compiler_reference_kinds` (full ATC `ty_reference_kind` parity: `data`, `method`, `type`, plus `function`, `form`, `event`, `include`, …)
  - `usage_modes` (e.g. `usage_modes-read`, `usage_modes-write`, `usage_modes-read_database`, `usage_modes-write_database`)
  - `usage_grades` (e.g. `usage_grades-definition`, `usage_grades-direct`, `usage_grades-indirect`)
  - `severities` (e.g. `severities-error`, `severities-warning`, `severities-info`)
  - `attribute_kinds` (e.g. `attribute_kinds-boolean`, `attribute_kinds-integer`, `attribute_kinds-string`, `attribute_kinds-elementary`)

### 5. Stateful Block & Control Flow Traversal (Depth Tracking)
When inspecting multi-statement structures (e.g., `IF ... ENDIF`, `LOOP ... ENDLOOP`, `TRY ... CATCH`, `SELECT ... ENDSELECT`):
- Maintain an integer depth counter (`lv_depth`) to track nesting accurately without tripping over inner blocks.
- **Pattern:**
  ```abap
  DATA lv_depth TYPE i.
  FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

  LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
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
   - Local structures: `ls_*` (e.g., `ls_statement`, `ls_token`, `ls_quickfix`).
   - Local internal tables: `lt_*` (e.g., `lt_tokens`, `lt_statements`).
   - Field symbols: `<ls_*>`, `<lv_*>`.
   - Member attributes: `mv_*`, `mt_*`, `mo_*`.
   - Constants: `c_*` or structured constants `BEGIN OF c_finding_codes ... END OF c_finding_codes`.

3. **Control Structure Hygiene:**
   - **No `if_in_if`:** Combine nested conditionals using `IF cond1 AND cond2.` instead of nesting `IF` within `IF`.
   - **Use `CASE` for Multi-Branch Keyword Dispatches:** Satisfy `change_if_to_case`.
   - **No Trailing Dots / Formatting Errors:** Keep line lengths under 120 characters, align `TYPE` expressions to the same column, and use uppercase ABAP keywords.

---

## 🛠️ Anatomy of a Skylint Check Rule

Each check consists of 2 ABAP files + 1 fixture directory. Test sources live in `tests/fixtures/` (never shipped to SAP systems):

```text
src/
├── checks/
│   ├── zcl_skylint_check_XXX.clas.abap         # 1. Main check implementation
│   └── zcl_skylint_check_XXX.clas.xml          # 2. abapGit XML
tests/
└── fixtures/check_XXX/
    ├── source.abap                             # 3. Full test class source
    └── expected.json                           # 4. Expected findings
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
        my_finding_code TYPE zif_skylint_types=>ty_finding_code VALUE 'FINDINGCD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MY_RULE_SUPPRESSION'.

    " Configurable Attributes
    DATA mv_custom_option TYPE abap_bool VALUE abap_false.

ENDCLASS.


CLASS zcl_skylint_check_XXX IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detailed rule description'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-my_finding_code
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Clear finding message explaining why and how to fix'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'CUSTOM_OPTION'
                       kind  = zif_skylint_types=>attribute_kinds-boolean
                       value = REF #( mv_custom_option ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_custom_opt TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'CUSTOM_OPTION'
                   IMPORTING ev_value = lv_custom_opt ).

    IF lv_custom_opt IS INITIAL.
      lv_custom_opt = mv_custom_option.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'TARGET_KEYWORD'.
      " Inspection logic
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-my_finding_code ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

### 2. Main Check XML (`src/checks/zcl_skylint_check_XXX.clas.xml`)
Plain abapGit class XML (no test include — tests live in `tests/fixtures/`, not in ABAP):

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
    </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
```

### 3. Test Fixture (`tests/fixtures/check_XXX/`)
Tests run in the JS harness (`scripts/skylint-test/run.mjs`), which ports the SAP-identical tokenizer 1:1 to JS
(`lexer.mjs`) and enriches compiler/RTTI data via abaplint (`abaplint-bridge.mjs`, `rtti.mjs`).
The harness slices `METHOD..ENDMETHOD` (or `CLASS DEFINITION`/`INTERFACE`) blocks itself, so `line`/`column`
in `expected.json` stay relative to the sliced block. Regenerate positions with `npm run build` + `npm run positions`:

`source.abap` (full test class source):
```abap
CLASS zcl_skylint_test_XXX DEFINITION
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.
CLASS zcl_skylint_test_XXX IMPLEMENTATION.
  METHOD test_001.
    NON_COMPLIANT_STATEMENT.
  ENDMETHOD.
  METHOD test_002.
    COMPLIANT_STATEMENT.
  ENDMETHOD.
ENDCLASS.
```

`expected.json` (`code: null` asserts zero findings):
```json
[
  { "method": "TEST_001", "code": "FINDINGCD", "line": 2, "column": 4 },
  { "method": "TEST_002", "code": null }
]
```

Notes:
- There is no ABAP test runner anymore. Adapters (`sci/atc_adapter`) stay for production branches only.
- `expected.json` rows target either a `METHOD name` slice or a `CLASS/INTERFACE name` definition block
  (`method = 'LCL_CHILD'` slices `CLASS lcl_child DEFINITION..ENDCLASS.`). Method rows fall back to a class
  definition block when the body is empty/`RETURN.` only.
- The harness derives `object_name` (enclosing class of a method slice, matched name of a definition slice)
  and passes it to checks and to RTTI feeding, so hierarchy checks (`get_super_classes`) resolve the tested
  class instead of a synthetic name.
- Tokenizer (`lexer.mjs`) is a 1:1 port of the SAP-identical ABAP tokenizer — do NOT replace it with
  abaplint's tokenizer. Compiler references are hybrid: JS heuristic first, then `abaplint-bridge.mjs`
  enriches via `@abaplint/core` (`SyntaxLogic.spaghetti`). RTTI has NO static caches: `rtti.mjs`
  transpiles the full fixture source (lenient batch + auto-stubbed unknown superclasses) and evaluates it into the shared `abap.Classes`
  registry with a `ZSKYLINT_TEST` alias, so `zcl_skylint_rtti_util` live queries (`describe_*`, `is_static_method`,
  `get_single_importing_param`, `get_super_classes`) resolve. No filesystem access in tests.

### 4. QuickFix Implementation & API Pattern
When automated code replacement or removal is appropriate, use the QuickFix API:

1. **Define QuickFix Codes in `c_quickfix_codes` & register in `constructor`:**
   ```abap
   CONSTANTS:
     BEGIN OF c_quickfix_codes,
       replace_syntax TYPE zif_skylint_types=>ty_quickfix_code VALUE 'REPLACE_ST',
     END OF c_quickfix_codes.

   super->constructor(
       VALUE #(
           ...
           quickfix_codes = VALUE #(
               ( code       = c_quickfix_codes-replace_syntax
                 short_text = 'Replace with modern equivalent' ) ) ) ).
   ```

2. **Generate QuickFix in `check` & attach to findings:**
   ```abap
   DATA ls_quickfix TYPE zif_skylint_types=>ty_quickfix.

   ls_quickfix = quickfix_replace(
       iv_quickfix_code  = c_quickfix_codes-replace_syntax
       iv_statement_from = sy-tabix
       it_new_code       = VALUE #( ( 'NEW_REPLACEMENT_STATEMENT.' ) ) ).

   report_statement( is_statement    = <ls_statement>
                     iv_finding_code = c_finding_codes-my_finding_code
                     is_quickfix     = ls_quickfix ).
   ```

3. **Verify QuickFix via fixture:**
   Add a non-compliant `METHOD` to the fixture `source.abap` and assert the
   finding in `expected.json`. The harness surfaces `quickfixes` on findings
   for adapter-level verification.

---

## 🚫 The 5 Most Critical Anti-Patterns to Avoid

1. **Importing Platform Interfaces into Core Checks:**
   - *Why:* Referencing `if_ci_atc_*` or `cl_ci_*` breaks portability and prevents running in Open-ABAP or NetWeaver environments without ATC Cloud stubs.
   - *Fix:* Always and exclusively use `zif_skylint_types`.

2. **Assuming Magic Token Indices (`tokens[ 3 ]`):**
   - *Why:* Line breaks, pragmas, or modifier tokens shift indices, causing test failures or `CX_SY_ITAB_LINE_NOT_FOUND` dumps.
   - *Fix:* Always loop through tokens or verify table boundaries (`IF lines( tokens ) >= N.`).

3. **Replacing the JS tokenizer with abaplint's:**
   - *Why:* `scripts/skylint-test/lexer.mjs` is a 1:1 port of the SAP-identical tokenizer the checks were written against; abaplint splits punctuation differently and would shift positions/keywords.
   - *Fix:* Never swap tokenizers. Fix bugs in `lexer.mjs`/`parser.mjs` with 1:1 ABAP-equivalent semantics.

4. **Parsing Chained Statements (`:`, `,`) or Raw Text for Keywords:**
   - *Why:* The AST unrolls chains into individual statements and tags implicit assignments as `'COMPUTE'` and method calls as `'+CALL_METHOD'`.
   - *Fix:* Rely on `statement-keyword` and normalized statement streams instead of raw punctuation regex.

5. **Inline Declarations & Syntax Non-Compliance:**
   - *Why:* `DATA(...)` or `ASSIGN ... TO FIELD-SYMBOL(...)` fail abaplint rules and compatibility with classic ABAP versions.
   - *Fix:* Always use explicit `DATA` and `FIELD-SYMBOLS` at the top of the method.

---

## 🚀 Step-by-Step Workflow for Adding a Check

Follow this exact procedure when adding or modifying check rules:

1. **Create the Check Class & Files:**
   - Create `src/checks/zcl_skylint_check_XXX.clas.abap` inheriting from `zcl_skylint_check_base`.
   - Create `src/checks/zcl_skylint_check_XXX.clas.xml` (plain abapGit class XML, no test include).
   - Create `tests/fixtures/check_XXX/source.abap` + `expected.json` for the JS harness.

2. **Implement Inspection Logic:**
   - Adhere to the Zero Magic Index and Compiler References standards.
   - Use `report_statement( is_statement = <ls_statement> iv_finding_code = ... is_quickfix = ls_quickfix )` or `report_token(...)`.
   - Support optional QuickFixes via `quickfix_replace(...)` when appropriate.

3. **Re-index and Renumber:**
   - Run `npm run index`
   - The indexer automatically renumbers all checks sequentially (001, 002, ...), updates class names, fixture dirs, XML tags, and regenerates `README.md` with accurate QuickFix badges.

4. **Verify Linter and Tests:**
   - Run `npm test`
   - Ensure `npm run lint` yields `0 issue(s) found`.
   - Ensure all unit tests pass with `Exit code 0`.
