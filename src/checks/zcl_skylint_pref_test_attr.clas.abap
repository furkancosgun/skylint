CLASS zcl_skylint_pref_test_attr DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        test_attributes TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_TSTAT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_TEST_ATTR'.

    DATA mv_check_duration   TYPE abap_bool VALUE abap_true.
    DATA mv_check_risk_level TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_pref_test_attr IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Require DURATION and RISK LEVEL attributes on test classes'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-test_attributes
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Test class must declare DURATION and RISK LEVEL attributes'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_DURATION'
                                                                value = REF #( mv_check_duration ) )
                                                              ( name  = 'CHECK_RISK_LEVEL'
                                                                value = REF #( mv_check_risk_level ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CLASS'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'DEFINITION' ) = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                    it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) = 0.
        CONTINUE.
      ENDIF.

      IF mv_check_duration = abap_true AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                                                   iv_lexeme    = 'DURATION' ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-test_attributes ).
        CONTINUE.
      ENDIF.

      IF mv_check_risk_level = abap_true AND zcl_skylint_ast_util=>find_token_sequence(
                                                 is_statement = <ls_statement>
                                                 it_expected  = VALUE #( ( `RISK` ) ( `LEVEL` ) ) ) = 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-test_attributes ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
