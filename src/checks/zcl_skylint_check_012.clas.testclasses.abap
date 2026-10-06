CLASS ltcl_check_012 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_012 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_012( )
        iv_class    = 'ZCL_SKYLINT_TEST_012'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_012=>c_finding_codes-exit_outside_loop line = 2 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_012=>c_finding_codes-exit_outside_loop line = 4 column = 6 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
