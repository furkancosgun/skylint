CLASS ltcl_check_026 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_026 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_026( )
        iv_class    = 'ZCL_SKYLINT_TEST_026'
        it_expected = VALUE #(
            ( method = 'TEST_001' )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' )
            ( method = 'TEST_004' )
        ) ).
  ENDMETHOD.
ENDCLASS.
