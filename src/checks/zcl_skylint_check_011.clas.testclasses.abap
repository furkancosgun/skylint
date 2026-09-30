CLASS ltcl_check_011 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZCL_SKYLINT_TEST_011'.
    CONSTANTS:
      BEGIN OF c_methods,
        without_pseudo_comments TYPE c LENGTH 30 VALUE 'WITHOUT_PSEUDO_COMMENTS',
        with_pseudo_comments    TYPE c LENGTH 30 VALUE 'WITH_PSEUDO_COMMENTS',
      END OF c_methods.

    METHODS execute_test_class FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_011 IMPLEMENTATION.
  METHOD execute_test_class.
    DATA ls_loc_no_pc   TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_with_pc TYPE if_ci_atc_check=>ty_location.

    ls_loc_no_pc = VALUE #( object   = cl_ci_atc_unit_driver=>get_method_object(
                                           VALUE #( class  = c_test_class
                                                    method = c_methods-without_pseudo_comments ) )
                            position = VALUE #( line   = 3
                                                column = 4 ) ).

    ls_loc_with_pc = VALUE #( object   = cl_ci_atc_unit_driver=>get_method_object(
                                             VALUE #( class  = c_test_class
                                                      method = c_methods-with_pseudo_comments ) )
                              position = VALUE #( line   = 3
                                                  column = 4 ) ).

    cl_ci_atc_unit_driver=>create_asserter( )->check_and_assert(
        check             = NEW zcl_skylint_check_011( )
        object            = VALUE #( type = 'CLAS'
                                     name = c_test_class )
        expected_findings = VALUE #( code = zcl_skylint_check_011=>c_finding_codes-prefer_line_exists
                                     ( location = ls_loc_no_pc )
                                     ( location = ls_loc_with_pc ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
