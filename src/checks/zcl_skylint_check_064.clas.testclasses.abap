CLASS ltcl_check_064 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_064 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_064( )
        iv_class    = 'ZCL_SKYLINT_TEST_064'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_064=>c_finding_codes-check_subrc line = 3 column = 5 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_064=>c_finding_codes-check_subrc line = 4 column = 5 )
            ( method = 'TEST_004' )
        ) ).
  ENDMETHOD.
ENDCLASS.
