CLASS ltcl_test_runner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_run FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_runner IMPLEMENTATION.
  METHOD test_run.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_001( )
        iv_class    = 'ZCL_SKYLINT_TEST_001'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_001=>c_finding_codes-describe_lines line = 4 column = 4 )
            ( method = 'TEST_002' ) ) ).
  ENDMETHOD.
ENDCLASS.
