CLASS lcl_mock_code_provider DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_ci_atc_source_code_provider.

    METHODS set_procedures
      IMPORTING
        it_procedures TYPE if_ci_atc_source_code_provider=>ty_procedures.

  PRIVATE SECTION.
    DATA mt_procedures TYPE if_ci_atc_source_code_provider=>ty_procedures.
ENDCLASS.

CLASS lcl_mock_code_provider IMPLEMENTATION.

  METHOD set_procedures.
    mt_procedures = it_procedures.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_procedures.
    CREATE DATA procedures.
    procedures->* = mt_procedures.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~object_to_comp_unit.
    compilation_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
    compilation_unit-name = object-name.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_statement_location.
    location-position = statement-position.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_statement_checksum.
    checksum = 0.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_called_procedure.
    RETURN.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_mock_data_provider DEFINITION INHERITING FROM cl_ci_atc_data_provider FINAL.
  PUBLIC SECTION.
    METHODS set_code_provider
      IMPORTING
        io_code_provider TYPE REF TO if_ci_atc_source_code_provider.

    METHODS get_code_provider REDEFINITION.

  PRIVATE SECTION.
    DATA mo_code_provider TYPE REF TO if_ci_atc_source_code_provider.
ENDCLASS.

CLASS lcl_mock_data_provider IMPLEMENTATION.

  METHOD set_code_provider.
    mo_code_provider = io_code_provider.
  ENDMETHOD.

  METHOD get_code_provider.
    code_provider = mo_code_provider.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_ci_atc_unit_asserter DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_ci_atc_unit_asserter.

  PRIVATE SECTION.
    METHODS build_procedures_from_source
      IMPORTING
        iv_source            TYPE string
        iv_object_name       TYPE string
      RETURNING
        VALUE(rt_procedures) TYPE if_ci_atc_source_code_provider=>ty_procedures.
ENDCLASS.

CLASS lcl_ci_atc_unit_asserter IMPLEMENTATION.

  METHOD if_ci_atc_unit_asserter~check_and_assert.
    DATA lv_source        TYPE string.
    DATA lv_name          TYPE string.
    DATA lo_code_provider TYPE REF TO lcl_mock_code_provider.
    DATA lo_data_provider TYPE REF TO lcl_mock_data_provider.
    DATA lo_factory       TYPE REF TO cl_ci_atc_assistant_factory.
    DATA lt_procedures    TYPE if_ci_atc_source_code_provider=>ty_procedures.
    DATA lt_actual        TYPE if_ci_atc_check=>ty_findings.
    DATA lt_filtered      TYPE if_ci_atc_check=>ty_findings.
    DATA ls_exp           TYPE if_ci_atc_unit_asserter=>ty_expected_finding.
    DATA ls_act           TYPE if_ci_atc_check=>ty_finding.
    DATA lv_found         TYPE abap_bool.
    DATA lv_msg           TYPE string.

    DATA lt_source_lines  TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_line          TYPE string.

    lv_name = object-name.

    READ REPORT lv_name INTO lt_source_lines.
    IF sy-subrc = 0 AND lines( lt_source_lines ) > 0.
      LOOP AT lt_source_lines INTO lv_line.
        IF lv_source IS INITIAL.
          lv_source = lv_line.
        ELSE.
          lv_source = |{ lv_source }\n{ lv_line }|.
        ENDIF.
      ENDLOOP.
    ELSE.
      WRITE '@KERNEL if (!globalThis.__abapFileMap) {'.
      WRITE '@KERNEL   const fs = await import("fs");'.
      WRITE '@KERNEL   const path = await import("path");'.
      WRITE '@KERNEL   globalThis.__abapFileMap = new Map();'.
      WRITE '@KERNEL   function indexDir(dir) {'.
      WRITE '@KERNEL     if (!fs.existsSync(dir)) return;'.
      WRITE '@KERNEL     const entries = fs.readdirSync(dir, { withFileTypes: true });'.
      WRITE '@KERNEL     for (const entry of entries) {'.
      WRITE '@KERNEL       const fullPath = path.join(dir, entry.name);'.
      WRITE '@KERNEL       if (entry.isDirectory()) {'.
      WRITE '@KERNEL         indexDir(fullPath);'.
      WRITE '@KERNEL       } else if (entry.isFile() && entry.name.toLowerCase().endsWith(".abap")) {'.
      WRITE '@KERNEL         const baseName = entry.name.toLowerCase().replace(/\.(clas|prog|fugr)?\.abap$/, "");'.
      WRITE '@KERNEL         const key = baseName.replace(/[^a-z0-9_]/g, "");'.
      WRITE '@KERNEL         globalThis.__abapFileMap.set(key, fullPath);'.
      WRITE '@KERNEL       }'.
      WRITE '@KERNEL     }'.
      WRITE '@KERNEL   }'.
      WRITE '@KERNEL   indexDir(path.join(process.cwd(), "src"));'.
      WRITE '@KERNEL }'.
      WRITE '@KERNEL const fs = await import("fs");'.
      WRITE '@KERNEL const lookupKey = lv_name.get().toLowerCase().replace(/[^a-z0-9_]/g, "");'.
      WRITE '@KERNEL const targetPath = globalThis.__abapFileMap.get(lookupKey);'.
      WRITE '@KERNEL if (targetPath) {'.
      WRITE '@KERNEL   lv_source.set(fs.readFileSync(targetPath, "utf8"));'.
      WRITE '@KERNEL } else {'.
      WRITE '@KERNEL   lv_source.set("");'.
      WRITE '@KERNEL }'.
    ENDIF.

    lt_procedures = build_procedures_from_source(
      iv_source      = lv_source
      iv_object_name = lv_name ).

    CREATE OBJECT lo_code_provider.
    lo_code_provider->set_procedures( lt_procedures ).

    CREATE OBJECT lo_data_provider.
    lo_data_provider->set_code_provider( lo_code_provider ).

    CREATE OBJECT lo_factory.
    check->set_assistant_factory( lo_factory ).

    lt_actual = check->run(
      data_provider = lo_data_provider
      object        = object ).

    IF asserter_config-remove_findings_with_pcoms = abap_true.
      LOOP AT lt_actual INTO ls_act WHERE has_pseudo_comment = abap_false.
        INSERT ls_act INTO TABLE lt_filtered.
      ENDLOOP.
      lt_actual = lt_filtered.
    ENDIF.

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_actual )
      exp = lines( expected_findings )
      msg = 'ATC findings count does not match expected' ).

    LOOP AT expected_findings INTO ls_exp.
      lv_found = abap_false.
      LOOP AT lt_actual INTO ls_act WHERE code = ls_exp-code.
        IF ls_act-location-position-line = ls_exp-location-position-line.
          IF ls_exp-location-position-column = 0 OR ls_act-location-position-column = ls_exp-location-position-column.
            lv_found = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.

      lv_msg = |Expected finding { ls_exp-code } at line { ls_exp-location-position-line } not found in actual ATC findings|.
      cl_abap_unit_assert=>assert_equals(
        act = lv_found
        exp = abap_true
        msg = lv_msg ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_procedures_from_source.
    DATA lt_tokens           TYPE STANDARD TABLE OF stokesx WITH DEFAULT KEY.
    DATA lt_stmnts           TYPE STANDARD TABLE OF sstmnt WITH DEFAULT KEY.
    DATA ls_stmnt            TYPE sstmnt.
    DATA ls_token            TYPE stokesx.
    DATA ls_statement        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_atc_token        TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_procedure        TYPE if_ci_atc_source_code_provider=>ty_procedure.
    FIELD-SYMBOLS <ls_stmt_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_in_proc          TYPE abap_bool.
    DATA lv_first_token      TYPE abap_bool.
    DATA lv_tok_idx          TYPE i.
    DATA lv_proc_start_row   TYPE i.
    DATA lv_rel_row          TYPE i.
    DATA lv_pc_str           TYPE string.

    DATA lt_src_lines        TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_src_line         TYPE string.

    SPLIT iv_source AT |\n| INTO TABLE lt_src_lines.

    SCAN ABAP-SOURCE iv_source
      TOKENS INTO lt_tokens
      STATEMENTS INTO lt_stmnts
      WITH ANALYSIS
      WITH COMMENTS
      WITH PRAGMAS '*'
      WITH INCLUDES.

    LOOP AT lt_stmnts INTO ls_stmnt.
      CLEAR ls_statement.
      lv_first_token = abap_true.

      lv_tok_idx = ls_stmnt-from.
      WHILE lv_tok_idx <= ls_stmnt-to.
        READ TABLE lt_tokens INTO ls_token INDEX lv_tok_idx.
        IF sy-subrc = 0.
          IF ls_token-type = 'C'.
            IF ls_token-str CP '"#EC *'.
              lv_pc_str = ls_token-str+5.
              CONDENSE lv_pc_str.
              INSERT lv_pc_str INTO TABLE ls_statement-pseudo_comments.
            ENDIF.
          ELSEIF ls_token-type = 'P' OR ls_token-str CP '##*'.
            lv_pc_str = ls_token-str+2.
            CONDENSE lv_pc_str.
            INSERT lv_pc_str INTO TABLE ls_statement-pseudo_comments.

            CLEAR ls_atc_token.
            ls_atc_token-lexeme = ls_token-str.
            ls_atc_token-position-line = ls_token-row.
            ls_atc_token-position-column = ls_token-col.
            INSERT ls_atc_token INTO TABLE ls_statement-tokens.
          ELSE.
            IF lv_first_token = abap_true.
              ls_statement-keyword = to_upper( ls_token-str ).
              ls_statement-position-line = ls_token-row.
              ls_statement-position-column = ls_token-col.
              lv_first_token = abap_false.
            ENDIF.

            CLEAR ls_atc_token.
            ls_atc_token-lexeme = ls_token-str.
            ls_atc_token-position-line = ls_token-row.
            ls_atc_token-position-column = ls_token-col.
            INSERT ls_atc_token INTO TABLE ls_statement-tokens.
          ENDIF.
        ENDIF.
        lv_tok_idx = lv_tok_idx + 1.
      ENDWHILE.

      READ TABLE lt_src_lines INTO lv_src_line INDEX ls_statement-position-line.
      IF sy-subrc = 0.
        IF ( to_upper( lv_src_line ) CP |*{ ls_statement-keyword }:*|
             OR to_upper( lv_src_line ) CP |*{ ls_statement-keyword } :*|
             OR ls_stmnt-terminator = ',' )
           AND lines( ls_statement-tokens ) >= 1.
          READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 2.
          IF sy-subrc <> 0 OR ls_atc_token-lexeme <> ':'.
            CLEAR ls_atc_token.
            ls_atc_token-lexeme = ':'.
            ls_atc_token-position-line = ls_statement-position-line.
            ls_atc_token-position-column = ls_statement-position-column.
            INSERT ls_atc_token INTO ls_statement-tokens INDEX 2.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_statement-keyword = 'METHOD'.
        CLEAR ls_procedure.
        lv_in_proc = abap_true.
        lv_proc_start_row = ls_statement-position-line.
        ls_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-method.
        READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 2.
        IF sy-subrc = 0.
          ls_procedure-id-name = to_upper( ls_atc_token-lexeme ).
        ENDIF.
        ls_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ls_procedure-id-main_unit-name = iv_object_name.
      ELSEIF ls_statement-keyword = 'FORM'.
        CLEAR ls_procedure.
        lv_in_proc = abap_true.
        lv_proc_start_row = ls_statement-position-line.
        ls_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-form_routine.
        READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 2.
        IF sy-subrc = 0.
          ls_procedure-id-name = to_upper( ls_atc_token-lexeme ).
        ENDIF.
        ls_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ls_procedure-id-main_unit-name = iv_object_name.
      ELSEIF ls_statement-keyword = 'FUNCTION'.
        CLEAR ls_procedure.
        lv_in_proc = abap_true.
        lv_proc_start_row = ls_statement-position-line.
        ls_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-function.
        READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 2.
        IF sy-subrc = 0.
          ls_procedure-id-name = to_upper( ls_atc_token-lexeme ).
        ENDIF.
        ls_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ls_procedure-id-main_unit-name = iv_object_name.
      ELSEIF ls_statement-keyword = 'MODULE'.
        CLEAR ls_procedure.
        lv_in_proc = abap_true.
        lv_proc_start_row = ls_statement-position-line.
        ls_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-module_in.
        READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 2.
        IF sy-subrc = 0.
          ls_procedure-id-name = to_upper( ls_atc_token-lexeme ).
        ENDIF.
        ls_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ls_procedure-id-main_unit-name = iv_object_name.
      ELSEIF ls_statement-keyword = 'CLASS' AND lv_in_proc = abap_false.
        READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 3.
        IF sy-subrc = 0 AND to_upper( ls_atc_token-lexeme ) = 'DEFINITION'.
          CLEAR ls_procedure.
          lv_in_proc = abap_true.
          lv_proc_start_row = ls_statement-position-line.
          ls_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
          READ TABLE ls_statement-tokens INTO ls_atc_token INDEX 2.
          IF sy-subrc = 0.
            ls_procedure-id-name = to_upper( ls_atc_token-lexeme ).
          ENDIF.
          ls_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
          ls_procedure-id-main_unit-name = iv_object_name.
        ENDIF.
      ENDIF.

      IF lv_in_proc = abap_true.
        lv_rel_row = ls_statement-position-line - lv_proc_start_row + 1.
        ls_statement-position-line = lv_rel_row.
        LOOP AT ls_statement-tokens ASSIGNING <ls_stmt_tok>.
          <ls_stmt_tok>-position-line = <ls_stmt_tok>-position-line - lv_proc_start_row + 1.
        ENDLOOP.
        APPEND ls_statement TO ls_procedure-statements.
      ENDIF.

      IF    ls_statement-keyword = 'ENDMETHOD'
         OR ls_statement-keyword = 'ENDFORM'
         OR ls_statement-keyword = 'ENDFUNCTION'
         OR ls_statement-keyword = 'ENDMODULE'
         OR ( ls_statement-keyword = 'ENDCLASS' AND ls_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition ).
        lv_in_proc = abap_false.
        APPEND ls_procedure TO rt_procedures.
        CLEAR ls_procedure.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_ci_atc_unit_test_case DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_ci_atc_unit_test_case.

    METHODS constructor
      IMPORTING
        io_check  TYPE REF TO if_ci_atc_check
        is_object TYPE if_ci_atc_check=>ty_object.

  PRIVATE SECTION.
    DATA mo_check  TYPE REF TO if_ci_atc_check.
    DATA ms_object TYPE if_ci_atc_check=>ty_object.
ENDCLASS.

CLASS lcl_ci_atc_unit_test_case IMPLEMENTATION.

  METHOD constructor.
    mo_check = io_check.
    ms_object = is_object.
  ENDMETHOD.

  METHOD if_ci_atc_unit_test_case~execute_and_assert.
    cl_ci_atc_unit_driver=>create_asserter( )->check_and_assert(
      check             = mo_check
      object            = ms_object
      expected_findings = expected_findings
      asserter_config   = asserter_config ).
  ENDMETHOD.

ENDCLASS.
