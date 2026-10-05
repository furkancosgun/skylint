CLASS ltcl_check_062 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_062 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_062( )
        it_source   = VALUE #( ( `TRY.` )
                               ( `TRY.` )
                               ( `ENDTRY.` )
                               ( `ENDTRY.` ) )
        it_expected = VALUE #( ( line = 3
                                 code = zcl_skylint_check_062=>c_finding_codes-nested_try ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_062( )
                                               it_source = VALUE #( ( `TRY.` )
                                                                    ( `ENDTRY.` ) ) ).
  ENDMETHOD.
ENDCLASS.
