CLASS zcl_skylint_no_many_parens DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        many_parentheses TYPE if_ci_atc_check=>ty_finding_code VALUE 'MANY_PAREN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_parentheses TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'NOPARENS',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MANY_PARENS'.

ENDCLASS.


CLASS zcl_skylint_no_many_parens IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Remove redundant parentheses'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-many_parentheses
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Parentheses wrap a complete expression and can be removed'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_parentheses
                                                                short_text = 'Remove redundant parentheses' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_index    TYPE i.
    DATA lv_count    TYPE i.
    DATA lv_open     TYPE i.
    DATA lv_close    TYPE i.
    DATA lv_depth    TYPE i.
    DATA lv_has_cond TYPE abap_bool.
    DATA ls_open     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_prev     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_report   TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword <> 'IF'
         AND <ls_statement>-keyword <> 'ELSEIF'
         AND <ls_statement>-keyword <> 'WHILE'
         AND <ls_statement>-keyword <> 'CHECK'
         AND <ls_statement>-keyword <> 'COMPUTE'.
        CONTINUE.
      ENDIF.

      lv_count = zcl_skylint_ast_util=>token_count( <ls_statement> ).
      lv_index = 1.
      WHILE lv_index <= lv_count.
        ls_open = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                   iv_index     = lv_index ).
        lv_open = lv_index.
        IF ls_open-lexeme <> '('.
          lv_index += 1.
          CONTINUE.
        ENDIF.

        lv_depth = 0.
        lv_close = 0.
        lv_index += 1.
        WHILE lv_index <= lv_count.
          ls_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                      iv_index     = lv_index ).
          lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).
          IF lv_depth = -1 AND ls_token-lexeme = ')'.
            lv_close = lv_index.
            EXIT.
          ENDIF.
          IF lv_depth < -1.
            EXIT.
          ENDIF.
          lv_index += 1.
        ENDWHILE.
        IF lv_close = 0.
          lv_index += 1.
          CONTINUE.
        ENDIF.

        IF lv_open > 1.
          ls_prev = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                     iv_index     = lv_open - 1 ).
          IF ls_prev-lexeme = 'NOT' AND ls_prev-references IS INITIAL.
            lv_index = lv_close + 1.
            CONTINUE.
          ENDIF.
        ENDIF.

        lv_has_cond = abap_false.
        lv_depth = 0.
        lv_index = lv_open + 1.
        WHILE lv_index < lv_close.
          ls_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                      iv_index     = lv_index ).
          IF     lv_depth = 0 AND ls_token-references IS INITIAL
             AND (    zcl_skylint_ast_util=>is_comparison_operator( ls_token-lexeme ) = abap_true
                   OR ls_token-lexeme = 'IS'
                   OR ls_token-lexeme = 'IN'
                   OR ls_token-lexeme = 'BETWEEN' ).
            lv_has_cond = abap_true.
          ENDIF.
          lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).
          IF lv_depth < 0.
            lv_depth = 0.
          ENDIF.
          lv_index += 1.
        ENDWHILE.

        IF lv_has_cond = abap_true.
          lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                             it_deletions = VALUE #( ( lv_open ) ( lv_close ) )
                                                             iv_suffix    = `.` ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_parentheses
                                          iv_statement_from = sy-tabix
                                          it_new_code       = VALUE #( ( lv_line ) ) ).

          ls_report = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                       iv_index     = lv_open ).
          report_token( is_token        = ls_report
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-many_parentheses
                        is_quickfix     = ls_quickfix ).
        ENDIF.

        lv_index = lv_close + 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
