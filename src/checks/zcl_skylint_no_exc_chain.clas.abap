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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EXC_CHAIN'.

    DATA mv_require_previous TYPE abap_bool VALUE abap_true.

    METHODS is_raise_exception
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS has_previous_equal
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

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
                 attributes        = VALUE #( ( name  = 'REQUIRE_PREVIOUS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_require_previous ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_catch     TYPE abap_bool.
    DATA lv_has_previous TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CATCH'.
          lv_in_catch = xsdbool( zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                                         iv_lexeme    = 'INTO' ) = abap_true ).

        WHEN 'ENDTRY'.
          lv_in_catch = abap_false.

        WHEN 'RAISE'.
          IF lv_in_catch = abap_true AND is_raise_exception( <ls_statement> ) = abap_true.
            lv_has_previous = has_previous_equal( <ls_statement> ).

            IF    ( mv_require_previous = abap_true  AND lv_has_previous = abap_false )
               OR ( mv_require_previous = abap_false AND lv_has_previous = abap_true ).
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-missing_previous ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_exception.
    DATA lt_type TYPE zcl_skylint_ast_util=>ty_token_lexemes.
    DATA lt_new  TYPE zcl_skylint_ast_util=>ty_token_lexemes.

    lt_type = VALUE #( ( `RAISE` ) ( `EXCEPTION` ) ( `TYPE` ) ).
    lt_new  = VALUE #( ( `RAISE` ) ( `EXCEPTION` ) ( `NEW` ) ).

    rv_is = xsdbool(
           zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                       it_expected  = lt_type )    = abap_true
        OR zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                       it_expected  = lt_new )     = abap_true ).
  ENDMETHOD.

  METHOD has_previous_equal.
    DATA lt_expected TYPE zcl_skylint_ast_util=>ty_token_lexemes.

    lt_expected = VALUE #( ( `PREVIOUS` ) ( `=` ) ).
    rv_has = xsdbool( zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                                 it_expected  = lt_expected ) > 0 ).
  ENDMETHOD.
ENDCLASS.
