CLASS zcl_skylint_pref_join_type DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        join_type TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_JOINT',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_inner TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADD_INNER',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_JOIN_TYPE'.

    METHODS is_explicit_join
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_token_idx TYPE i
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_join_type IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer an explicit JOIN type such as INNER JOIN'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-join_type
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Specify the JOIN type explicitly, for example INNER JOIN'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_inner
                                                                short_text = 'Add explicit INNER JOIN' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      CLEAR lt_overrides.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF <ls_token>-lexeme <> 'JOIN' OR <ls_token>-references IS NOT INITIAL.
          CONTINUE.
        ENDIF.
        IF is_explicit_join( is_statement = <ls_statement>
                             iv_token_idx = sy-tabix ) = abap_true.
          CONTINUE.
        ENDIF.
        APPEND VALUE #( index  = sy-tabix
                        lexeme = 'INNER JOIN' ) TO lt_overrides.
      ENDLOOP.

      IF lt_overrides IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                         it_overrides = lt_overrides
                                                         iv_suffix    = '.' ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_inner
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-join_type
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_explicit_join.
    DATA ls_prev TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = iv_token_idx - 1 ).
    IF ls_prev-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    CASE ls_prev-lexeme.
      WHEN 'INNER' OR 'OUTER' OR 'LEFT' OR 'RIGHT' OR 'CROSS'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
