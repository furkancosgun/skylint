CLASS zcl_skylint_check_010 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_comparison TYPE if_ci_atc_check=>ty_finding_code VALUE 'BOOLCOMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_BOOL_COMP'.

    METHODS has_boolean_comparison
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS is_boolean_literal
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_010 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid direct comparison against boolean literals (abap_true, ''X'', etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_comparison
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid boolean comparison; use IF bool or IF NOT bool directly'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          IF has_boolean_comparison( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-bool_comparison ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_boolean_comparison.
    DATA lv_tok_idx   TYPE i.
    DATA lv_prev_idx  TYPE i.
    DATA lv_next_idx  TYPE i.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_adj_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found_adj TYPE abap_bool.
    DATA lv_lexeme    TYPE string.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_token.
      lv_tok_idx = sy-tabix.
      lv_lexeme = to_upper( ls_token-lexeme ).

      CASE lv_lexeme.
        WHEN '=' OR 'EQ' OR '<>' OR 'NE' OR '><'.
          lv_prev_idx = lv_tok_idx - 1.
          lv_next_idx = lv_tok_idx + 1.

          IF lv_prev_idx >= 1.
            zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                            iv_index     = lv_prev_idx
                                                  IMPORTING es_token     = ls_adj_token
                                                            ev_found     = lv_found_adj ).
            IF lv_found_adj = abap_true AND is_boolean_literal( to_upper( ls_adj_token-lexeme ) ) = abap_true.
              rv_has = abap_true.
              RETURN.
            ENDIF.
          ENDIF.

          IF lv_next_idx <= lines( is_statement-tokens ).
            zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                            iv_index     = lv_next_idx
                                                  IMPORTING es_token     = ls_adj_token
                                                            ev_found     = lv_found_adj ).
            IF lv_found_adj = abap_true AND is_boolean_literal( to_upper( ls_adj_token-lexeme ) ) = abap_true.
              rv_has = abap_true.
              RETURN.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_literal.
    rv_is = abap_false.

    CASE iv_lexeme.
      WHEN 'ABAP_TRUE' OR 'ABAP_FALSE' OR 'ABAP_UNDEFINED' OR 'SPACE'
        OR '''X''' OR '`X`' OR '''''' OR '``'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
