CLASS ltcl_check_048 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
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
    zcl_skylint_test_util=>assert_no_findings( io_check            = NEW zcl_skylint_check_048( )
                                               it_source           = VALUE #( ( `CLASS lcl_test DEFINITION FINAL.` ) )
                                               iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_not_final DEFINITION.
ENDCLASS.
CLASS lcl_not_final IMPLEMENTATION.
ENDCLASS.

CLASS lcl_clean DEFINITION FINAL.
ENDCLASS.
CLASS lcl_clean IMPLEMENTATION.
ENDCLASS.

CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.
ENDCLASS.
