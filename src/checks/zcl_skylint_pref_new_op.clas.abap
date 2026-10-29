CLASS zcl_skylint_pref_new_op DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_new          TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_NEW',
        raise_exception_new TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_RSNEW',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_new   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TONEW',
        raise_new TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'RAISENEW',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_pseudo_comments,
        new_op    TYPE string VALUE 'PREF_NEW_OPERATOR',
        raise_new TYPE string VALUE 'PREF_RAISE_EXC_NEW',
      END OF c_pseudo_comments.

    DATA mv_check_create_object   TYPE abap_bool VALUE abap_true.
    DATA mv_check_raise_exception TYPE abap_bool VALUE abap_true.

    METHODS is_static_create_object
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS build_new_expression
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

    METHODS is_raise_exception_type
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS build_new_raise
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_new_op IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer NEW operator over CREATE OBJECT and RAISE EXCEPTION'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-prefer_new
                       text           = 'Prefer NEW #( ) expression over CREATE OBJECT'
                       pseudo_comment = c_pseudo_comments-new_op )
                     ( code           = c_finding_codes-raise_exception_new
                       text           = 'Prefer RAISE EXCEPTION NEW cx_name( ) over RAISE EXCEPTION TYPE'
                       pseudo_comment = c_pseudo_comments-raise_new ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_new
                                                short_text = 'Use NEW constructor' )
                                              ( code       = c_quickfix_codes-raise_new
                                                short_text = 'Use RAISE EXCEPTION NEW' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_CREATE_OBJECT'
                                                value = REF #( mv_check_create_object ) )
                                              ( name  = 'CHECK_RAISE_EXCEPTION'
                                                value = REF #( mv_check_raise_exception ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'CREATE'.
          IF mv_check_create_object = abap_true AND is_static_create_object( <ls_statement> ) = abap_true.
            CLEAR ls_quickfix.
            lv_line = build_new_expression( <ls_statement> ).
            IF lv_line IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_new
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-prefer_new
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'RAISE'.
          IF mv_check_raise_exception = abap_true AND is_raise_exception_type( <ls_statement> ) = abap_true.
            CLEAR ls_quickfix.
            lv_line = build_new_raise( <ls_statement> ).
            IF lv_line IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-raise_new
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-raise_exception_new
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_static_create_object.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_type  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_idx   TYPE i.
    DATA lv_tok   TYPE string.
    DATA lv_count TYPE i.

    rv_res = abap_false.
    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `CREATE` ) ( `OBJECT` ) ) ) = abap_false.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) = abap_true.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `PARAMETER-TABLE` ) ) ) = abap_true.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = 'OBJECT' ).
    lv_tok = ls_tok-lexeme.
    IF ls_tok-lexeme IS NOT INITIAL AND ( lv_tok(1) = `'` OR lv_tok(1) = '`' ).
      RETURN.
    ENDIF.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = 3.
    WHILE lv_idx <= lv_count.
      ls_type = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_idx ).
      IF     ls_type-lexeme = 'TYPE'
         AND ls_type-references IS INITIAL
         AND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = lv_idx + 1 ) CP '(*'.
        RETURN.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    rv_res = abap_true.
  ENDMETHOD.

  METHOD build_new_expression.
    DATA lv_count  TYPE i.
    DATA lv_idx    TYPE i.
    DATA lv_target TYPE string.
    DATA lv_class  TYPE string.
    DATA lv_token  TYPE string.
    DATA lv_name   TYPE string.
    DATA lv_value  TYPE string.
    DATA lv_args   TYPE string.
    DATA lv_first  TYPE abap_bool.

    CLEAR rv_line.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 3.
      RETURN.
    ENDIF.

    lv_target = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'OBJECT' )-lexeme.
    IF lv_target IS INITIAL.
      RETURN.
    ENDIF.

    lv_class = '#'.
    lv_idx = 4.
    WHILE lv_idx <= lv_count.
      lv_token = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = lv_idx ).
      CASE lv_token.
        WHEN 'TYPE'.
          IF lv_idx + 1 > lv_count.
            RETURN.
          ENDIF.
          lv_class = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                             iv_index     = lv_idx + 1 ).
          IF lv_class IS INITIAL OR lv_class CS '('.
            RETURN.
          ENDIF.
          lv_idx += 2.
        WHEN 'EXPORTING'.
          lv_idx += 1.
          lv_first = abap_true.
          WHILE lv_idx + 2 <= lv_count.
            lv_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                              iv_index     = lv_idx ).
            IF lv_name IS INITIAL.
              RETURN.
            ENDIF.
            IF zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                       iv_index     = lv_idx + 1 ) <> '='.
              RETURN.
            ENDIF.
            lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                               iv_index     = lv_idx + 2 ).
            IF lv_value IS INITIAL.
              RETURN.
            ENDIF.
            IF lv_first = abap_true.
              lv_first = abap_false.
            ELSE.
              lv_args = |{ lv_args } |.
            ENDIF.
            lv_args = |{ lv_args }{ lv_name } = { lv_value }|.
            lv_idx += 3.
          ENDWHILE.
          IF lv_idx <= lv_count.
            RETURN.
          ENDIF.
        WHEN 'EXCEPTIONS' OR 'MESSAGE' OR 'MESSAGE-ID'.
          RETURN.
        WHEN OTHERS.
          RETURN.
      ENDCASE.
    ENDWHILE.

    IF lv_args IS INITIAL.
      lv_args = `( )`.
    ELSE.
      lv_args = |( { lv_args } )|.
    ENDIF.

    rv_line = |{ lv_target } = NEW { lv_class }{ lv_args }.|.
  ENDMETHOD.

  METHOD is_raise_exception_type.
    rv_res = abap_false.
    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `RAISE` ) ( `EXCEPTION` ) ( `TYPE` ) ) ) > 0.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD build_new_raise.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_class TYPE string.
    DATA lv_token TYPE string.
    DATA lv_name  TYPE string.
    DATA lv_value TYPE string.
    DATA lv_args  TYPE string.
    DATA lv_first TYPE abap_bool.

    CLEAR rv_line.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 4.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `RAISE` )
                                                                           ( `EXCEPTION` )
                                                                           ( `TYPE` ) ) ) = abap_false.
      RETURN.
    ENDIF.

    lv_class = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'TYPE' )-lexeme.
    IF lv_class IS INITIAL OR lv_class CS '('.
      RETURN.
    ENDIF.

    lv_idx = 5.
    lv_first = abap_true.
    WHILE lv_idx <= lv_count.
      lv_token = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = lv_idx ).
      IF lv_token <> 'EXPORTING'.
        RETURN.
      ENDIF.
      lv_idx += 1.
      WHILE lv_idx + 2 <= lv_count.
        lv_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                          iv_index     = lv_idx ).
        IF    lv_name IS INITIAL
           OR zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                      iv_index     = lv_idx + 1 ) <> '='.
          RETURN.
        ENDIF.
        lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                           iv_index     = lv_idx + 2 ).
        IF lv_value IS INITIAL.
          RETURN.
        ENDIF.
        IF lv_first = abap_true.
          lv_first = abap_false.
        ELSE.
          lv_args = |{ lv_args } |.
        ENDIF.
        lv_args = |{ lv_args }{ lv_name } = { lv_value }|.
        lv_idx += 3.
      ENDWHILE.
      IF lv_idx <= lv_count.
        RETURN.
      ENDIF.
    ENDWHILE.

    IF lv_args IS INITIAL.
      lv_args = `( )`.
    ELSE.
      lv_args = |( { lv_args } )|.
    ENDIF.

    rv_line = |RAISE EXCEPTION NEW { lv_class }{ lv_args }.|.
  ENDMETHOD.
ENDCLASS.
