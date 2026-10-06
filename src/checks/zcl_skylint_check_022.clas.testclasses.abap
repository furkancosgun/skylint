CLASS ltcl_check_022 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_022 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_022( )
        iv_class    = 'ZCL_SKYLINT_TEST_022'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_022=>c_finding_codes-prefer_new line = 3 column = 5 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_022=>c_finding_codes-prefer_new line = 3 column = 5 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
