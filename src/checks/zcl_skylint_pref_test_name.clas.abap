CLASS zcl_skylint_pref_test_name DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        test_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'TEST_NAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TEST_NAME'.
ENDCLASS.


CLASS zcl_skylint_pref_test_name IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Enforce test method naming convention (TEST_, SHOULD_) in AUnit'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-test_name
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Test methods should start with TEST_ or SHOULD_'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_method_name TYPE string.
    DATA lt_expected    TYPE zcl_skylint_ast_util=>ty_token_lexemes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lt_expected = VALUE #( ( `FOR` ) ( `TESTING` ) ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS'.
        CONTINUE.
      ENDIF.
      IF zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                    it_expected  = lt_expected ) = 0.
        CONTINUE.
      ENDIF.

      lv_method_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                               iv_index     = 2 ).
      IF lv_method_name IS INITIAL.
        CONTINUE.
      ENDIF.

      IF NOT ( lv_method_name CP 'TEST_*' OR lv_method_name CP 'SHOULD_*' OR lv_method_name CP 'CHECK_*' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-test_name ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
