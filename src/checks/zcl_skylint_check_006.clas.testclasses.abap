CLASS ltcl_check_006 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_006 IMPLEMENTATION.
  METHOD test_check.
    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_006( )
        is_object   = VALUE #( type = zif_skylint_types=>object_types-class
                               name = 'ZCL_SKYLINT_TEST_006' )
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_006=>c_finding_codes-omit_exporting )
            ( method = 'TEST_002' )
        ) ).
  ENDMETHOD.
ENDCLASS.
