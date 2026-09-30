CLASS zcl_skylint_check_085 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TEST_METHOD_NAME'.
ENDCLASS.


CLASS zcl_skylint_check_085 IMPLEMENTATION.
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
    DATA lv_is_testing  TYPE abap_bool.
    DATA lv_method_name TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS'.
      lv_is_testing = abap_false.
      lv_method_name = ''.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF sy-tabix = 2.
          lv_method_name = to_upper( <ls_token>-lexeme ).
        ENDIF.
        IF to_upper( <ls_token>-lexeme ) = 'TESTING'.
          lv_is_testing = abap_true.
        ENDIF.
      ENDLOOP.

      IF         lv_is_testing = abap_true AND lv_method_name IS NOT INITIAL
         AND NOT ( lv_method_name CP 'TEST_*' OR lv_method_name CP 'SHOULD_*' OR lv_method_name CP 'CHECK_*' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-test_name ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
