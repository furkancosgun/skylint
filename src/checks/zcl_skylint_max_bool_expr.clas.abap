CLASS zcl_skylint_max_bool_expr DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_operands TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAXBOOL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_BOOL_EXPR'.

    DATA mv_max_boolean_expressions TYPE i VALUE 4.

    METHODS count_operators
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.
ENDCLASS.


CLASS zcl_skylint_max_bool_expr IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Limit boolean expressions in conditions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-too_many_operands
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Split the condition or extract named helpers'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'MAX_BOOLEAN_EXPRESSIONS'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_max_boolean_expressions ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_operators TYPE i.
    DATA lv_operands  TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          lv_operators = count_operators( <ls_statement> ).
          lv_operands = lv_operators + 1.
          IF lv_operands <= mv_max_boolean_expressions.
            CONTINUE.
          ENDIF.

          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-too_many_operands ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_operators.
    DATA lv_between TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_count = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                 iv_lexeme = 'BETWEEN' ) = abap_true.
        lv_between = abap_true.
        CONTINUE.
      ENDIF.

      IF     zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                     iv_lexeme = 'AND' )    = abap_true
         AND lv_between = abap_true.
        lv_between = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                 iv_lexeme = 'AND' ) = abap_true.
        rv_count += 1.
        CONTINUE.
      ENDIF.

      IF    zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                    iv_lexeme = 'OR' )     = abap_true
         OR zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                    iv_lexeme = 'EQUIV' )  = abap_true.
        rv_count += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
