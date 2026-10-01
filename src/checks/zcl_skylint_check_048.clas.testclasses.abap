CLASS ltcl_check_048 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_048 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_048( )
        it_source           = VALUE #( ( `CLASS lcl_test DEFINITION.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_048=>c_finding_codes-class_not_final ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_048( )
        it_source           = VALUE #( ( `CLASS lcl_test DEFINITION FINAL.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.
