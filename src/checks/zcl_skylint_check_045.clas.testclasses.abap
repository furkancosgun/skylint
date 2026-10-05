CLASS ltcl_check_045 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_045 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_045( )
        is_object   = VALUE #( type = zif_skylint_types=>object_types-class
                               name = 'ZCL_SKYLINT_TEST_045' )
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_045=>c_finding_codes-missing_auth_check )
            ( method = 'TEST_002' )
        ) ).
  ENDMETHOD.
ENDCLASS.
