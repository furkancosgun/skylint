CLASS zcl_skylint_no_nested_cond DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nested_cond TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_NEST_CD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_NESTED_COND'.

    METHODS check_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS scan_inner_expressions
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from_idx  TYPE i
                iv_to_idx    TYPE i.

    METHODS is_cond_or_switch
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_nested_cond IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid Nested COND or SWITCH Expressions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-nested_cond
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid nesting COND or SWITCH expressions inside each other'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      check_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD check_statement.
    DATA lv_tok_cnt TYPE i.
    DATA lv_idx     TYPE i.
    DATA lv_open    TYPE i.
    DATA lv_close   TYPE i.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next    TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = 1.

    WHILE lv_idx <= lv_tok_cnt.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).

      IF is_cond_or_switch( ls_tok ) = abap_true.
        lv_open = lv_idx + 1.
        ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_open ).
        IF zcl_skylint_ast_util=>token_paren_delta( ls_next ) > 0.
          lv_close = zcl_skylint_ast_util=>find_matching_paren( is_statement  = is_statement
                                                                iv_open_index = lv_open ).
          IF lv_close > lv_open.
            scan_inner_expressions( is_statement = is_statement
                                    iv_from_idx  = lv_open + 1
                                    iv_to_idx    = lv_close - 1 ).
            lv_idx = lv_close.
          ENDIF.
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD scan_inner_expressions.
    DATA lv_idx  TYPE i.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_idx = iv_from_idx.
    WHILE lv_idx <= iv_to_idx.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      IF is_cond_or_switch( ls_tok ) = abap_true.
        ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_idx + 1 ).
        IF zcl_skylint_ast_util=>token_paren_delta( ls_next ) > 0.
          report_token( is_token        = ls_tok
                        is_statement    = is_statement
                        iv_finding_code = c_finding_codes-nested_cond ).
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_cond_or_switch.
    rv_yes = abap_false.
    IF ( is_token-lexeme = 'COND' OR is_token-lexeme = 'SWITCH' ) AND is_token-references IS INITIAL.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
