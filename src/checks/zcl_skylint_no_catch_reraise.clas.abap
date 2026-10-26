CLASS zcl_skylint_no_catch_reraise DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        redundant_handler TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RETHROW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_names TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CATCH_RERAISE'.

    METHODS parse_catch
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING et_types     TYPE ty_names
                ev_into      TYPE string.

    METHODS is_bare_reraise
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                it_types     TYPE ty_names
                iv_into      TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_catch_reraise IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect CATCH blocks that only re-raise the same exception'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-redundant_handler
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'CATCH block only re-raises the same exception; remove it'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_total      TYPE i.
    DATA lv_idx        TYPE i.
    DATA lv_catch_idx  TYPE i.
    DATA lv_body_count TYPE i.
    DATA ls_body       TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_first_body TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lt_types      TYPE ty_names.
    DATA lv_into       TYPE string.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CATCH'.
        CONTINUE.
      ENDIF.

      lv_catch_idx = sy-tabix.

      parse_catch( EXPORTING is_statement = <ls_statement>
                   IMPORTING et_types     = lt_types
                             ev_into      = lv_into ).

      lv_body_count = 0.
      CLEAR ls_body.
      CLEAR ls_first_body.
      lv_idx = lv_catch_idx + 1.
      WHILE lv_idx <= lv_total.
        ls_body = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                       iv_index      = lv_idx ).
        CASE ls_body-keyword.
          WHEN 'CATCH' OR 'CLEANUP' OR 'ENDTRY'.
            EXIT.
        ENDCASE.
        lv_body_count += 1.
        IF lv_body_count = 1.
          ls_first_body = ls_body.
        ENDIF.
        lv_idx += 1.
      ENDWHILE.

      IF lv_body_count <> 1 OR ls_first_body-keyword <> 'RAISE'.
        CONTINUE.
      ENDIF.

      IF is_bare_reraise( is_statement = ls_first_body
                          it_types     = lt_types
                          iv_into      = lv_into ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-redundant_handler ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_catch.
    DATA lv_count TYPE i.
    DATA lv_into  TYPE i.
    DATA lv_idx   TYPE i.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR: et_types, ev_into.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_into = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                iv_lexeme    = 'INTO' ).
    IF lv_into = 0.
      lv_into = lv_count + 1.
    ENDIF.

    DO lv_count TIMES.
      lv_idx = sy-index.
      IF lv_idx < 2 OR lv_idx >= lv_into.
        CONTINUE.
      ENDIF.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      ls_ref = zcl_skylint_ast_util=>get_reference( is_token = ls_token
                                                    iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type ).
      IF ls_ref-full_name IS NOT INITIAL.
        APPEND ls_ref-full_name TO et_types.
      ENDIF.
    ENDDO.

    IF lv_into < lv_count.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_into + 1 ).
      ls_ref = zcl_skylint_ast_util=>get_reference( is_token = ls_token
                                                    iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      ev_into = ls_ref-full_name.
    ENDIF.
  ENDMETHOD.

  METHOD is_bare_reraise.
    DATA lv_count TYPE i.
    DATA lv_type_name TYPE string.
    DATA lv_var_name  TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 3.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 2 ).
    IF ls_token-lexeme <> 'EXCEPTION'.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 3 ).
    CASE ls_token-lexeme.
      WHEN 'NEW' OR 'RESUMABLE' OR 'MESSAGE'.
        RETURN.
      WHEN 'TYPE'.
        IF     zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'PREVIOUS' ) > 0
            OR zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'EXPORTING' ) > 0.
          RETURN.
        ENDIF.
        IF lines( it_types ) <> 1.
          RETURN.
        ENDIF.
        ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = 4 ).
        ls_ref = zcl_skylint_ast_util=>get_reference( is_token = ls_token
                                                      iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type ).
        READ TABLE it_types INTO lv_type_name INDEX 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
        IF lv_type_name = ls_ref-full_name.
          rv_yes = abap_true.
        ENDIF.
      WHEN OTHERS.
        IF iv_into IS INITIAL.
          RETURN.
        ENDIF.
        ls_ref = zcl_skylint_ast_util=>get_reference( is_token = ls_token
                                                      iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
        lv_var_name = ls_ref-full_name.
        IF lv_var_name IS NOT INITIAL AND lv_var_name = iv_into.
          rv_yes = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
