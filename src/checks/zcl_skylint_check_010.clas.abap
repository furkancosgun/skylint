CLASS zcl_skylint_check_010 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_comparison TYPE if_ci_atc_check=>ty_finding_code VALUE 'BOOLCOMP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        drop_literal TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DROPBOOL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS has_boolean_comparison
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_index) TYPE i.

    METHODS is_droppable
      IMPORTING iv_operator  TYPE string
                iv_literal   TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

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
                                       text     = 'Avoid boolean comparison for method calls; call method directly' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-drop_literal
                                                                short_text = 'Drop boolean literal' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_op_idx    TYPE i.
    DATA lv_lit_idx   TYPE i.
    DATA lv_lit_before TYPE abap_bool.
    DATA lv_op        TYPE string.
    DATA lv_lit       TYPE string.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.
    DATA ls_adj       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_adj       TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          IF     zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_true.
            lv_op_idx = has_boolean_comparison( <ls_statement> ).
            IF lv_op_idx > 0.
              CLEAR ls_quickfix.
              CLEAR lt_deletions.
              ls_adj = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                        iv_index     = lv_op_idx - 1 ).
              lv_adj = to_upper( ls_adj-lexeme ).
              IF is_boolean_operand( is_token  = ls_adj
                                     iv_lexeme = lv_adj ) = abap_true.
                lv_lit_before = abap_true.
                lv_lit_idx = lv_op_idx - 1.
              ELSE.
                lv_lit_before = abap_false.
                lv_lit_idx = lv_op_idx + 1.
              ENDIF.
              lv_op = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                              iv_index     = lv_op_idx ).
              lv_lit = zcl_skylint_ast_util=>get_token_lexeme( is_statement      = <ls_statement>
                                                               iv_index          = lv_lit_idx
                                                               iv_case_sensitive = abap_true ).
              IF is_droppable( iv_operator = lv_op
                               iv_literal  = lv_lit ) = abap_true.
                lt_deletions = VALUE #( ( lv_op_idx ) ( lv_lit_idx ) ).
                lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                             it_deletions = lt_deletions ).
                ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-drop_literal
                                                iv_statement_from = lv_stmt_idx
                                                it_new_code       = VALUE #( ( lv_line && '.' ) ) ).
              ENDIF.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-bool_comparison
                                is_quickfix     = ls_quickfix ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_boolean_comparison.
    DATA lv_tok_idx   TYPE i.
    DATA lv_adj       TYPE string.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_adj_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_index = 0.

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
            rv_index = lv_tok_idx.
            RETURN.
          ENDIF.

          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx + 1 ).
          lv_adj = to_upper( ls_adj_token-lexeme ).
          IF is_boolean_operand( is_token  = ls_adj_token
                                 iv_lexeme = lv_adj ) = abap_true.
            rv_index = lv_tok_idx.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_droppable.
    DATA lv_op  TYPE string.
    DATA lv_lit TYPE string.

    rv_yes = abap_false.
    lv_op = to_upper( iv_operator ).
    lv_lit = to_upper( iv_literal ).

    CASE lv_op.
      WHEN '=' OR 'EQ'.
        IF lv_lit = 'ABAP_TRUE' OR lv_lit = '''X''' OR lv_lit = '`X`'.
          rv_yes = abap_true.
        ENDIF.
      WHEN '<>' OR 'NE' OR '><'.
        IF lv_lit = 'ABAP_FALSE' OR lv_lit = '''''' OR lv_lit = '``'.
          rv_yes = abap_true.
        ENDIF.
    ENDCASE.
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
