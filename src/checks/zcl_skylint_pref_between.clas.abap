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

    METHODS operand_key
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from         TYPE i
                iv_to           TYPE i
      RETURNING VALUE(rv_key)   TYPE string.

    METHODS token_key
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_key) TYPE string.

    METHODS is_compare_operator
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

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          inspect_condition( <ls_statement> ).
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_condition.
    DATA lv_count    TYPE i.
    DATA lv_idx      TYPE i.
    DATA lv_depth    TYPE i.
    DATA lv_and_cnt  TYPE i.
    DATA lv_and_idx  TYPE i.
    DATA lv_cmp1     TYPE i.
    DATA lv_cmp2     TYPE i.
    DATA lv_op1      TYPE string.
    DATA lv_op2      TYPE string.
    DATA lv_key1     TYPE string.
    DATA lv_key2     TYPE string.
    DATA lv_key3     TYPE string.
    DATA lv_key4     TYPE string.
    DATA lv_shared_left  TYPE abap_bool.
    DATA lv_shared_right TYPE abap_bool.
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 8.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                         iv_lexeme    = 'BETWEEN' ) > 0.
      RETURN.
    ENDIF.

    lv_depth = 0.
    DO lv_count TIMES.
      lv_idx = sy-index.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      IF lv_depth = 0 AND lv_idx >= 2 AND ls_token-references IS INITIAL.
        IF is_compare_operator( ls_token-lexeme ) = abap_true.
          IF lv_cmp1 <> 0 AND lv_cmp2 <> 0.
            RETURN.
          ENDIF.
          IF lv_cmp1 = 0.
            lv_cmp1 = lv_idx.
          ELSE.
            lv_cmp2 = lv_idx.
          ENDIF.
        ELSE.
          CASE ls_token-lexeme.
            WHEN 'OR'.
              RETURN.
            WHEN 'AND'.
              lv_and_cnt += 1.
              lv_and_idx = lv_idx.
          ENDCASE.
        ENDIF.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).
    ENDDO.

    IF     lv_cmp1 = 0
        OR lv_cmp2 = 0
        OR lv_and_cnt <> 1
        OR lv_cmp1 >= lv_and_idx
        OR lv_and_idx >= lv_cmp2.
      RETURN.
    ENDIF.

    lv_key1 = operand_key( is_statement = is_statement
                           iv_from      = 2
                           iv_to        = lv_cmp1 - 1 ).
    lv_key2 = operand_key( is_statement = is_statement
                           iv_from      = lv_cmp1 + 1
                           iv_to        = lv_and_idx - 1 ).
    lv_key3 = operand_key( is_statement = is_statement
                           iv_from      = lv_and_idx + 1
                           iv_to        = lv_cmp2 - 1 ).
    lv_key4 = operand_key( is_statement = is_statement
                           iv_from      = lv_cmp2 + 1
                           iv_to        = lv_count ).
    IF     lv_key1 IS INITIAL
        OR lv_key2 IS INITIAL
        OR lv_key3 IS INITIAL
        OR lv_key4 IS INITIAL.
      RETURN.
    ENDIF.

    lv_shared_left  = xsdbool( lv_key1 = lv_key3 ).
    lv_shared_right = xsdbool( lv_key2 = lv_key4 ).
    IF lv_shared_left = lv_shared_right.
      RETURN.
    ENDIF.

    lv_op1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_cmp1 )-lexeme.
    lv_op2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_cmp2 )-lexeme.
    IF matches_range_operators( iv_first  = lv_op1
                                iv_second = lv_op2 ) = abap_false.
      RETURN.
    ENDIF.

    report_statement( is_statement    = is_statement
                      iv_finding_code = c_finding_codes-range_check ).
  ENDMETHOD.

  METHOD operand_key.
    DATA lv_idx TYPE i.
    DATA lv_key TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_key = ``.
    IF iv_from <= 0 OR iv_to < iv_from.
      RETURN.
    ENDIF.

    DO iv_to - iv_from + 1 TIMES.
      lv_idx = iv_from + sy-index - 1.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      lv_key = token_key( ls_token ).
      rv_key = |{ rv_key }{ lv_key }|.
    ENDDO.
  ENDMETHOD.

  METHOD token_key.
    DATA ls_reference TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_reference = zcl_skylint_ast_util=>get_reference( is_token ).
    IF ls_reference-full_name IS NOT INITIAL.
      rv_key = ls_reference-full_name.
    ELSE.
      rv_key = is_token-lexeme.
    ENDIF.
  ENDMETHOD.

  METHOD is_compare_operator.
    rv_yes = xsdbool(    iv_lexeme = '='  OR iv_lexeme = '<>' OR iv_lexeme = '<'
                      OR iv_lexeme = '>'  OR iv_lexeme = '<=' OR iv_lexeme = '>='
                      OR iv_lexeme = 'EQ' OR iv_lexeme = 'NE' OR iv_lexeme = 'LT'
                      OR iv_lexeme = 'GT' OR iv_lexeme = 'LE' OR iv_lexeme = 'GE' ).
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
