" ======================================================================
" LOCAL CLASS DEFINITIONS
" ======================================================================

CLASS lcl_mock_code_provider DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_ci_atc_source_code_provider.

    METHODS set_procedures
      IMPORTING
        it_procedures TYPE if_ci_atc_source_code_provider=>ty_procedures.

  PRIVATE SECTION.
    DATA mt_procedures TYPE if_ci_atc_source_code_provider=>ty_procedures.
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


CLASS lcl_ast_keyword_helper DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS determine_keyword
      IMPORTING
        it_tokens          TYPE if_ci_atc_source_code_provider=>ty_tokens
        iv_in_chain        TYPE abap_bool
        iv_chain_header_kw TYPE string
      RETURNING
        VALUE(rv_keyword)  TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS is_assignment
      IMPORTING
        it_tokens     TYPE if_ci_atc_source_code_provider=>ty_tokens
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

    CLASS-METHODS is_call_method
      IMPORTING
        it_tokens     TYPE if_ci_atc_source_code_provider=>ty_tokens
      RETURNING
        VALUE(rv_res) TYPE abap_bool.
ENDCLASS.


CLASS lcl_ast_token_builder DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS build_token
      IMPORTING
        is_token            TYPE stokesx
        iv_object_name      TYPE string
        iv_proc_name        TYPE string
      RETURNING
        VALUE(rs_atc_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS extract_pseudo_comment
      IMPORTING
        is_token       TYPE stokesx
      RETURNING
        VALUE(rv_pcom) TYPE string.
ENDCLASS.


CLASS lcl_ast_procedure_builder DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_object_name TYPE string.

    METHODS start_procedure
      IMPORTING
        iv_keyword   TYPE string
        it_tokens    TYPE if_ci_atc_source_code_provider=>ty_tokens
        iv_line      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS add_statement
      IMPORTING
        is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS finish_procedure
      IMPORTING
        iv_keyword          TYPE string
      RETURNING
        VALUE(rs_procedure) TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS is_in_procedure
      RETURNING
        VALUE(rv_in) TYPE abap_bool.

    METHODS get_procedure_name
      RETURNING
        VALUE(rv_name) TYPE string.

  PRIVATE SECTION.
    DATA mv_object_name    TYPE string.
    DATA mv_in_proc        TYPE abap_bool.
    DATA mv_proc_start_row TYPE i.
    DATA ms_procedure      TYPE if_ci_atc_source_code_provider=>ty_procedure.
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


" ======================================================================
" LOCAL CLASS IMPLEMENTATIONS
" ======================================================================

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
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_cls   TYPE string.
    DATA lv_meth  TYPE string.
    DATA lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_part  TYPE string.

    CLEAR procedure.
    LOOP AT calling_token-references INTO ls_ref
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      IF ls_ref-full_name CS '\'.
        SPLIT ls_ref-full_name AT '\' INTO TABLE lt_parts.
        LOOP AT lt_parts INTO lv_part.
          IF lv_part CP 'TY:*'.
            lv_cls = lv_part+3.
          ELSEIF lv_part CP 'ME:*'.
            lv_meth = lv_part+3.
          ENDIF.
        ENDLOOP.
      ELSEIF ls_ref-full_name CS '=>'.
        SPLIT ls_ref-full_name AT '=>' INTO lv_cls lv_meth.
      ELSEIF ls_ref-full_name CS '->'.
        SPLIT ls_ref-full_name AT '->' INTO lv_cls lv_meth.
      ENDIF.

      IF lv_meth IS NOT INITIAL.
        procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-method.
        IF lv_cls IS NOT INITIAL.
          procedure-id-name = |{ lv_cls }=>{ lv_meth }|.
          procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
          procedure-id-main_unit-name = lv_cls.
        ELSE.
          procedure-id-name = lv_meth.
        ENDIF.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_mock_data_provider IMPLEMENTATION.

  METHOD set_code_provider.
    mo_code_provider = io_code_provider.
  ENDMETHOD.

  METHOD get_code_provider.
    code_provider = mo_code_provider.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_ast_keyword_helper IMPLEMENTATION.

  METHOD determine_keyword.
    DATA ls_first_token  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_first_lexeme TYPE string.

    IF iv_in_chain = abap_true AND iv_chain_header_kw IS NOT INITIAL.
      rv_keyword = iv_chain_header_kw.
      RETURN.
    ENDIF.

    IF lines( it_tokens ) = 0.
      rv_keyword = ''.
      RETURN.
    ENDIF.

    READ TABLE it_tokens INTO ls_first_token INDEX 1.
    lv_first_lexeme = to_upper( ls_first_token-lexeme ).

    IF is_assignment( it_tokens ) = abap_true.
      rv_keyword = 'COMPUTE'.
    ELSEIF is_call_method( it_tokens ) = abap_true.
      rv_keyword = '+CALL_METHOD'.
    ELSE.
      rv_keyword = lv_first_lexeme.
    ENDIF.
  ENDMETHOD.

  METHOD is_assignment.
    DATA ls_token            TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_first_lexeme     TYPE string.
    DATA lv_char_cnt         TYPE i.
    DATA lv_char_idx         TYPE i.
    DATA lv_char             TYPE c LENGTH 1.
    DATA lv_paren_depth      TYPE i.
    DATA lv_has_top_level_eq TYPE abap_bool.

    rv_res = abap_false.
    IF lines( it_tokens ) = 0.
      RETURN.
    ENDIF.

    READ TABLE it_tokens INTO ls_token INDEX 1.
    lv_first_lexeme = to_upper( ls_token-lexeme ).

    CASE lv_first_lexeme.
      WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE' OR 'WAIT' OR 'WHEN' OR 'WHERE'
        OR 'UNTIL' OR 'LOOP' OR 'SELECT' OR 'UPDATE' OR 'DELETE' OR 'MODIFY'
        OR 'READ' OR 'ASSERT' OR 'AUTHORITY-CHECK' OR 'RAISE' OR 'CALL'
        OR 'PERFORM' OR 'SUBMIT' OR 'SET' OR 'GET' OR 'ASSIGN' OR 'DESCRIBE'
        OR 'MESSAGE' OR 'CONSTANTS' OR 'DATA' OR 'TYPES' OR 'STATICS'
        OR 'CLASS-DATA' OR 'FIELD-SYMBOLS'.
        RETURN.
    ENDCASE.

    LOOP AT it_tokens INTO ls_token.
      lv_char_cnt = strlen( ls_token-lexeme ).
      lv_char_idx = 0.
      WHILE lv_char_idx < lv_char_cnt.
        lv_char = ls_token-lexeme+lv_char_idx(1).
        CASE lv_char.
          WHEN '(' OR '[' OR '{'.
            lv_paren_depth = lv_paren_depth + 1.
          WHEN ')' OR ']' OR '}'.
            IF lv_paren_depth > 0.
              lv_paren_depth = lv_paren_depth - 1.
            ENDIF.
          WHEN '='.
            IF lv_paren_depth = 0.
              lv_has_top_level_eq = abap_true.
            ENDIF.
        ENDCASE.
        lv_char_idx = lv_char_idx + 1.
      ENDWHILE.
    ENDLOOP.

    rv_res = lv_has_top_level_eq.
  ENDMETHOD.

  METHOD is_call_method.
    DATA ls_tok1         TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok2         TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_first_lexeme TYPE string.

    rv_res = abap_false.
    IF lines( it_tokens ) = 0.
      RETURN.
    ENDIF.

    READ TABLE it_tokens INTO ls_tok1 INDEX 1.
    lv_first_lexeme = to_upper( ls_tok1-lexeme ).

    CASE lv_first_lexeme.
      WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE' OR 'LOOP' OR 'SELECT'
        OR 'WHEN' OR 'WHERE' OR 'DATA' OR 'TYPES' OR 'CONSTANTS'
        OR 'VALUE' OR 'NEW' OR 'COND' OR 'SWITCH' OR 'LINES' OR 'LINES('.
        RETURN.
    ENDCASE.

    IF lv_first_lexeme CP '*('.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    IF lines( it_tokens ) >= 2.
      READ TABLE it_tokens INTO ls_tok2 INDEX 2.
      IF to_upper( ls_tok2-lexeme ) CP '(*'.
        rv_res = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_ast_token_builder IMPLEMENTATION.

  METHOD build_token.
    DATA ls_ref       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_var_name  TYPE string.
    DATA lv_tok_upper TYPE string.
    DATA lv_cls       TYPE string.
    DATA lv_meth      TYPE string.
    DATA lv_len       TYPE i.

    rs_atc_token-lexeme = is_token-str.
    rs_atc_token-position-line = is_token-row.
    rs_atc_token-position-column = is_token-col.

    lv_tok_upper = to_upper( is_token-str ).

    IF lv_tok_upper CS '=>'.
      SPLIT lv_tok_upper AT '=>' INTO lv_cls lv_meth.
      IF lv_meth CP '*('.
        lv_len = strlen( lv_meth ) - 1.
        lv_meth = lv_meth(lv_len).
      ENDIF.

      " 1. Reference to Class / Type
      ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
      ls_ref-full_name = |\\TY:{ lv_cls }|.
      ls_ref-usage_grade = 'DIRECT'.
      CLEAR ls_ref-usage_mode.
      INSERT ls_ref INTO TABLE rs_atc_token-references.

      " 2. Reference to Method
      ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      ls_ref-full_name = |\\TY:{ lv_cls }\\ME:{ lv_meth }|.
      ls_ref-usage_grade = 'DIRECT'.
      ls_ref-usage_mode = 'READ'.
      INSERT ls_ref INTO TABLE rs_atc_token-references.
    ELSEIF lv_tok_upper CS '->'.
      SPLIT lv_tok_upper AT '->' INTO lv_cls lv_meth.
      IF lv_meth CP '*('.
        lv_len = strlen( lv_meth ) - 1.
        lv_meth = lv_meth(lv_len).
      ENDIF.

      ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      IF lv_cls = 'ME'.
        ls_ref-full_name = |\\TY:{ iv_object_name }\\ME:{ lv_meth }|.
      ELSE.
        ls_ref-full_name = |{ lv_cls }->{ lv_meth }|.
      ENDIF.
      ls_ref-usage_grade = 'DIRECT'.
      ls_ref-usage_mode = 'READ'.
      INSERT ls_ref INTO TABLE rs_atc_token-references.
    ELSEIF lv_tok_upper CP 'DATA(*)' OR lv_tok_upper CP '@DATA(*)'.
      lv_var_name = lv_tok_upper.
      IF lv_var_name CP '@*'.
        lv_var_name = lv_var_name+1.
      ENDIF.
      lv_var_name = lv_var_name+5.
      lv_len = strlen( lv_var_name ) - 1.
      IF lv_len > 0.
        lv_var_name = lv_var_name(lv_len).
      ENDIF.
      ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      ls_ref-full_name = |\\TY:{ iv_object_name }\\ME:{ iv_proc_name }\\DA:{ lv_var_name }|.
      ls_ref-usage_grade = 'DEFINITION'.
      ls_ref-usage_mode = 'DEFINITION_WITH_WRITE'.
      INSERT ls_ref INTO TABLE rs_atc_token-references.
    ELSEIF lv_tok_upper CP 'FIELD-SYMBOL(*)' OR lv_tok_upper CP 'FIELD-SYMBOLS(*)'.
      lv_var_name = lv_tok_upper.
      IF lv_var_name CP 'FIELD-SYMBOLS(*)'.
        lv_var_name = lv_var_name+14.
      ELSE.
        lv_var_name = lv_var_name+13.
      ENDIF.
      lv_len = strlen( lv_var_name ) - 1.
      IF lv_len > 0.
        lv_var_name = lv_var_name(lv_len).
      ENDIF.
      ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      ls_ref-full_name = |\\TY:{ iv_object_name }\\ME:{ iv_proc_name }\\DA:{ lv_var_name }|.
      ls_ref-usage_grade = 'DEFINITION'.
      ls_ref-usage_mode = 'DEFINITION_WITH_WRITE'.
      INSERT ls_ref INTO TABLE rs_atc_token-references.
    ENDIF.
  ENDMETHOD.

  METHOD extract_pseudo_comment.
    rv_pcom = ''.
    IF is_token-type = 'C' AND is_token-str CP '"#EC *'.
      rv_pcom = is_token-str+5.
      CONDENSE rv_pcom.
    ELSEIF is_token-type = 'P' OR is_token-str CP '##*'.
      rv_pcom = is_token-str+2.
      CONDENSE rv_pcom.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_ast_procedure_builder IMPLEMENTATION.

  METHOD constructor.
    mv_object_name = iv_object_name.
    mv_in_proc = abap_false.
  ENDMETHOD.

  METHOD is_in_procedure.
    rv_in = mv_in_proc.
  ENDMETHOD.

  METHOD get_procedure_name.
    rv_name = ms_procedure-id-name.
  ENDMETHOD.

  METHOD start_procedure.
    DATA ls_name_token TYPE if_ci_atc_source_code_provider=>ty_token.
    rv_ok = abap_false.

    CASE iv_keyword.
      WHEN 'METHOD'.
        CLEAR ms_procedure.
        mv_in_proc = abap_true.
        mv_proc_start_row = iv_line.
        ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-method.
        READ TABLE it_tokens INTO ls_name_token INDEX 2.
        IF sy-subrc = 0.
          ms_procedure-id-name = |{ mv_object_name }=>{ to_upper( ls_name_token-lexeme ) }|.
        ENDIF.
        ms_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ms_procedure-id-main_unit-name = mv_object_name.
        rv_ok = abap_true.

      WHEN 'FORM'.
        CLEAR ms_procedure.
        mv_in_proc = abap_true.
        mv_proc_start_row = iv_line.
        ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-form_routine.
        READ TABLE it_tokens INTO ls_name_token INDEX 2.
        IF sy-subrc = 0.
          ms_procedure-id-name = to_upper( ls_name_token-lexeme ).
        ENDIF.
        ms_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ms_procedure-id-main_unit-name = mv_object_name.
        rv_ok = abap_true.

      WHEN 'FUNCTION'.
        CLEAR ms_procedure.
        mv_in_proc = abap_true.
        mv_proc_start_row = iv_line.
        ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-function.
        READ TABLE it_tokens INTO ls_name_token INDEX 2.
        IF sy-subrc = 0.
          ms_procedure-id-name = to_upper( ls_name_token-lexeme ).
        ENDIF.
        ms_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ms_procedure-id-main_unit-name = mv_object_name.
        rv_ok = abap_true.

      WHEN 'MODULE'.
        CLEAR ms_procedure.
        mv_in_proc = abap_true.
        mv_proc_start_row = iv_line.
        ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-module_in.
        READ TABLE it_tokens INTO ls_name_token INDEX 2.
        IF sy-subrc = 0.
          ms_procedure-id-name = to_upper( ls_name_token-lexeme ).
        ENDIF.
        ms_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
        ms_procedure-id-main_unit-name = mv_object_name.
        rv_ok = abap_true.

      WHEN 'CLASS'.
        IF mv_in_proc = abap_false AND lines( it_tokens ) >= 3.
          IF to_upper( it_tokens[ 3 ]-lexeme ) = 'DEFINITION'.
            CLEAR ms_procedure.
            mv_in_proc = abap_true.
            mv_proc_start_row = iv_line.
            ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
            ms_procedure-id-name = '0'.
            ms_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
            ms_procedure-id-main_unit-name = mv_object_name.
            rv_ok = abap_true.
          ENDIF.
        ENDIF.

      WHEN 'INTERFACE'.
        IF mv_in_proc = abap_false.
          CLEAR ms_procedure.
          mv_in_proc = abap_true.
          mv_proc_start_row = iv_line.
          ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
          ms_procedure-id-name = '0'.
          ms_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-interface.
          ms_procedure-id-main_unit-name = mv_object_name.
          rv_ok = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD add_statement.
    DATA ls_rel_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_prev_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_last_idx TYPE i.

    IF mv_in_proc = abap_false.
      RETURN.
    ENDIF.

    IF lines( is_statement-tokens ) = 0.
      IF lines( is_statement-pseudo_comments ) > 0 AND lines( ms_procedure-statements ) > 0.
        lv_last_idx = lines( ms_procedure-statements ).
        ASSIGN ms_procedure-statements[ lv_last_idx ] TO <ls_prev_stmt>.
        IF sy-subrc = 0.
          INSERT LINES OF is_statement-pseudo_comments INTO TABLE <ls_prev_stmt>-pseudo_comments.
        ENDIF.
      ENDIF.
    ELSE.
      ls_rel_stmt = is_statement.
      ls_rel_stmt-position-line = ls_rel_stmt-position-line - mv_proc_start_row + 1.
      LOOP AT ls_rel_stmt-tokens ASSIGNING <ls_tok>.
        <ls_tok>-position-line = <ls_tok>-position-line - mv_proc_start_row + 1.
      ENDLOOP.
      APPEND ls_rel_stmt TO ms_procedure-statements.
    ENDIF.
  ENDMETHOD.

  METHOD finish_procedure.
    CLEAR rs_procedure.
    IF    iv_keyword = 'ENDMETHOD'
       OR iv_keyword = 'ENDFORM'
       OR iv_keyword = 'ENDFUNCTION'
       OR iv_keyword = 'ENDMODULE'
       OR ( iv_keyword = 'ENDCLASS' AND ms_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition )
       OR iv_keyword = 'ENDINTERFACE'.
      mv_in_proc = abap_false.
      rs_procedure = ms_procedure.
      CLEAR ms_procedure.
    ENDIF.
  ENDMETHOD.

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

    CLEAR lv_source.
    lv_name = object-name.

    WRITE '@KERNEL if (!globalThis.__abapClassIncludes) {'.
      WRITE '@KERNEL   const fs = await import("fs");'.
      WRITE '@KERNEL   const path = await import("path");'.
      WRITE '@KERNEL   globalThis.__abapClassIncludes = new Map();'.
      WRITE '@KERNEL   function indexDir(dir) {'.
      WRITE '@KERNEL     if (!fs.existsSync(dir)) return;'.
      WRITE '@KERNEL     const entries = fs.readdirSync(dir, { withFileTypes: true });'.
      WRITE '@KERNEL     for (const entry of entries) {'.
      WRITE '@KERNEL       const fullPath = path.join(dir, entry.name);'.
      WRITE '@KERNEL       if (entry.isDirectory()) {'.
      WRITE '@KERNEL         indexDir(fullPath);'.
      WRITE '@KERNEL       } else if (entry.isFile() && entry.name.toLowerCase().endsWith(".abap")) {'.
      WRITE '@KERNEL         const m = entry.name.match(/^([^.]+)\.clas(\.locals_def|\.locals_imp)?\.abap$/i);'.
      WRITE '@KERNEL         if (m) {'.
      WRITE '@KERNEL           const className = m[1].toLowerCase().replace(/[^a-z0-9_]/g, "");'.
      WRITE '@KERNEL           const type = m[2] ? m[2].toLowerCase().replace(".", "") : "main";'.
      WRITE '@KERNEL           if (!globalThis.__abapClassIncludes.has(className)) {'.
      WRITE '@KERNEL             globalThis.__abapClassIncludes.set(className, {});'.
      WRITE '@KERNEL           }'.
      WRITE '@KERNEL           globalThis.__abapClassIncludes.get(className)[type] = fullPath;'.
      WRITE '@KERNEL         } else {'.
      WRITE '@KERNEL           const base = entry.name.toLowerCase().replace(/\.(clas|prog|fugr|intf)?\.abap$/i, "").replace(/[^a-z0-9_]/g, "");'.
      WRITE '@KERNEL           if (!globalThis.__abapClassIncludes.has(base)) {'.
      WRITE '@KERNEL             globalThis.__abapClassIncludes.set(base, {});'.
      WRITE '@KERNEL           }'.
      WRITE '@KERNEL           globalThis.__abapClassIncludes.get(base)["main"] = fullPath;'.
      WRITE '@KERNEL         }'.
      WRITE '@KERNEL       }'.
      WRITE '@KERNEL     }'.
      WRITE '@KERNEL   }'.
      WRITE '@KERNEL   indexDir(path.join(process.cwd(), "src"));'.
      WRITE '@KERNEL }'.
      WRITE '@KERNEL const fs = await import("fs");'.
      WRITE '@KERNEL const lookupKey = lv_name.get().toLowerCase().replace(/[^a-z0-9_]/g, "");'.
      WRITE '@KERNEL const classInfo = globalThis.__abapClassIncludes.get(lookupKey);'.
      WRITE '@KERNEL if (classInfo) {'.
      WRITE '@KERNEL   let combined = "";'.
      WRITE '@KERNEL   if (classInfo.locals_def && fs.existsSync(classInfo.locals_def)) {'.
      WRITE '@KERNEL     combined += fs.readFileSync(classInfo.locals_def, "utf8") + "\n";'.
      WRITE '@KERNEL   }'.
      WRITE '@KERNEL   if (classInfo.main && fs.existsSync(classInfo.main)) {'.
      WRITE '@KERNEL     combined += fs.readFileSync(classInfo.main, "utf8") + "\n";'.
      WRITE '@KERNEL   }'.
      WRITE '@KERNEL   if (classInfo.locals_imp && fs.existsSync(classInfo.locals_imp)) {'.
      WRITE '@KERNEL     combined += fs.readFileSync(classInfo.locals_imp, "utf8") + "\n";'.
      WRITE '@KERNEL   }'.
      WRITE '@KERNEL   lv_source.set(combined);'.
      WRITE '@KERNEL } else {'.
      WRITE '@KERNEL   lv_source.set("");'.
      WRITE '@KERNEL }'.

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
    DATA lo_proc_mgr         TYPE REF TO lcl_ast_procedure_builder.
    DATA lv_in_chain         TYPE abap_bool.
    DATA lv_chain_header_kw  TYPE string.
    DATA ls_chain_header_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_tok_idx          TYPE i.
    DATA lv_pcom             TYPE string.
    DATA lv_first_token      TYPE abap_bool.

    CREATE OBJECT lo_proc_mgr
      EXPORTING
        iv_object_name = iv_object_name.

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

      " Prepend chain header token if inside chained statement
      IF lv_in_chain = abap_true AND ls_chain_header_tok-lexeme IS NOT INITIAL.
        INSERT ls_chain_header_tok INTO TABLE ls_statement-tokens.
      ENDIF.

      lv_tok_idx = ls_stmnt-from.
      WHILE lv_tok_idx <= ls_stmnt-to.
        READ TABLE lt_tokens INTO ls_token INDEX lv_tok_idx.
        IF sy-subrc = 0.
          lv_pcom = lcl_ast_token_builder=>extract_pseudo_comment( ls_token ).
          IF lv_pcom IS NOT INITIAL.
            INSERT lv_pcom INTO TABLE ls_statement-pseudo_comments.
          ENDIF.

          IF ls_token-type <> 'C'.
            ls_atc_token = lcl_ast_token_builder=>build_token(
                             is_token       = ls_token
                             iv_object_name = iv_object_name
                             iv_proc_name   = lo_proc_mgr->get_procedure_name( ) ).

            IF lv_first_token = abap_true.
              ls_statement-position-line = ls_token-row.
              ls_statement-position-column = ls_token-col.
              lv_first_token = abap_false.
            ENDIF.

            INSERT ls_atc_token INTO TABLE ls_statement-tokens.
          ENDIF.
        ENDIF.
        lv_tok_idx = lv_tok_idx + 1.
      ENDWHILE.

      " Resolve Keyword
      ls_statement-keyword = lcl_ast_keyword_helper=>determine_keyword(
                               it_tokens          = ls_statement-tokens
                               iv_in_chain        = lv_in_chain
                               iv_chain_header_kw = lv_chain_header_kw ).

      " Manage Chain State
      IF ls_stmnt-terminator = ','.
        IF lv_in_chain = abap_false.
          lv_in_chain = abap_true.
          lv_chain_header_kw = ls_statement-keyword.
          IF lines( ls_statement-tokens) > 0.
            ls_chain_header_tok = ls_statement-tokens[ 1 ].
          ENDIF.
        ENDIF.
      ELSE.
        lv_in_chain = abap_false.
        CLEAR lv_chain_header_kw.
        CLEAR ls_chain_header_tok.
      ENDIF.

      " Check if procedure starts
      lo_proc_mgr->start_procedure(
        iv_keyword = ls_statement-keyword
        it_tokens  = ls_statement-tokens
        iv_line    = ls_statement-position-line ).

      " Add statement to active procedure
      lo_proc_mgr->add_statement( ls_statement ).

      " Check if procedure ends
      ls_procedure = lo_proc_mgr->finish_procedure( ls_statement-keyword ).
      IF ls_procedure-id-kind IS NOT INITIAL.
        APPEND ls_procedure TO rt_procedures.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

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
