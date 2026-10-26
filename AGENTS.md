# 🤖 Skylint Agent Development Guidelines & Standards (`AGENTS.md`)

This document outlines the mandatory engineering guidelines, architectural design patterns, Clean ABAP standards, testing workflows, and parser internals for any AI agent or contributor developing check rules in **Skylint**.

---

## 🏛️ Core Philosophy & Architecture

1. **ATC-Native Core:**
   - Every check inherits `zcl_skylint_check_base` and implements `if_ci_atc_check` directly.
   - All statement, token, reference, and finding types come from the standard SAP ATC framework:
     `if_ci_atc_source_code_provider` (code), `if_ci_atc_check` (findings),
     `if_ci_atc_check_meta_data` (config), `cl_ci_atc_quickfixes` (quickfix codes).
   - Target language version is ABAP Cloud (`abaplint.json`: `Cloud`).

2. **Shared Base Class (`zcl_skylint_check_base` + `zcl_skylint_check_meta_data`):**
   - `zcl_skylint_check_base` implements `if_ci_atc_check~run` (procedure loop, checksum, location,
     quickfix context creation) and exposes the rule API: `check`, `report_statement`, `report_token`,
     `quickfix_replace`. Attributes bound via `REF #( mv_* )` are updated in place by the framework.
   - `zcl_skylint_check_meta_data` is the single shared `if_ci_atc_check_meta_data` implementation,
     fed from the base config. Do NOT create per-check metadata classes.

3. **Mandatory Type Sources (no custom type interface):**
   - Code analysis **MUST** use framework types:
     - Statements/tokens/references: `if_ci_atc_source_code_provider=>ty_statement`, `=>ty_token`,
       `=>ty_compiler_reference`, `=>ty_procedure` (`-id-kind`, `-id-name`, `-id-main_unit-kind/name`).
     - Findings: `if_ci_atc_check=>ty_finding_code`, `=>finding_severities-warning/error/note`.
     - QuickFixes: `zcl_skylint_check_base=>ty_quickfix/ty_quickfixes/ty_code_lines`,
       `cl_ci_atc_quickfixes=>ty_quickfix_code`.
     - Attributes: `if_ci_atc_check_meta_data=>attribute_kinds-boolean/elementary`
       (`string`/`integer` options map to `elementary`).
   - Custom type wrapper interfaces must not be used; rely directly on standard `if_ci_atc_*` framework types.

4. **Zero-Boilerplate Rule (`zcl_skylint_XXX`):**
   - Every check rule **MUST** inherit from `zcl_skylint_check_base` in its own isolated class named `zcl_skylint_XXX` (e.g. `zcl_skylint_pref_lines`, `zcl_skylint_no_call_method`, maximum 30 characters).
   - Subclasses only need to implement:
     - `constructor`: Metadata configuration (description, finding codes, severities, pseudo-comments, and attributes).
     - `check( is_procedure )`: Procedure inspection logic over `is_procedure-statements`.
   - Finding creation, checksum/location mapping, pseudo-comment suppression, and quickfix formatting are automatically handled by the base class.

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
  LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
    IF <ls_statement>-keyword <> 'COMPUTE'.
      CONTINUE.
    ENDIF.
  ```

### 3. Functional Method Calls Become `+CALL_METHOD`
Functional calls like `lo_instance->do_work( )` or `cl_helper=>execute( )` do not start with the classic `CALL METHOD` keyword.
- The parser assigns the special keyword **`+CALL_METHOD`**.
- **Agent Rule:** When inspecting method calls, use `zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> )` or look for both `keyword = '+CALL_METHOD'` and `keyword = 'CALL'`.

### 4. Compiler References (`token-references`)
During tokenization, compiler symbols are attached to each token:
- Method calls (`=>`, `->`) have references of kind `if_ci_atc_source_code_provider=>compiler_reference_kinds-method` with usage mode `READ`.
- Inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`) have references of kind `if_ci_atc_source_code_provider=>compiler_reference_kinds-data` with usage mode `DEFINITION_WITH_WRITE`.

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

### 1. Minimum Magic Index Coupling ("Zero Magic Token Index") & `zcl_skylint_ast_util`
- **Never assume fixed token positions** (e.g. do NOT assume `tokens[ 3 ]` or `tokens[ 4 ]` contains the identifier; source code can contain pragmas, line breaks, comments, or modifier keywords, causing false positives or `CX_SY_ITAB_LINE_NOT_FOUND` dumps).
- **Rule of Thumb:** Any hardcoded token index greater than 2 is almost always an antipattern.
- **Prefer `zcl_skylint_ast_util` over direct array access:**
  - Access tokens safely via helper methods: `get_token`, `get_token_lexeme`, `get_first_token`, `get_last_token`, `find_token`, `get_token_before`, `get_token_after`.
  - If direct table reading is ever unavoidable, **always guard boundaries** (`IF lines( is_statement-tokens ) >= N.`).
- **Use `*sequence` helper methods for consecutive token structures:**
  - When inspecting consecutive token structures (e.g. `TYPE REF TO`, `ASSIGN ... TO`, keyword combinations), **never write manual nested loops** or index arithmetic (`READ TABLE tokens INDEX sy-tabix + 1`).
  - Use `zcl_skylint_ast_util=>find_token_sequence`, `get_token_after_sequence`, or `match_token_sequence`.
  - These sequence utilities automatically verify that each token in the expected sequence matches and has empty references (`references IS INITIAL`).
- **Allowed Traversal Patterns:**
  - Token stream traversal using loops (`LOOP AT is_statement-tokens`) with index bounds checking.
  - Keyword filters on statements (`WHERE keyword = ...`).
  - Scanning relative to a matched keyword or operator (e.g., finding the token immediately following `'TYPE'` or `'INTO'`).
  - Tracking delimiter/expression depth for parentheses `( )`, brackets `[ ]`, and braces `{ }`.
  - Using helper methods from `zcl_skylint_ast_util` (`find_token_sequence`, `statement_is_method_call`, `statement_is_db_access`).

### 2. Compiler References over Text Matching (`tokens-references`)
Compiler symbol resolution is stored in `is_statement-tokens-references` (of type `if_ci_atc_source_code_provider=>ty_compiler_reference`).
- **Never guess what an identifier represents by matching its text.** Inspect `token-references` to determine whether a token is a method call, variable, type definition, database read, or database write.
- **Mandatory empty reference check (`references IS INITIAL`) for keywords and operators:**
  - In ABAP, user variables or structure fields can legally share names with ABAP keywords or operators (e.g., `DATA eq TYPE i.`, `DATA type TYPE string.`).
  - A token with text `'EQ'` or `'TYPE'` is **only an operator/keyword when its references are empty** (`token-references IS INITIAL`). If it references a variable, it carries a `DATA` reference (`compiler_reference_kinds-data`).
  - Always confirm that `references IS INITIAL` before treating a token as a keyword or syntax operator.
  - Note: `zcl_skylint_ast_util` helper methods (such as `find_token_sequence`) automatically enforce this check internally.
- **Reserved builtin exception (only sanctioned case):** `ABAP_TRUE`, `ABAP_FALSE`, `ABAP_UNDEFINED` are matched by closed name set even with references — SAP reserves these names and they always denote the builtin constants. `SPACE` and everything else require empty references.
- **Shadowing requires declaration scan:** when a user identifier can textually equal a keyword (`ME->`, `CX_SY_*`), a reference on the usage token is not enough — scan the block with `zcl_skylint_ast_util=>is_declared_data( it_statements iv_name )` and skip when a `DA` definition with that name exists.
- **ATC statements have no index field.** Never rely on `statement-index`; inside a `LOOP AT is_procedure-statements` use `sy-tabix` when a statement position is needed (e.g. `quickfix_replace( iv_statement_from = sy-tabix ... )`). Findings carry checksum + location, computed by the base class.
- Traversal pattern:
  ```abap
  FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
  FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

  LOOP AT is_statement-tokens ASSIGNING <ls_token>.
    LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
      IF <ls_ref>-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method
         AND <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read.
        " Verified method call
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  ```

### 2.1 How Compiler References Are Produced (JS Test Process)
The `tokens-references` seen by a check are produced by the Skylint test harness, not by SAP.
The split of responsibilities is fixed:

| Layer | Module | Responsibility |
| --- | --- | --- |
| Skylint parser | `lib/core/lexer.mjs`, `lib/core/parser.mjs` | statements, keywords, chain unrolling, token positions |
| abaplint | `lib/core/references-abaplint.mjs` | **symbol resolution of usages** (read/write/method/type/object/table) via `SyntaxLogic` + spaghetti scope |
| Skylint parser | `lib/core/semantic.mjs` | **definitions** (`usage_grade 0`), inline declarations, system variables, message classes, database tables, catch types |

- abaplint does not emit references for declaration sites, therefore definitions
  (`DATA`, `CONSTANTS`, `FIELD-SYMBOLS`, `STATICS`, inline `DATA(...)`/`FIELD-SYMBOL(...)`)
  are synthesized by the Skylint parser with `usage_grade = 0`.
- abaplint resolves the *root* symbol of a component access, so the component path
  (`ls_data-field` -> `\DA:LS_DATA\DA:FIELD`) is added by the Skylint parser.
- abaplint cannot resolve symbols that are unknown to the registry (e.g. `CX_ROOT`,
  database tables that are not part of the scanned project). For those the safe
  fallback of `lib/core/semantic.mjs` complements the references.
- All 148 checks and 1,013 fixtures run through this unified pipeline.

### 3. Safe RTTI over String Matching (`zcl_skylint_rtti_util`) & Remote Enablement
- **Never use string parsing or regex** on `is_procedure-id-name` or `INHERITING FROM` to determine class hierarchies, interfaces, or superclasses.
- **Always use ABAP Run-Time Type Identification (RTTI) via `zcl_skylint_rtti_util`:**
  - Safe wrappers over `cl_abap_typedescr=>describe_by_name( lv_classname )`.
  - Inspect superclasses via `zcl_skylint_rtti_util=>get_super_classes( lv_class_name )`.
  - Always wrap raw RTTI operations in `TRY ... CATCH cx_root` to safely handle dynamic or missing types.
- **CRITICAL ARCHITECTURAL RULE: Checks using RTTI CANNOT be Remote Enabled:**
  - Any check that invokes RTTI (`zcl_skylint_rtti_util` or `cl_abap_typedescr`) **MUST set `remote_enablement = abap_false`** in its `constructor`.
  - *Why:* In ATC remote execution scenarios (analyzing remote systems via RFC), the local SAP system does not have access to runtime type descriptors of the remote system, which causes runtime errors or inaccurate results. Rules using RTTI can only be executed locally.
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
- **Mandatory framework constants (never invent values):**
  - `if_ci_atc_source_code_provider=>procedure_kinds` (e.g. `method`, `class_definition`, `form_routine`, `function`)
  - `if_ci_atc_source_code_provider=>compilation_unit_kinds` (e.g. `class`, `interface`, `report`)
  - `if_ci_atc_source_code_provider=>compiler_reference_kinds` (e.g. `data`, `method`, `type`)
  - `if_ci_atc_source_code_provider=>usage_modes` (e.g. `read`, `write`, `read_database`, `write_database`)
  - `if_ci_atc_source_code_provider=>usage_grades` (e.g. `definition`, `direct`, `indirect`)
  - `if_ci_atc_check=>finding_severities` (`error`, `warning`, `note`)
  - `if_ci_atc_check_meta_data=>attribute_kinds` (`boolean`, `elementary`)

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

## ⚡ ABAP Cloud & ATC Framework Notes

`src/` targets ABAP Cloud (`abaplint.json`: `Cloud`) and runs natively on ATC-capable SAP systems.
`deps/atc/src/` holds local-only stubs of the ATC framework for abaplint/transpiler resolution —
they never ship via abapGit. Adhere to these runtime safety rules:

1. **Safe RTTI with `cx_root`:**
   - Always wrap calls to `cl_abap_typedescr=>describe_by_name( ... )` in `TRY ... CATCH cx_root.`
2. **Safe Internal Table Indexing:**
   - Unchecked array reads like `tokens[ 3 ]` dump with `CX_SY_ITAB_LINE_NOT_FOUND` if out of bounds.
   - Always verify table size first (`IF lines( tokens ) >= 3.`) or use `READ TABLE ... INTO ... INDEX ...`.
3. **Cloud-safe built-ins only:**
   - Favor standard built-ins: `to_upper( )`, `to_lower( )`, `strlen( )`, `contains( )`, `matches( )`.
   - No obsolete statements, no `CREATE OBJECT` (prefer `NEW`), no `LIKE` — the code must compile under Cloud syntax.
4. **No line break after `=>`:**
   - abaplint cannot parse a line break between `=>` and the component name — keep
     `if_ci_atc_check=>finding_severities-warning` style references on a single line and
     re-indent the surrounding `VALUE #( )` block instead when a line exceeds 120 chars.

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

Each check consists of 2 ABAP files + 1 fixture directory. Test sources live in `test/fixtures/` (never shipped to SAP systems):

```text
src/
├── checks/
│   ├── zcl_skylint_XXX.clas.abap         # 1. Main check implementation
│   └── zcl_skylint_XXX.clas.xml          # 2. abapGit XML
test/
└── fixtures/XXX/                         # 3. Short class name (e.g. pref_lines, no_neg_cond)
    ├── source.abap                       # Full test class source
    └── expected.json                     # Expected findings
```

### 1. Main Check Implementation Pattern

```abap
CLASS zcl_skylint_XXX DEFINITION
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

    " Configurable Attributes
    DATA mv_custom_option TYPE abap_bool VALUE abap_false.

ENDCLASS.


CLASS zcl_skylint_XXX IMPLEMENTATION.
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
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF mv_custom_option = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'TARGET_KEYWORD'.
        CONTINUE.
      ENDIF.

      " Inspection logic
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-my_finding_code ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
```

### 2. Main Check XML (`src/checks/zcl_skylint_XXX.clas.xml`)
Plain abapGit class XML (no test include — tests live in `test/fixtures/`, not in ABAP):

```xml
<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>ZCL_SKYLINT_XXX</CLSNAME>
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

### 3. Test Fixture (`test/fixtures/XXX/`)
Each check keeps a fixture directory as test data, executed by the ATC-native
harness (`test/run.mjs`: fixture → `ty_procedure` → real `if_ci_atc_check~run`
with JS test doubles for the SAP boundary).
`METHOD..ENDMETHOD` (or `CLASS DEFINITION`/`INTERFACE`) blocks map to slices, so `line`/`column`
in `expected.json` stay relative to the sliced block.

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
  { "target": "TEST_001", "code": "FINDINGCD", "line": 2, "column": 4, "quickfixes": ["REPLACE_ST"] },
  { "target": "TEST_002", "code": null }
]
```

Notes:
- Local verification: `npm test` runs full linter, build, and fixture assertions across all checks.
  Run `node test/run.mjs [XXX]` to test a specific check.
- **QuickFix Round-Trip Validation:** Every recorded QuickFix is automatically applied and parsed
  via `@abaplint/core` (`lib/roundtrip.mjs`) to ensure it leaves behind valid, parseable ABAP.
- `expected.json` rows target either a `METHOD name` slice, `CLASS/INTERFACE name` definition block
  (`target = 'LCL_CHILD'` slices `CLASS lcl_child DEFINITION..ENDCLASS.`), or full procedure (`target = 'LCL_X=>METH'`).
- Rows assert `{target, code, line, column}` plus optional `quickfixes: [...]`
  (created quickfix codes recorded by the fakes). Fill missing `quickfixes`
  with `node test/run.mjs --fix-quickfixes [XXX]` — it never overwrites
  existing entries, so stale values fail loudly instead of being masked.
- Hierarchy checks (`get_super_classes`) resolve the tested class from the
  procedure's `id-main_unit-name`, so fixtures must use realistic class names.
When automated code replacement or removal is appropriate, use the QuickFix API:

1. **Define QuickFix Codes in `c_quickfix_codes` & register in `constructor`:**
   ```abap
   CONSTANTS:
     BEGIN OF c_quickfix_codes,
       replace_syntax TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLACE_ST',
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
   DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.

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
   and validates that the transformed code is syntactically valid via the roundtrip tester.

4. **Preserve Whitespace in String Templates:**
   ABAP string templates require spaces around embedded expressions (`|{ expr }|`).
   Always build template strings using backtick string literals (`` `{ ` `` and `` ` }` ``)
   rather than character literals (`'{ '`), because trailing spaces in character literals
   are automatically truncated in ABAP.

---

## 🚫 The 5 Most Critical Anti-Patterns to Avoid

1. **Custom Type Wrappers / Parallel Interfaces:**
   - *Why:* Wrapping SAP framework types causes drift, lossy mappings, and unnecessary boilerplate. The SAP ATC framework (`if_ci_atc_*`) is the single source of truth.
   - *Fix:* Use `if_ci_atc_source_code_provider`, `if_ci_atc_check`, `if_ci_atc_check_meta_data`, and `cl_ci_atc_quickfixes` types directly.

2. **Assuming Magic Token Indices (`tokens[ 3 ]`):**
   - *Why:* Line breaks, pragmas, comments, or modifier tokens shift indices, causing test failures or `CX_SY_ITAB_LINE_NOT_FOUND` dumps. Furthermore, matching keywords by text alone can misidentify variables or parameters named after ABAP keywords.
   - *Fix:* Always use `zcl_skylint_ast_util` helper methods (`get_token`, `get_token_lexeme`, `find_token_sequence`, etc.). For consecutive tokens, use `find_token_sequence` / `match_token_sequence` instead of manual nested loops. Always verify `references IS INITIAL` when checking for keywords or operators (automatically handled by `zcl_skylint_ast_util`). If manual index access is ever necessary, always verify boundaries first (`IF lines( tokens ) >= N.`).

3. **Trusting the ATC tokenizer over your own parsing:**
   - *Why:* Statement keywords (`COMPUTE`, `+CALL_METHOD`), token boundaries, and compiler
     references come from the SAP ATC provider. Re-tokenizing source text in a check
     duplicates the framework and drifts from it.
   - *Fix:* Consume `is_procedure-statements` as delivered. Normalize only via
     `zcl_skylint_ast_util` helpers with ATC-equivalent semantics.

4. **Parsing Chained Statements (`:`, `,`) or Raw Text for Keywords:**
   - *Why:* The AST unrolls chains into individual statements and tags implicit assignments as `'COMPUTE'` and method calls as `'+CALL_METHOD'`.
   - *Fix:* Rely on `statement-keyword` and normalized statement streams instead of raw punctuation regex.

5. **Inline Declarations & Syntax Non-Compliance:**
   - *Why:* `DATA(...)` or `ASSIGN ... TO FIELD-SYMBOL(...)` fail abaplint rules and compatibility with classic ABAP versions.
   - *Fix:* Always use explicit `DATA` and `FIELD-SYMBOLS` at the top of the method.

---

## 🚀 Step-by-Step Workflow for Adding a Check

Follow this exact procedure when adding or modifying check rules:

1. **Register the Rule in Registry:**
   - Add rule metadata to `scripts/rules-data.mjs` (ID, ruleId in kebab-case, className <= 30 chars, pseudoComment, category).

2. **Create the Check Class & Files:**
   - Create `src/checks/zcl_skylint_XXX.clas.abap` inheriting from `zcl_skylint_check_base`.
   - Create `src/checks/zcl_skylint_XXX.clas.xml` (plain abapGit class XML, no test include).
   - Create `test/fixtures/XXX/source.abap` + `expected.json` for the JS harness (XXX = short class name).

3. **Implement Inspection Logic:**
   - Adhere to the Zero Magic Index and Compiler References standards.
   - Iterate `is_procedure-statements`; use `sy-tabix` for the statement position (ATC statements carry no index).
   - Use `report_statement( is_statement = <ls_statement> iv_finding_code = ... is_quickfix = ls_quickfix )` or `report_token(...)`.
   - Support optional QuickFixes via `quickfix_replace(...)` when appropriate.

4. **Re-index and Regenerate Catalog:**
   - Run `npm run index`
   - The indexer verifies all checks and regenerates `README.md` with accurate QuickFix badges and metadata.

5. **Verify Linter and Tests:**
   - Run `npm test`
   - Ensure `npm run lint` yields `0 issue(s) found`.
   - Ensure all unit tests pass with `Exit code 0`.
