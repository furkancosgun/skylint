CLASS zcl_skylint_no_yoda_cond DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'YODA_COND'.

    METHODS is_yoda_at
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index     TYPE i
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS mirror_operator
      IMPORTING iv_operator  TYPE string
      RETURNING VALUE(rv_op) TYPE string.

    METHODS can_quickfix
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_match      TYPE i
                iv_operator   TYPE string
      RETURNING VALUE(rv_can) TYPE abap_bool.

    METHODS build_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                iv_match           TYPE i
                iv_operator        TYPE string
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_yoda_cond IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #(
                            description       = 'Avoid Yoda conditions in comparison expressions'
                            remote_enablement = abap_true
                            finding_codes     = VALUE #(
                                ( code           = c_finding_codes-yoda_condition
                                  severity       = if_ci_atc_check=>finding_severities-warning
                                  text           = 'Avoid Yoda conditions; place variable before literal in comparison'
                                  pseudo_comment = c_pseudo_comment ) )
                            quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-unyoda
                                                           short_text = 'Swap to variable-first comparison' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_tok_idx  TYPE i.
    DATA lv_total    TYPE i.
    DATA lv_op       TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lv_total = lines( <ls_statement>-tokens ).
      IF lv_total < 3.
        CONTINUE.
      ENDIF.

      lv_tok_idx = 1.
      WHILE lv_tok_idx <= lv_total - 2.
        IF is_yoda_at( is_statement = <ls_statement>
                       iv_index     = lv_tok_idx ) = abap_true.
          lv_op = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                          iv_index     = lv_tok_idx + 1 ).
          CLEAR ls_quickfix.
          IF can_quickfix( is_statement = <ls_statement>
                           iv_match     = lv_tok_idx
                           iv_operator  = lv_op ) = abap_true.
            ls_quickfix = build_quickfix( is_statement = <ls_statement>
                                          iv_stmt_idx  = lv_stmt_idx
                                          iv_match     = lv_tok_idx
                                          iv_operator  = lv_op ).
          ENDIF.

          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-yoda_condition
                            is_quickfix     = ls_quickfix ).
          EXIT.
        ENDIF.
        lv_tok_idx += 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_yoda_at.
    DATA ls_t1 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t3 TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.

    ls_t1 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_index ).
    ls_t2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_index + 1 ).
    ls_t3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_index + 2 ).

    IF     zcl_skylint_ast_util=>token_is_literal( ls_t1 )               = abap_true
       AND ls_t2-references IS INITIAL
       AND zcl_skylint_ast_util=>is_comparison_operator( ls_t2-lexeme )  = abap_true
       AND zcl_skylint_ast_util=>token_is_literal( ls_t3 )               = abap_false.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD can_quickfix.
    DATA ls_t3 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_t4 TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_can = abap_false.

    IF mirror_operator( iv_operator ) IS INITIAL.
      RETURN.
    ENDIF.

    ls_t3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_match + 2 ).
    IF ls_t3-lexeme IS INITIAL OR ls_t3-lexeme CA '()[]{}`''"'.
      RETURN.
    ENDIF.

    ls_t4 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                             iv_index     = iv_match + 3 ).
    IF     ls_t4-lexeme IS NOT INITIAL
       AND ls_t4-lexeme <> '.'
       AND ls_t4-lexeme <> ')'
       AND ls_t4-lexeme <> 'AND'
       AND ls_t4-lexeme <> 'OR'.
      RETURN.
    ENDIF.

    rv_can = abap_true.
  ENDMETHOD.

  METHOD build_quickfix.
    DATA lv_lit       TYPE string.
    DATA lv_var       TYPE string.
    DATA lv_mirror    TYPE string.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.

    lv_lit = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = iv_match ).
    lv_var = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = iv_match + 2 ).
    lv_mirror = mirror_operator( iv_operator ).

    lt_overrides = VALUE #( ( index  = iv_match
                              lexeme = lv_var )
                            ( index  = iv_match + 1
                              lexeme = lv_mirror )
                            ( index  = iv_match + 2
                              lexeme = lv_lit ) ).

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = lt_overrides ).

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-unyoda
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
  ENDMETHOD.

  METHOD mirror_operator.
    rv_op = ''.
    CASE iv_operator.
      WHEN '=' OR '<>' OR 'EQ' OR 'NE'.
        rv_op = iv_operator.
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
ENDCLASS.
