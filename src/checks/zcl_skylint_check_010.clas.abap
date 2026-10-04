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

    METHODS is_call_operand_left
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_op_index       TYPE i
      RETURNING VALUE(rv_is_call) TYPE abap_bool.

    METHODS is_call_operand_right
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_op_index       TYPE i
      RETURNING VALUE(rv_is_call) TYPE abap_bool.

    METHODS is_method_or_function_token
      IMPORTING is_token     TYPE zif_skylint_types=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_boolean_literal
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_010 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid comparing boolean functions or methods to boolean literals'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_comparison
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid boolean comparison for functional calls; use IF method( ) directly'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
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
    DATA ls_token     TYPE zif_skylint_types=>ty_token.
    DATA ls_adj_token TYPE zif_skylint_types=>ty_token.
    DATA lv_lexeme    TYPE string.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_token.
      lv_tok_idx = sy-tabix.
      lv_lexeme = to_upper( ls_token-lexeme ).

      CASE lv_lexeme.
        WHEN '=' OR 'EQ' OR '<>' OR 'NE' OR '><'.
          " Check Case 1: <call>( ... ) = boolean_literal
          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx + 1 ).
          IF     ls_adj_token-lexeme IS NOT INITIAL
             AND is_boolean_literal( to_upper( ls_adj_token-lexeme ) ) = abap_true
             AND is_call_operand_left( is_statement = is_statement
                                       iv_op_index  = lv_tok_idx ) = abap_true.
            rv_has = abap_true.
            RETURN.
          ENDIF.

          " Check Case 2: boolean_literal = <call>( ... )
          ls_adj_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                          iv_index     = lv_tok_idx - 1 ).
          IF     ls_adj_token-lexeme IS NOT INITIAL
             AND is_boolean_literal( to_upper( ls_adj_token-lexeme ) ) = abap_true
             AND is_call_operand_right( is_statement = is_statement
                                        iv_op_index  = lv_tok_idx ) = abap_true.
            rv_has = abap_true.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_call_operand_left.
    DATA ls_prev_tok TYPE zif_skylint_types=>ty_token.
    DATA lv_scan_idx TYPE i.
    DATA ls_scan_tok TYPE zif_skylint_types=>ty_token.

    rv_is_call = abap_false.
    IF iv_op_index <= 1.
      RETURN.
    ENDIF.

    ls_prev_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = iv_op_index - 1 ).
    IF ls_prev_tok-lexeme <> ')' AND ls_prev_tok-lexeme NP '*)'.
      RETURN.
    ENDIF.

    lv_scan_idx = iv_op_index - 1.
    WHILE lv_scan_idx >= 1.
      ls_scan_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = lv_scan_idx ).
      IF ls_scan_tok-lexeme IS INITIAL.
        EXIT.
      ENDIF.
      IF is_method_or_function_token( ls_scan_tok ) = abap_true.
        rv_is_call = abap_true.
        EXIT.
      ENDIF.
      CASE to_upper( ls_scan_tok-lexeme ).
        WHEN 'AND' OR 'OR' OR 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          EXIT.
      ENDCASE.
      lv_scan_idx = lv_scan_idx - 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_call_operand_right.
    DATA lv_has_call  TYPE abap_bool.
    DATA lv_has_close TYPE abap_bool.
    DATA lv_scan_idx  TYPE i.
    DATA ls_scan_tok  TYPE zif_skylint_types=>ty_token.

    rv_is_call = abap_false.
    lv_scan_idx = iv_op_index + 1.
    WHILE lv_scan_idx <= lines( is_statement-tokens ).
      ls_scan_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = lv_scan_idx ).
      IF ls_scan_tok-lexeme IS INITIAL.
        EXIT.
      ENDIF.
      CASE to_upper( ls_scan_tok-lexeme ).
        WHEN 'AND' OR 'OR' OR '.' OR 'THEN'.
          EXIT.
      ENDCASE.
      IF is_method_or_function_token( ls_scan_tok ) = abap_true.
        lv_has_call = abap_true.
      ENDIF.
      IF ls_scan_tok-lexeme CS ')' OR ls_scan_tok-lexeme = ')'.
        lv_has_close = abap_true.
      ENDIF.
      lv_scan_idx = lv_scan_idx + 1.
    ENDWHILE.

    IF lv_has_call = abap_true AND lv_has_close = abap_true.
      rv_is_call = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_method_or_function_token.
    FIELD-SYMBOLS <ls_ref> TYPE zif_skylint_types=>ty_compiler_reference.

    rv_is = abap_false.

    " 1. Inspect compiler references (compiler_reference_kinds-method)
    LOOP AT is_token-references ASSIGNING <ls_ref>.
      IF <ls_ref>-kind = zif_skylint_types=>compiler_reference_kinds-method.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    " 2. Also support built-in predicate functions and call tokens
    IF is_token-lexeme CS '->' OR is_token-lexeme CS '=>' OR is_token-lexeme CP '*('.
      rv_is = abap_true.
    ENDIF.
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
