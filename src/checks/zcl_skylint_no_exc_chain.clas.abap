CLASS zcl_skylint_no_exc_chain DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_previous TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_EXCCHN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_flags TYPE STANDARD TABLE OF abap_bool WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EXC_CHAIN'.

    DATA mv_require_previous TYPE abap_bool VALUE abap_true.

    METHODS inspect_raise
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_exc_chain IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Preserve the original exception with PREVIOUS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-missing_previous
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Converted exception does not follow the PREVIOUS chaining policy'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'REQUIRE_PREVIOUS'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                       value = REF #( mv_require_previous ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_flags TYPE ty_flags.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <lv_in_catch>  TYPE abap_bool.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TRY'.
          APPEND abap_false TO lt_flags.
        WHEN 'CATCH'.
          IF lines( lt_flags ) = 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_flags ASSIGNING <lv_in_catch> INDEX lines( lt_flags ).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          <lv_in_catch> = xsdbool( zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                                     iv_lexeme    = 'INTO' ) > 0 ).
        WHEN 'CLEANUP'.
          IF lines( lt_flags ) = 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_flags ASSIGNING <lv_in_catch> INDEX lines( lt_flags ).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          <lv_in_catch> = abap_false.
        WHEN 'ENDTRY'.
          IF lines( lt_flags ) > 0.
            DELETE lt_flags INDEX lines( lt_flags ).
          ENDIF.
        WHEN 'RAISE'.
          IF lines( lt_flags ) = 0.
            CONTINUE.
          ENDIF.
          READ TABLE lt_flags ASSIGNING <lv_in_catch> INDEX lines( lt_flags ).
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          IF <lv_in_catch> = abap_false.
            CONTINUE.
          ENDIF.
          inspect_raise( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_raise.
    DATA lv_count        TYPE i.
    DATA lv_has_previous TYPE abap_bool.
    DATA ls_token        TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 4.
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
      WHEN 'RESUMABLE' OR 'MESSAGE'.
        RETURN.
      WHEN 'NEW' OR 'TYPE'.
        lv_has_previous = xsdbool( zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                                      iv_lexeme    = 'PREVIOUS' ) > 0 ).
        IF     ( mv_require_previous = abap_true  AND lv_has_previous = abap_false )
            OR ( mv_require_previous = abap_false AND lv_has_previous = abap_true ).
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-missing_previous ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
