CLASS zcl_skylint_no_self_compare DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        self_compare  TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_SELFCMP',
        self_operator TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_SELFOPR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_SELF_COMPARE'.

    METHODS inspect_expression
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start     TYPE i.

    METHODS find_top_level_operator
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start        TYPE i
                iv_kind         TYPE string
      RETURNING VALUE(rv_index) TYPE i.

    METHODS operands_match
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start       TYPE i
                iv_op_index    TYPE i
      RETURNING VALUE(rv_yes)  TYPE abap_bool.

    METHODS token_key
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_key) TYPE string.

    METHODS has_boolean_connector
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start     TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_compare_operator
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_arith_operator
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_self_compare IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect comparisons and arithmetic with identical operands'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-self_compare
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Both sides of the comparison resolve to the same symbol'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-self_operator
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Arithmetic operation uses the same symbol on both sides'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_start TYPE i.
    DATA lv_equal TYPE i.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          lv_start = 2.
        WHEN 'COMPUTE'.
          lv_equal = zcl_skylint_ast_util=>find_token( is_statement   = <ls_statement>
                                                      iv_lexeme      = '='
                                                      iv_start_index = 2 ).
          IF lv_equal = 0.
            CONTINUE.
          ENDIF.
          lv_start = lv_equal + 1.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      inspect_expression( is_statement = <ls_statement>
                          iv_start     = lv_start ).
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_expression.
    DATA lv_op TYPE i.

    IF zcl_skylint_ast_util=>token_count( is_statement ) < iv_start + 2.
      RETURN.
    ENDIF.

    IF has_boolean_connector( is_statement = is_statement
                              iv_start     = iv_start ) = abap_true.
      RETURN.
    ENDIF.

    lv_op = find_top_level_operator( is_statement = is_statement
                                     iv_start     = iv_start
                                     iv_kind      = 'COMPARE' ).
    IF     lv_op > 0
       AND operands_match( is_statement = is_statement
                           iv_start     = iv_start
                           iv_op_index  = lv_op ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-self_compare ).
      RETURN.
    ENDIF.

    lv_op = find_top_level_operator( is_statement = is_statement
                                     iv_start     = iv_start
                                     iv_kind      = 'ARITH' ).
    IF     lv_op > 0
       AND operands_match( is_statement = is_statement
                           iv_start     = iv_start
                           iv_op_index  = lv_op ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-self_operator ).
    ENDIF.
  ENDMETHOD.

  METHOD find_top_level_operator.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_lex   TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_index = 0.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_depth = 0.

    DO lv_count TIMES.
      lv_idx = sy-index.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      IF lv_depth = 0 AND lv_idx >= iv_start AND ls_token-references IS INITIAL.
        lv_lex = ls_token-lexeme.
        IF     ( iv_kind = 'COMPARE' AND is_compare_operator( lv_lex ) = abap_true )
            OR ( iv_kind = 'ARITH'   AND is_arith_operator( lv_lex )   = abap_true ).
          rv_index = lv_idx.
          RETURN.
        ENDIF.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).
    ENDDO.
  ENDMETHOD.

  METHOD operands_match.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_key   TYPE string.
    DATA lv_left  TYPE string.
    DATA lv_right TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).

    IF iv_op_index <= iv_start OR iv_op_index >= lv_count.
      RETURN.
    ENDIF.

    DO lv_count TIMES.
      lv_idx = sy-index.
      IF lv_idx < iv_start OR lv_idx = iv_op_index.
        CONTINUE.
      ENDIF.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      lv_key = token_key( ls_token ).
      IF lv_idx < iv_op_index.
        lv_left = |{ lv_left }{ lv_key }|.
      ELSE.
        lv_right = |{ lv_right }{ lv_key }|.
      ENDIF.
    ENDDO.

    IF lv_left IS NOT INITIAL AND lv_left = lv_right.
      rv_yes = abap_true.
    ENDIF.
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

  METHOD has_boolean_connector.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_lex   TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_depth = 0.

    DO lv_count TIMES.
      lv_idx = sy-index.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      IF lv_depth = 0 AND lv_idx >= iv_start AND ls_token-references IS INITIAL.
        lv_lex = ls_token-lexeme.
        IF lv_lex = 'AND' OR lv_lex = 'OR'.
          rv_yes = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_token ).
    ENDDO.
  ENDMETHOD.

  METHOD is_compare_operator.
    rv_yes = xsdbool(    iv_lexeme = '='  OR iv_lexeme = '<>' OR iv_lexeme = '<'
                      OR iv_lexeme = '>'  OR iv_lexeme = '<=' OR iv_lexeme = '>='
                      OR iv_lexeme = 'EQ' OR iv_lexeme = 'NE' OR iv_lexeme = 'LT'
                      OR iv_lexeme = 'GT' OR iv_lexeme = 'LE' OR iv_lexeme = 'GE' ).
  ENDMETHOD.

  METHOD is_arith_operator.
    rv_yes = xsdbool(    iv_lexeme = '-'
                      OR iv_lexeme = '/'
                      OR iv_lexeme = 'DIV'
                      OR iv_lexeme = 'MOD' ).
  ENDMETHOD.
ENDCLASS.
