CLASS zcl_skylint_check_072 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        condense_stmt  TYPE if_ci_atc_check=>ty_finding_code VALUE 'CONDENSE_S',
        translate_stmt TYPE if_ci_atc_check=>ty_finding_code VALUE 'TRANSLATE_',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        condense_stmt  TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CONDENSE',
        translate_stmt TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TRANSLATE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_072 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect obsolete string statements; prefer built-in functions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity = if_ci_atc_check=>finding_severities-warning
                                     ( code = c_finding_codes-condense_stmt
                                       text = 'Use modern built-in string function condense( ... ) instead' )
                                     ( code = c_finding_codes-translate_stmt
                                       text = 'Use modern string functions ) or to_lower( instead' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-condense_stmt
                                                                short_text = 'Use condense( ) function' )
                                                              ( code       = c_quickfix_codes-translate_stmt
                                                                short_text = 'Use  /to_lower( )' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_var      TYPE string.
    DATA lv_line     TYPE string.
    DATA lv_code     TYPE if_ci_atc_check=>ty_finding_code.
    DATA lv_fix_code TYPE cl_ci_atc_quickfixes=>ty_quickfix_code.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.
      CLEAR lv_line.
      CLEAR lv_code.
      CLEAR lv_fix_code.
      CASE <ls_statement>-keyword.
        WHEN 'CONDENSE'.
          lv_code = c_finding_codes-condense_stmt.
          IF zcl_skylint_ast_util=>token_count( <ls_statement> ) = 2.
            lv_var = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 2 ).
            lv_line = |{ lv_var } = condense( { lv_var } ).|.
            lv_fix_code = c_quickfix_codes-condense_stmt.
          ELSEIF     zcl_skylint_ast_util=>token_count( <ls_statement> )                   = 3
                 AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                             iv_index     = 3
                                                             iv_expected  = `NO-GAPS` )    = abap_true.
            lv_var = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 2 ).
            lv_line = |{ lv_var } = condense( val = { lv_var } from = ` ` to = `` ).|.
            lv_fix_code = c_quickfix_codes-condense_stmt.
          ENDIF.
        WHEN 'TRANSLATE'.
          lv_code = c_finding_codes-translate_stmt.
          IF     zcl_skylint_ast_util=>token_count( <ls_statement> )                   = 5
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 3
                                                         iv_expected  = `TO` )         = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 5
                                                         iv_expected  = `CASE` )       = abap_true.
            lv_var = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 2 ).
            IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                       iv_index     = 4
                                                       iv_expected  = `UPPER` ) = abap_true.
              lv_line = |{ lv_var } =  { lv_var } .|.
              lv_fix_code = c_quickfix_codes-translate_stmt.
            ELSEIF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                           iv_index     = 4
                                                           iv_expected  = `LOWER` ) = abap_true.
              lv_line = |{ lv_var } = to_lower( { lv_var } ).|.
              lv_fix_code = c_quickfix_codes-translate_stmt.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      IF lv_line IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = lv_fix_code
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = lv_code
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
