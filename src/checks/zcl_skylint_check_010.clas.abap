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
    METHODS has_boolean_comparison
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS is_boolean_literal
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_boolean_operand
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
                iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_010 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid comparing boolean method calls to boolean literals'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-bool_comparison
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid boolean comparison for method calls; call method directly' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          IF     zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_true
             AND has_boolean_comparison( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-bool_comparison ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_boolean_comparison.
    DATA lv_tok_idx   TYPE i.
    DATA lv_adj       TYPE string.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_adj_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_token.
      lv_tok_idx = sy-tabix.
      IF ls_token-references IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      CASE to_upper( ls_token-lexeme ).
        WHEN '=' OR 'EQ' OR '<>' OR 'NE' OR '><'.
          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx - 1 ).
          lv_adj = to_upper( ls_adj_token-lexeme ).
          IF is_boolean_operand( is_token  = ls_adj_token
                                 iv_lexeme = lv_adj ) = abap_true.
            rv_has = abap_true.
            RETURN.
          ENDIF.

          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx + 1 ).
          lv_adj = to_upper( ls_adj_token-lexeme ).
          IF is_boolean_operand( is_token  = ls_adj_token
                                 iv_lexeme = lv_adj ) = abap_true.
            rv_has = abap_true.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_operand.
    rv_is = abap_false.
    IF     is_token-references IS NOT INITIAL
       AND iv_lexeme           <> 'ABAP_TRUE'
       AND iv_lexeme           <> 'ABAP_FALSE'
       AND iv_lexeme           <> 'ABAP_UNDEFINED'.
      RETURN.
    ENDIF.
    rv_is = is_boolean_literal( iv_lexeme ).
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
