CLASS ltcl_check_065 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_065 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_065( )
        iv_class    = 'ZCL_SKYLINT_TEST_065'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_065=>c_finding_codes-avoid_form )
            ( method = 'TEST_002' )
        ) ).
  ENDMETHOD.
ENDCLASS.
