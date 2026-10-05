CLASS ltcl_check_024 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_024 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_024( )
        iv_class    = 'ZCL_SKYLINT_TEST_024'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_024=>c_finding_codes-prefer_xsdbool )
            ( method = 'TEST_002' )
        ) ).
  ENDMETHOD.
ENDCLASS.
