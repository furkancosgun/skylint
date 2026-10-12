CLASS zcl_skylint_check_020 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        yoda_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'YODACOND',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        unyoda TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'UNYODA',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_literal
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_comparison_operator
      IMPORTING iv_str       TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_identifier
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS mirror_operator
      IMPORTING iv_operator  TYPE string
      RETURNING VALUE(rv_op) TYPE string.

    METHODS has_yoda_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_index) TYPE i.

ENDCLASS.


CLASS zcl_skylint_check_020 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Yoda conditions in comparison expressions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-yoda_condition
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid Yoda conditions; place variable before literal in comparison' ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-unyoda
                                                short_text = 'Swap to variable-first comparison' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_match    TYPE i.
    DATA lv_lit      TYPE string.
    DATA lv_op       TYPE string.
    DATA lv_var      TYPE string.
    DATA lv_mirror   TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.

      lv_match = has_yoda_condition( <ls_statement> ).
      IF lv_match > 0.
        lv_lit = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = lv_match ).
        lv_op = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                        iv_index     = lv_match + 1 ).
        lv_var = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = lv_match + 2 ).
        lv_mirror = mirror_operator( lv_op ).
        IF lv_mirror IS NOT INITIAL.
          lt_overrides = VALUE #( ( index  = lv_match
                                    lexeme = lv_var )
                                  ( index  = lv_match + 1
                                    lexeme = lv_mirror )
                                  ( index  = lv_match + 2
                                    lexeme = lv_lit ) ).
          lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                       it_overrides = lt_overrides ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-unyoda
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line && '.' ) ) ).
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-yoda_condition
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_yoda_condition.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA ls_t1    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t2    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t3    TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_index = 0.
    lv_total = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_total < 3.
      RETURN.
    ENDIF.

    lv_idx = 1.
    WHILE lv_idx <= lv_total - 2.
      ls_t1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_idx ).
      ls_t2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_idx + 1 ).
      ls_t3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = lv_idx + 2 ).

      IF     zcl_skylint_ast_util=>token_is_literal( ls_t1 )               = abap_true
         AND ls_t2-references IS INITIAL
         AND zcl_skylint_ast_util=>is_comparison_operator( ls_t2-lexeme )  = abap_true
         AND is_identifier( ls_t3 ) = abap_true
         AND zcl_skylint_ast_util=>token_is_literal( ls_t3 )               = abap_false.
        rv_index = lv_idx.
        RETURN.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD mirror_operator.
    DATA lv_upper TYPE string.

    rv_op = ''.
    lv_upper = to_upper( iv_operator ).
    CASE lv_upper.
      WHEN '=' OR '<>' OR 'EQ' OR 'NE'.
        rv_op = lv_upper.
      WHEN '<'.
        rv_op = '>'.
      WHEN '>'.
        rv_op = '<'.
      WHEN '<='.
        rv_op = '>='.
      WHEN '>='.
        rv_op = '<='.
      WHEN 'LT'.
        rv_op = 'GT'.
      WHEN 'GT'.
        rv_op = 'LT'.
      WHEN 'LE'.
        rv_op = 'GE'.
      WHEN 'GE'.
        rv_op = 'LE'.
    ENDCASE.
  ENDMETHOD.

  METHOD is_literal.
    DATA ls_dummy TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_dummy-lexeme = iv_str.
    rv_is = zcl_skylint_ast_util=>token_is_literal( ls_dummy ).
  ENDMETHOD.

  METHOD is_comparison_operator.
    rv_is = zcl_skylint_ast_util=>is_comparison_operator( iv_str ).
  ENDMETHOD.

  METHOD is_identifier.
    DATA lv_upper TYPE string.
    DATA lv_first TYPE c LENGTH 1.

    rv_is = abap_false.
    IF zcl_skylint_ast_util=>has_compiler_reference(
           is_token = is_token
           iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ) = abap_true.
      rv_is = abap_true.
      RETURN.
    ENDIF.

    IF is_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_upper = to_upper( is_token-lexeme ).
    lv_first = lv_upper(1).

    IF lv_first NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_'.
      RETURN.
    ENDIF.

    CASE lv_upper.
      WHEN 'AND' OR 'OR' OR 'NOT' OR 'EQUIV' OR 'IS' OR 'INITIAL' OR 'BOUND'
        OR 'ASSIGNED' OR 'REQUESTED' OR 'SUPPLIED' OR 'IN' OR 'BETWEEN'
        OR 'LIKE' OR 'LINES' OR 'TABLE' OR 'LINE_EXISTS' OR 'LINE_INDEX'.
        RETURN.
      WHEN OTHERS.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
