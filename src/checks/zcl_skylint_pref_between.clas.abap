CLASS zcl_skylint_pref_between DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        range_check TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_BETWN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_BETWEEN'.

    DATA mv_strict_range TYPE abap_bool VALUE abap_false.

    METHODS inspect_condition
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS get_symbol
      IMPORTING is_token         TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS is_range_operator
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS matches_range_operators
      IMPORTING iv_first      TYPE string
                iv_second     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_between IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer BETWEEN for inclusive range checks'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-range_check
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Combine the duplicated range comparison with BETWEEN'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'STRICT_RANGE'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                       value = REF #( mv_strict_range ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          inspect_condition( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_condition.
    DATA lv_count   TYPE i.
    DATA lv_and_idx TYPE i.
    DATA lv_op1_idx TYPE i.
    DATA lv_op2_idx TYPE i.
    DATA lv_op1     TYPE string.
    DATA lv_op2     TYPE string.
    DATA ls_token   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_left1   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_right1  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_left2   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_right2  TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 8.
      RETURN.
    ENDIF.

    IF     zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'BETWEEN' ) = abap_true
        OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'OR' ) = abap_true.
      RETURN.
    ENDIF.

    lv_and_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'AND' ).
    IF lv_and_idx <= 3.
      RETURN.
    ENDIF.

    " Ensure only single AND in condition
    IF zcl_skylint_ast_util=>find_token( is_statement   = is_statement
                                         iv_lexeme      = 'AND'
                                         iv_start_index = lv_and_idx + 1 ) > 0.
      RETURN.
    ENDIF.

    " Find first comparison operator (before AND)
    DO lv_and_idx - 2 TIMES.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = sy-index + 1 ).
      IF is_range_operator( ls_token-lexeme ) = abap_true.
        lv_op1_idx = sy-index + 1.
        lv_op1     = ls_token-lexeme.
        EXIT.
      ENDIF.
    ENDDO.

    " Find second comparison operator (after AND)
    DO lv_count - lv_and_idx TIMES.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_and_idx + sy-index ).
      IF is_range_operator( ls_token-lexeme ) = abap_true.
        lv_op2_idx = lv_and_idx + sy-index.
        lv_op2     = ls_token-lexeme.
        EXIT.
      ENDIF.
    ENDDO.

    IF lv_op1_idx = 0 OR lv_op2_idx = 0.
      RETURN.
    ENDIF.

    IF matches_range_operators( iv_first  = lv_op1
                                iv_second = lv_op2 ) = abap_false.
      RETURN.
    ENDIF.

    ls_left1  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_op1_idx - 1 ).
    ls_right1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_op1_idx + 1 ).
    ls_left2  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_op2_idx - 1 ).
    ls_right2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_op2_idx + 1 ).

    IF     get_symbol( ls_left1 ) = get_symbol( ls_left2 )
       AND get_symbol( ls_left1 ) IS NOT INITIAL.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-range_check ).
    ELSEIF get_symbol( ls_right1 ) = get_symbol( ls_right2 )
       AND get_symbol( ls_right1 ) IS NOT INITIAL.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-range_check ).
    ENDIF.
  ENDMETHOD.

  METHOD get_symbol.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).

    IF ls_ref-full_name IS NOT INITIAL.
      rv_symbol = ls_ref-full_name.
    ELSE.
      rv_symbol = is_token-lexeme.
    ENDIF.
  ENDMETHOD.

  METHOD is_range_operator.
    rv_yes = xsdbool(    iv_lexeme = '<='
                      OR iv_lexeme = '>='
                      OR iv_lexeme = '<'
                      OR iv_lexeme = '>' ).
  ENDMETHOD.

  METHOD matches_range_operators.
    rv_yes = xsdbool(
            (    ( iv_first = '>=' AND iv_second = '<=' )
              OR ( iv_first = '<=' AND iv_second = '>=' ) )
         OR ( mv_strict_range = abap_true
          AND (    ( iv_first = '>' AND iv_second = '<' )
                OR ( iv_first = '<' AND iv_second = '>' ) ) ) ).
  ENDMETHOD.
ENDCLASS.