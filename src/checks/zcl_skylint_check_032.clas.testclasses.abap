CLASS ltcl_check_032 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_032 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_032( )
        iv_class    = 'ZCL_SKYLINT_TEST_032'
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_032=>c_finding_codes-select_star )
            ( method = 'TEST_002' )
        ) ).
  ENDMETHOD.
ENDCLASS.
