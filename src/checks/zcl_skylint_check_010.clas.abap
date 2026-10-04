CLASS zcl_skylint_check_010 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_comparison TYPE zif_skylint_types=>ty_finding_code VALUE 'BOOLCOMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_BOOL_COMP'.

    METHODS has_boolean_comparison
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS is_boolean_literal
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_010 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid comparing boolean method calls to boolean literals'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_comparison
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid boolean comparison for method calls; call method directly'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
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
    DATA ls_token     TYPE zif_skylint_types=>ty_token.
    DATA ls_adj_token TYPE zif_skylint_types=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_token.
      lv_tok_idx = sy-tabix.

      CASE to_upper( ls_token-lexeme ).
        WHEN '=' OR 'EQ' OR '<>' OR 'NE' OR '><'.
          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx - 1 ).
          IF is_boolean_literal( to_upper( ls_adj_token-lexeme ) ) = abap_true.
            rv_has = abap_true.
            RETURN.
          ENDIF.

          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx + 1 ).
          IF is_boolean_literal( to_upper( ls_adj_token-lexeme ) ) = abap_true.
            rv_has = abap_true.
            RETURN.
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
