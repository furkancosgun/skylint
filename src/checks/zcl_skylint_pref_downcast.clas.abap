CLASS zcl_skylint_pref_downcast DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_cast TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CAST',
        inline_cast TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INLCS',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_cast    TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOCAST',
        inline_cast TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'INLINECST',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_cast TYPE string VALUE 'PREF_DOWNCAST'.
    CONSTANTS c_pseudo_comment_inl  TYPE string VALUE 'PREF_INLINE_CAST'.

    DATA mv_check_cast_syntax TYPE abap_bool VALUE abap_true.
    DATA mv_check_inline_cast TYPE abap_bool VALUE abap_true.

    TYPES: BEGIN OF ty_usage,
             statement_index TYPE i,
             token_index     TYPE i,
           END OF ty_usage,
           ty_usages TYPE STANDARD TABLE OF ty_usage WITH EMPTY KEY.

    TYPES: BEGIN OF ty_usage_result,
             usages    TYPE ty_usages,
             has_write TYPE abap_bool,
           END OF ty_usage_result.

    METHODS build_move_cast_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                iv_to_idx          TYPE i
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

    METHODS collect_usages
      IMPORTING it_statements    TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name     TYPE if_ci_atc_source_code_provider=>ty_full_name
      RETURNING VALUE(rs_result) TYPE ty_usage_result.

    METHODS get_cast_expression
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_text) TYPE string.

    METHODS get_call_suffix
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index         TYPE i
                iv_name          TYPE string
      RETURNING VALUE(rv_suffix) TYPE string.

    METHODS is_supported_use
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index      TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_downcast IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Modernize Downcasting (CAST #( ) & inlining)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-prefer_cast
                       text           = 'Prefer CAST #( ) constructor expression over ?= downcast'
                       pseudo_comment = c_pseudo_comment_cast )
                     ( code           = c_finding_codes-inline_cast
                       text           = 'CAST helper is read exactly once in the next statement; inline it'
                       pseudo_comment = c_pseudo_comment_inl ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_cast
                                                short_text = 'Use CAST #( )' )
                                              ( code       = c_quickfix_codes-inline_cast
                                                short_text = 'Inline CAST into next statement' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_CAST_SYNTAX'
                                                value = REF #( mv_check_cast_syntax ) )
                                              ( name  = 'CHECK_INLINE_CAST'
                                                value = REF #( mv_check_inline_cast ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx     TYPE i.
    DATA lv_tok_idx      TYPE i.
    DATA lv_line         TYPE string.
    DATA ls_quickfix     TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides    TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA ls_tok          TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_cast_idx     TYPE i.
    DATA lv_assign       TYPE i.
    DATA lv_full_name    TYPE if_ci_atc_source_code_provider=>ty_full_name.
    DATA lv_name         TYPE string.
    DATA lv_cast         TYPE string.
    DATA lv_new_line     TYPE string.
    DATA lv_has_write    TYPE abap_bool.
    DATA lt_usages       TYPE ty_usages.
    DATA ls_usage        TYPE ty_usage.
    DATA ls_next         TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_usage_result TYPE ty_usage_result.
    DATA ls_ref          TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF mv_check_cast_syntax = abap_true.
        lv_tok_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = '?=' ).
        IF lv_tok_idx > 1.
          ls_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                    iv_index     = lv_tok_idx ).
          IF zcl_skylint_ast_util=>token_is_keyword( ls_tok ) = abap_true.
            CLEAR: lt_overrides,
                   ls_quickfix.

            lt_overrides = VALUE #( ( index  = lv_tok_idx
                                      lexeme = '= CAST #(' ) ).
            lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                               it_overrides = lt_overrides ).
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_cast
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = VALUE #( ( |{ lv_line } ).| ) ) ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-prefer_cast
                              is_quickfix     = ls_quickfix ).
            CONTINUE.
          ENDIF.
        ENDIF.

        IF <ls_statement>-keyword = 'MOVE'.
          lv_tok_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                         iv_lexeme    = '?TO' ).
          IF lv_tok_idx > 2 AND lines( <ls_statement>-tokens ) >= lv_tok_idx + 1.
            ls_quickfix = build_move_cast_quickfix( is_statement = <ls_statement>
                                                    iv_stmt_idx  = lv_stmt_idx
                                                    iv_to_idx    = lv_tok_idx ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-prefer_cast
                              is_quickfix     = ls_quickfix ).
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      IF mv_check_inline_cast = abap_false.
        CONTINUE.
      ENDIF.

      lv_cast_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                      iv_lexeme    = 'CAST' ).
      IF lv_cast_idx = 0.
        CONTINUE.
      ENDIF.

      CLEAR lv_full_name.
      LOOP AT <ls_statement>-tokens INTO ls_tok.
        ls_ref = zcl_skylint_ast_util=>get_reference(
                     is_token      = ls_tok
                     iv_kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                     iv_usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write ).
        IF     ls_ref-full_name IS NOT INITIAL
           AND zcl_skylint_ast_util=>token_is_inline_declaration( is_token  = ls_tok
                                                                  iv_prefix = 'DATA' )  = abap_true.
          lv_full_name = ls_ref-full_name.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_assign = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                    iv_lexeme    = '=' ).
      IF lv_assign = 0 OR lv_cast_idx <> lv_assign + 1 OR lv_stmt_idx + 1 > lines( is_procedure-statements ).
        CONTINUE.
      ENDIF.

      CLEAR lv_has_write.
      CLEAR lt_usages.
      ls_usage_result = collect_usages( it_statements = is_procedure-statements
                                        iv_full_name  = lv_full_name ).
      lt_usages    = ls_usage_result-usages.
      lv_has_write = ls_usage_result-has_write.

      IF lv_has_write = abap_true OR lines( lt_usages ) <> 1.
        CONTINUE.
      ENDIF.

      READ TABLE lt_usages INTO ls_usage INDEX 1.
      IF sy-subrc <> 0 OR ls_usage-statement_index <> lv_stmt_idx + 1.
        CONTINUE.
      ENDIF.

      ls_next = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                     iv_index      = ls_usage-statement_index ).
      IF is_supported_use( is_statement = ls_next
                           iv_index     = ls_usage-token_index ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_cast = get_cast_expression( <ls_statement> ).
      lv_name = zcl_skylint_ast_util=>get_reference_name( lv_full_name ).
      IF lv_cast IS INITIAL OR lv_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_new_line = zcl_skylint_ast_util=>flatten_statement(
                        is_statement = ls_next
                        it_overrides = VALUE #( ( index  = ls_usage-token_index
                                                  lexeme = lv_cast && get_call_suffix(
                                                                          is_statement = ls_next
                                                                          iv_index     = ls_usage-token_index
                                                                          iv_name      = lv_name ) ) )
                        iv_suffix    = `.` ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-inline_cast
                                      iv_statement_from = lv_stmt_idx
                                      iv_statement_to   = lv_stmt_idx + 1
                                      it_new_code       = VALUE #( ( lv_new_line ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-inline_cast
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_move_cast_quickfix.
    DATA lv_src TYPE string.
    DATA lv_dst TYPE string.
    DATA lv_idx TYPE i.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_quickfix.
    lv_idx = 2.
    WHILE lv_idx < iv_to_idx.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      IF lv_src IS INITIAL.
        lv_src = ls_tok-lexeme.
      ELSE.
        lv_src = |{ lv_src } { ls_tok-lexeme }|.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    lv_idx = iv_to_idx + 1.
    WHILE lv_idx <= lines( is_statement-tokens ).
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      IF lv_dst IS INITIAL.
        lv_dst = ls_tok-lexeme.
      ELSE.
        lv_dst = |{ lv_dst } { ls_tok-lexeme }|.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    IF lv_src IS NOT INITIAL AND lv_dst IS NOT INITIAL.
      rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_cast
                                      iv_statement_from = iv_stmt_idx
                                      it_new_code       = VALUE #( ( |{ lv_dst } = CAST #( { lv_src } ).| ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD collect_usages.
    DATA lv_stmt_index TYPE i.
    DATA lv_tok_index  TYPE i.
    DATA ls_token      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rs_result.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      lv_stmt_index = sy-tabix.
      LOOP AT <ls_statement>-tokens INTO ls_token.
        lv_tok_index = sy-tabix.
        ls_ref = zcl_skylint_ast_util=>get_reference(
                     is_token = ls_token
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
        IF ls_ref-full_name <> iv_full_name.
          CONTINUE.
        ENDIF.
        IF ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write.
          CONTINUE.
        ENDIF.
        IF zcl_skylint_ast_util=>is_write_usage( ls_ref ) = abap_true.
          rs_result-has_write = abap_true.
          RETURN.
        ENDIF.
        IF zcl_skylint_ast_util=>is_read_usage( ls_ref ) = abap_false.
          CONTINUE.
        ENDIF.
        APPEND VALUE #( statement_index = lv_stmt_index
                        token_index     = lv_tok_index ) TO rs_result-usages.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_cast_expression.
    DATA lv_index     TYPE i.
    DATA lv_count     TYPE i.
    DATA lv_depth     TYPE i.
    DATA lv_seen_open TYPE abap_bool.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_text.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_index = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'CAST' ).
    IF lv_index = 0.
      RETURN.
    ENDIF.

    WHILE lv_index <= lv_count.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_index ).
      IF rv_text IS INITIAL.
        rv_text = ls_token-lexeme.
      ELSE.
        rv_text = |{ rv_text } { ls_token-lexeme }|.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).
      IF lv_depth > 0.
        lv_seen_open = abap_true.
      ENDIF.
      IF lv_seen_open = abap_true AND lv_depth <= 0.
        RETURN.
      ENDIF.
      lv_index += 1.
    ENDWHILE.

    CLEAR rv_text.
  ENDMETHOD.

  METHOD get_call_suffix.
    DATA lv_lex TYPE string.
    DATA lv_len TYPE i.

    CLEAR rv_suffix.

    lv_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = iv_index ).
    IF lv_lex IS INITIAL.
      RETURN.
    ENDIF.

    lv_len = strlen( iv_name ).
    IF strlen( lv_lex ) <= lv_len.
      RETURN.
    ENDIF.
    IF lv_lex(lv_len) <> iv_name.
      RETURN.
    ENDIF.

    rv_suffix = lv_lex+lv_len.
  ENDMETHOD.

  METHOD is_supported_use.
    DATA ls_prev TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_yes.

    CASE is_statement-keyword.
      WHEN 'COMPUTE'.
        IF iv_index < 2.
          RETURN.
        ENDIF.
        ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = iv_index - 1 ).
        rv_yes = xsdbool( ls_prev-lexeme = '=' AND ls_prev-references IS INITIAL ).
      WHEN '+CALL_METHOD'.
        rv_yes = xsdbool( iv_index = 1 ).
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
