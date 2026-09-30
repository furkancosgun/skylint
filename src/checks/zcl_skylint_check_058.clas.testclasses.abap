CLASS ltcl_check_058 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZCL_SKYLINT_TEST_058'.

    METHODS execute_test_class FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_058 IMPLEMENTATION.
  METHOD execute_test_class.
    DATA ls_loc TYPE if_ci_atc_check=>ty_location.

    ls_loc = VALUE #( object   = VALUE #( type = 'CLAS'
                                          name = c_test_class )
                      position = VALUE #( line   = 1
                                          column = 0 ) ).

    cl_ci_atc_unit_driver=>create_asserter( )->check_and_assert(
        check             = NEW zcl_skylint_check_058( )
        object            = VALUE #( type = 'CLAS'
                                     name = c_test_class )
        expected_findings = VALUE #( ( code     = zcl_skylint_check_058=>c_finding_codes-attribute_count
                                       location = ls_loc ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
