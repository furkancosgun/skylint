CLASS zcl_skylint_atc_test_run DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                iv_class    TYPE string
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.
ENDCLASS.


CLASS zcl_skylint_atc_test_run IMPLEMENTATION.
  METHOD execute.
    DATA lo_asserter     TYPE REF TO cl_ci_atc_unit_asserter.
    DATA lt_atc_expected TYPE cl_ci_atc_unit_asserter=>ty_expected_findings.
    DATA ls_finding      TYPE cl_ci_atc_unit_asserter=>ty_expected_finding.
    DATA ls_exp          TYPE zif_skylint_types=>ty_test_expected.

    LOOP AT it_expected INTO ls_exp WHERE code IS NOT INITIAL.
      ls_finding-code = ls_exp-code.
      ls_finding-location-object = VALUE #( type = 'CLAS'
                                            name = iv_class ).
      INSERT ls_finding INTO TABLE lt_atc_expected.
    ENDLOOP.

    lo_asserter = cl_ci_atc_unit_driver=>create_asserter( ).
    lo_asserter->check_and_assert(
        check             = io_check
        object            = VALUE #( type = 'CLAS' name = iv_class )
        expected_findings = lt_atc_expected
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
