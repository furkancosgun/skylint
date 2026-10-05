CLASS ltcl_check_002 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_002 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_002( )
        it_source   = VALUE #( ( `CALL METHOD lo_obj->run.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_002=>c_finding_codes-call_method ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_002( )
                                               it_source = VALUE #( ( `lo_obj->run( ).` ) ) ).
  ENDMETHOD.
ENDCLASS.
