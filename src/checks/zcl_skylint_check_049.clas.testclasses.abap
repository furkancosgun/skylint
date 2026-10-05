CLASS ltcl_check_049 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_049 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_049( )
        iv_class    = 'ZCL_SKYLINT_TEST_049'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_049=>c_finding_codes-raise_shortdump )
            ( method = 'TEST_002' )
        ) ).
  ENDMETHOD.
ENDCLASS.
