CLASS zcl_skylint_no_dead_code DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dead_code TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEADCODE',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        delete_dead TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DELDEAD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DEAD_CODE'.

    METHODS is_constant_false_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_literal_or_constant
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_dead_code IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Detect Dead Code with Constant Condition'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-dead_code
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Condition is always false, creating dead code'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-delete_dead
                                                short_text = 'Delete statement with dead code condition' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          IF is_constant_false_condition( <ls_statement> ) = abap_true.
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-delete_dead
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = VALUE #( ) ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dead_code
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_literal_or_constant.
    IF iv_lexeme = 'ABAP_TRUE' OR iv_lexeme = 'ABAP_FALSE' OR iv_lexeme = 'SPACE'.
      rv_yes = abap_true.
      RETURN.
    ENDIF.
    IF matches( val   = iv_lexeme
                regex = '^-?\d+$' ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.
    IF matches( val   = iv_lexeme
                regex = '^''.*''$' ) OR matches( val   = iv_lexeme
                                                 regex = '^`.*`$' ).
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_constant_false_condition.
    DATA lv_tok_cnt  TYPE i.
    DATA lv_op1      TYPE string.
    DATA lv_op2      TYPE string.
    DATA lv_operator TYPE string.
    DATA lv_num1     TYPE i.
    DATA lv_num2     TYPE i.
    DATA lv_is_num1  TYPE abap_bool.
    DATA lv_is_num2  TYPE abap_bool.

    lv_tok_cnt = lines( is_statement-tokens ).

    IF lv_tok_cnt = 2.
      lv_op1 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                       iv_index     = 2 ).
      IF lv_op1 = 'ABAP_FALSE'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_tok_cnt <> 4.
      RETURN.
    ENDIF.

    lv_op1 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = 2 ).
    lv_operator = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                          iv_index     = 3 ).
    lv_op2 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = 4 ).

    IF is_literal_or_constant( lv_op1 ) = abap_false OR is_literal_or_constant( lv_op2 ) = abap_false.
      RETURN.
    ENDIF.

    lv_is_num1 = xsdbool( matches( val   = lv_op1
                                   regex = '^-?\d+$' ) ).
    lv_is_num2 = xsdbool( matches( val   = lv_op2
                                   regex = '^-?\d+$' ) ).

    IF lv_is_num1 = abap_true AND lv_is_num2 = abap_true.
      lv_num1 = CONV i( lv_op1 ).
      lv_num2 = CONV i( lv_op2 ).

      CASE lv_operator.
        WHEN '=' OR 'EQ'.
          IF lv_num1 <> lv_num2.
            rv_res = abap_true.
          ENDIF.
        WHEN '<>' OR 'NE'.
          IF lv_num1 = lv_num2.
            rv_res = abap_true.
          ENDIF.
        WHEN '<' OR 'LT'.
          IF lv_num1 >= lv_num2.
            rv_res = abap_true.
          ENDIF.
        WHEN '>' OR 'GT'.
          IF lv_num1 <= lv_num2.
            rv_res = abap_true.
          ENDIF.
        WHEN '<=' OR 'LE'.
          IF lv_num1 > lv_num2.
            rv_res = abap_true.
          ENDIF.
        WHEN '>=' OR 'GE'.
          IF lv_num1 < lv_num2.
            rv_res = abap_true.
          ENDIF.
      ENDCASE.
      RETURN.
    ENDIF.

    CASE lv_operator.
      WHEN '=' OR 'EQ'.
        IF lv_op1 <> lv_op2.
          rv_res = abap_true.
        ENDIF.
      WHEN '<>' OR 'NE'.
        IF lv_op1 = lv_op2.
          rv_res = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
