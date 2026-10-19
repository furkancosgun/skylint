CLASS zcl_skylint_pref_cast DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_cast TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFCAST',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_cast TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOCAST',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CAST'.

    METHODS build_move_cast_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                iv_to_idx          TYPE i
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_pref_cast IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer modern CAST #( ) expression over ?='
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_cast
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer CAST #( ) constructor expression over ?= downcast'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_cast
                                                                short_text = 'Use CAST #( )' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_tok_idx   TYPE i.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

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
        ENDIF.
      ENDIF.
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
ENDCLASS.
