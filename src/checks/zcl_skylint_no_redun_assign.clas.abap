CLASS zcl_skylint_no_redun_assign DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_move  TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_IDN_MOV',
        redundant_clear TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RED_CLR',
        clear_at_end    TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CLR_END',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        delete_self  TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DELIDENT',
        remove_clear TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'RMV_CLEAR',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_self  TYPE string VALUE 'NO_IDENTICAL_MOVE'.
    CONSTANTS c_pseudo_comment_clear TYPE string VALUE 'NO_REDUNDANT_CLEAR'.

    DATA mv_check_self_assign  TYPE abap_bool VALUE abap_true.
    DATA mv_check_before_write TYPE abap_bool VALUE abap_true.
    DATA mv_check_without_read TYPE abap_bool VALUE abap_true.

    TYPES:
      BEGIN OF ty_variable_decl,
        full_name TYPE string,
        stmt_idx  TYPE i,
        has_value TYPE abap_bool,
      END OF ty_variable_decl,
      ty_variable_decls TYPE STANDARD TABLE OF ty_variable_decl WITH EMPTY KEY.

    METHODS get_written_symbol
      IMPORTING is_token         TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS get_read_symbol
      IMPORTING is_token         TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS is_identical_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_identical_move
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS find_move_to
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_idx) TYPE i.

    METHODS collect_declarations
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rt_decls) TYPE ty_variable_decls.

    METHODS is_variable_written
      IMPORTING it_statements     TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_from_idx       TYPE i
                iv_to_idx         TYPE i
                iv_full_name      TYPE string
      RETURNING VALUE(rv_written) TYPE abap_bool.

    METHODS is_variable_read
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_from_idx    TYPE i
                iv_to_idx      TYPE i
                iv_full_name   TYPE string
      RETURNING VALUE(rv_read) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_redun_assign IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Remove Redundant Assignments & CLEARs'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-identical_move
                       text           = 'Identical assignment has no effect; remove redundant statement'
                       pseudo_comment = c_pseudo_comment_self )
                     ( code           = c_finding_codes-redundant_clear
                       text           = 'Do not CLEAR or FREE variables after declaration; they are already initial'
                       pseudo_comment = c_pseudo_comment_clear )
                     ( code           = c_finding_codes-clear_at_end
                       text           = 'Variable is CLEARed or FREEd but never read again before procedure ends'
                       pseudo_comment = c_pseudo_comment_clear ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-delete_self
                                                short_text = 'Delete self-assignment' )
                                              ( code       = c_quickfix_codes-remove_clear
                                                short_text = 'Remove redundant statement' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_SELF_ASSIGN'
                                                value = REF #( mv_check_self_assign ) )
                                              ( name  = 'CHECK_BEFORE_WRITE'
                                                value = REF #( mv_check_before_write ) )
                                              ( name  = 'CHECK_WITHOUT_READ'
                                                value = REF #( mv_check_without_read ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_identical  TYPE abap_bool.
    DATA lv_loop_depth TYPE i.
    DATA lt_decls      TYPE ty_variable_decls.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_decl>      TYPE ty_variable_decl.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lt_decls = collect_declarations( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth += 1.
        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_loop_depth > 0.
            lv_loop_depth -= 1.
          ENDIF.
      ENDCASE.

      IF mv_check_self_assign = abap_true.
        lv_identical = abap_false.
        CASE <ls_statement>-keyword.
          WHEN 'COMPUTE'.
            lv_identical = is_identical_assignment( <ls_statement> ).
          WHEN 'MOVE'.
            lv_identical = is_identical_move( <ls_statement> ).
        ENDCASE.

        IF lv_identical = abap_true.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-delete_self
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ) ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-identical_move
                            is_quickfix     = ls_quickfix ).
          CONTINUE.
        ENDIF.
      ENDIF.

      IF NOT ( ( <ls_statement>-keyword = 'CLEAR' OR <ls_statement>-keyword = 'FREE' ) AND lv_loop_depth = 0 ).
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'WITH' ) = abap_true.
        CONTINUE.
      ENDIF.

      ls_ref = zcl_skylint_ast_util=>statement_get_reference(
                   is_statement = <ls_statement>
                   iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF ls_ref-full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN lt_decls[ full_name = ls_ref-full_name ] TO <ls_decl>.
      IF sy-subrc = 0 AND lv_stmt_idx > <ls_decl>-stmt_idx.
        IF     mv_check_before_write = abap_true
           AND <ls_decl>-has_value = abap_false
           AND is_variable_written( it_statements = is_procedure-statements
                                    iv_from_idx   = <ls_decl>-stmt_idx + 1
                                    iv_to_idx     = lv_stmt_idx - 1
                                    iv_full_name  = <ls_decl>-full_name )   = abap_false.

          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_clear
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ) ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-redundant_clear
                            is_quickfix     = ls_quickfix ).
          CONTINUE.
        ENDIF.

        IF     mv_check_without_read = abap_true
           AND is_variable_read( it_statements = is_procedure-statements
                                 iv_from_idx   = lv_stmt_idx + 1
                                 iv_to_idx     = lines( is_procedure-statements )
                                 iv_full_name  = <ls_decl>-full_name )            = abap_false.

          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_clear
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ) ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-clear_at_end
                            is_quickfix     = ls_quickfix ).
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_written_symbol.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    IF ls_ref-full_name IS NOT INITIAL AND zcl_skylint_ast_util=>is_write_usage( ls_ref ) = abap_true.
      rv_symbol = ls_ref-full_name.
    ENDIF.
  ENDMETHOD.

  METHOD get_read_symbol.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    IF ls_ref-full_name IS NOT INITIAL AND zcl_skylint_ast_util=>is_read_usage( ls_ref ) = abap_true.
      rv_symbol = ls_ref-full_name.
    ENDIF.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA lv_eq_idx     TYPE i.
    DATA ls_tok_eq     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_left   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_right  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_after  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lhs_symbol TYPE string.
    DATA lv_rhs_symbol TYPE string.

    rv_res = abap_false.

    lv_eq_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                  iv_lexeme    = '=' ).
    IF lv_eq_idx <= 1 OR lv_eq_idx >= lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    ls_tok_eq = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_eq_idx ).
    IF ls_tok_eq-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF lines( is_statement-tokens ) > lv_eq_idx + 1.
      ls_tok_after = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                      iv_index     = lv_eq_idx + 2 ).
      IF ls_tok_after-lexeme IS NOT INITIAL AND NOT ( ls_tok_after-lexeme CP '##*' OR ls_tok_after-lexeme = '.' ).
        RETURN.
      ENDIF.
    ENDIF.

    ls_tok_left  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_eq_idx - 1 ).
    ls_tok_right = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_eq_idx + 1 ).

    lv_lhs_symbol = get_written_symbol( ls_tok_left ).
    lv_rhs_symbol = get_read_symbol( ls_tok_right ).

    IF     lv_lhs_symbol      IS NOT INITIAL
       AND lv_rhs_symbol      IS NOT INITIAL
       AND lv_lhs_symbol       = lv_rhs_symbol
       AND ls_tok_left-lexeme  = ls_tok_right-lexeme.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_identical_move.
    DATA lv_tok_cnt    TYPE i.
    DATA lv_to_idx     TYPE i.
    DATA lv_src_idx    TYPE i.
    DATA lv_tgt_idx    TYPE i.
    DATA ls_token      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_src    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_tgt    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_src_symbol TYPE string.
    DATA lv_tgt_symbol TYPE string.

    rv_res = abap_false.
    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_to_idx = find_move_to( is_statement ).
    IF lv_to_idx < 3.
      RETURN.
    ENDIF.

    lv_src_idx = 2.
    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_src_idx ).
    IF ls_token-lexeme = 'EXACT'.
      lv_src_idx += 1.
    ENDIF.

    IF lv_to_idx <> lv_src_idx + 1.
      RETURN.
    ENDIF.

    lv_tgt_idx = lv_to_idx + 1.
    IF lv_tgt_idx <> lv_tok_cnt.
      RETURN.
    ENDIF.

    ls_tok_src = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_src_idx ).
    ls_tok_tgt = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_tgt_idx ).

    lv_src_symbol = get_read_symbol( ls_tok_src ).
    lv_tgt_symbol = get_written_symbol( ls_tok_tgt ).

    IF     lv_src_symbol     IS NOT INITIAL
       AND lv_src_symbol      = lv_tgt_symbol
       AND ls_tok_src-lexeme  = ls_tok_tgt-lexeme.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD find_move_to.
    DATA lv_idx   TYPE i.
    DATA lv_cnt   TYPE i.
    DATA lv_lex   TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_idx = 0.
    lv_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = 2.

    WHILE lv_idx <= lv_cnt.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      lv_lex = ls_token-lexeme.
      IF ls_token-references IS INITIAL AND ( lv_lex = 'TO' OR lv_lex = '?TO' ).
        rv_idx = lv_idx.
        RETURN.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD collect_declarations.
    DATA lv_stmt_idx     TYPE i.
    DATA lv_struct_depth TYPE i.
    DATA ls_decl         TYPE ty_variable_decl.
    DATA lt_refs         TYPE if_ci_atc_source_code_provider=>ty_compiler_references.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_ref>  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      lv_stmt_idx = sy-tabix.

      IF <ls_stmt>-keyword <> 'DATA'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                 iv_lexeme    = 'BEGIN' ) = abap_true.
        lv_struct_depth += 1.
        IF lv_struct_depth > 1.
          CONTINUE.
        ENDIF.
      ELSEIF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                     iv_lexeme    = 'END' ) = abap_true.
        IF lv_struct_depth > 0.
          lv_struct_depth -= 1.
        ENDIF.
        CONTINUE.
      ELSEIF lv_struct_depth > 0.
        CONTINUE.
      ENDIF.

      lt_refs = zcl_skylint_ast_util=>statement_get_references(
                    is_statement = <ls_stmt>
                    iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      LOOP AT lt_refs ASSIGNING <ls_ref>.
        IF zcl_skylint_ast_util=>is_data_definition( <ls_ref> ) = abap_false.
          CONTINUE.
        ENDIF.

        IF <ls_ref>-full_name IS INITIAL.
          CONTINUE.
        ENDIF.

        IF line_exists( rt_decls[ full_name = <ls_ref>-full_name ] ).
          CONTINUE.
        ENDIF.

        CLEAR ls_decl.
        ls_decl-full_name = <ls_ref>-full_name.
        ls_decl-stmt_idx  = lv_stmt_idx.
        ls_decl-has_value = zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                                    iv_lexeme    = 'VALUE' ).
        APPEND ls_decl TO rt_decls.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_variable_written.
    rv_written = zcl_skylint_ast_util=>has_data_write_usage( it_statements = it_statements
                                                             iv_full_name  = iv_full_name
                                                             iv_from_idx   = iv_from_idx
                                                             iv_to_idx     = iv_to_idx ).
  ENDMETHOD.

  METHOD is_variable_read.
    rv_read = zcl_skylint_ast_util=>has_data_read_usage( it_statements = it_statements
                                                         iv_full_name  = iv_full_name
                                                         iv_from_idx   = iv_from_idx
                                                         iv_to_idx     = iv_to_idx ).
  ENDMETHOD.
ENDCLASS.
