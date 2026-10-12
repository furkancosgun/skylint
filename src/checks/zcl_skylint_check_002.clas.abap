CLASS zcl_skylint_check_002 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        call_method TYPE if_ci_atc_check=>ty_finding_code VALUE 'CALLMETHOD',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        functional_call TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CALL2FUNC',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_dynamic_call
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_dynamic) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_check_002 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #(
                            description       = 'Avoid static CALL METHOD statements'
                            remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-call_method
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Avoid static CALL METHOD; use functional method call instead' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-functional_call
                                                                short_text = 'Use functional call' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CALL'.
      lv_stmt_idx = sy-tabix.
      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) = abap_false.
        CONTINUE.
      ENDIF.

      IF is_dynamic_call( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lv_line = zcl_skylint_ast_util=>build_functional_call( <ls_statement> ).
      IF lv_line IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-functional_call
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-call_method
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dynamic_call.
    DATA ls_third TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_dynamic = abap_false.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'PARAMETER-TABLE' ) = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'EXCEPTION-TABLE' ) = abap_true.
      rv_dynamic = abap_true.
      RETURN.
    ENDIF.

    ls_third = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 3 ).
    IF to_upper( ls_third-lexeme ) CP '(*)'.
      rv_dynamic = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
