CLASS zcl_skylint_pref_corresp DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_corresponding TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFER_COR',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_corresponding TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CORRESP',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CORRESP'.
ENDCLASS.


CLASS zcl_skylint_pref_corresp IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer CORRESPONDING Expression over MOVE-CORRESPONDING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_corresponding
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer functional CORRESPONDING #( ... ) over MOVE-CORRESPONDING'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_corresponding
                                                short_text = 'Use CORRESPONDING expression' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_src      TYPE string.
    DATA lv_dst      TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'MOVE-CORRESPONDING'.
        CONTINUE.
      ENDIF.

      IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'EXPANDING' )  = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'KEEPING' )    = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      IF     zcl_skylint_ast_util=>token_count( <ls_statement> )                   = 4
         AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 3
                                                     iv_expected  = `TO` )         = abap_true.
        lv_src = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = 2 ).
        lv_dst = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = 4 ).
        lv_line = |{ lv_dst } = CORRESPONDING #( { lv_src } ).|.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_corresponding
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_corresponding
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
