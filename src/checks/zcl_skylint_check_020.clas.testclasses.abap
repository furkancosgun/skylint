CLASS ltcl_check_020 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_020 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_020( )
        iv_class    = 'ZCL_SKYLINT_TEST_020'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_020=>c_finding_codes-yoda_condition line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_020=>c_finding_codes-yoda_condition line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
