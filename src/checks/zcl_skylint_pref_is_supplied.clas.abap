CLASS zcl_skylint_pref_is_supplied DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        is_supplied TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_ISSUP',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_supplied TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USE_SUPPLD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_IS_SUPPLIED'.

    METHODS collect_overrides
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_found) TYPE zcl_skylint_ast_util=>ty_token_overrides.

ENDCLASS.


CLASS zcl_skylint_pref_is_supplied IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer IS SUPPLIED over the obsolete IS REQUESTED'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-is_supplied
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Use IS SUPPLIED instead of IS REQUESTED'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_supplied
                                                                short_text = 'Replace with IS SUPPLIED' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lt_overrides = collect_overrides( <ls_statement> ).
      IF lt_overrides IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                         it_overrides = lt_overrides
                                                         iv_suffix    = '.' ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_supplied
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-is_supplied
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_overrides.
    DATA lv_curr_idx  TYPE i.
    DATA lv_prev      TYPE string.
    DATA lv_prev_prev TYPE string.

    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rt_found.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_curr_idx = sy-tabix.

      IF <ls_token>-lexeme <> 'REQUESTED'.
        CONTINUE.
      ENDIF.

      lv_prev = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = lv_curr_idx - 1 ).
      lv_prev_prev = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                             iv_index     = lv_curr_idx - 2 ).
      IF     lv_prev <> 'IS'
         AND ( lv_prev <> 'NOT' OR lv_prev_prev <> 'IS' ).
        CONTINUE.
      ENDIF.

      APPEND VALUE #( index  = lv_curr_idx
                      lexeme = 'SUPPLIED' ) TO rt_found.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
