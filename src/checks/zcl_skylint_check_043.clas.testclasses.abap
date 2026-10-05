CLASS ltcl_check_043 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_043 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_043( )
        it_source           = VALUE #( ( `METHODS get_data EXCEPTIONS not_found.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_043=>c_finding_codes-class_based_exceptions ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_043( )
        it_source           = VALUE #( ( `METHODS get_data RAISING cx_static_check.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.
