CLASS ltcl_check_078 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZCL_SKYLINT_TEST_078'.
    CONSTANTS:
      BEGIN OF c_methods,
        without_pseudo_comments TYPE c LENGTH 30 VALUE 'WITHOUT_PSEUDO_COMMENTS',
        with_pseudo_comments    TYPE c LENGTH 30 VALUE 'WITH_PSEUDO_COMMENTS',
      END OF c_methods.

    METHODS execute_test_class FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_078 IMPLEMENTATION.
  METHOD execute_test_class.
    DATA ls_loc_no_pc_db  TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_no_pc_str TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_pc_db     TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_pc_str    TYPE if_ci_atc_check=>ty_location.

    ls_loc_no_pc_db = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-without_pseudo_comments ) )
      position = VALUE #( line   = 3
                          column = 4 ) ).

    ls_loc_no_pc_str = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-without_pseudo_comments ) )
      position = VALUE #( line   = 6
                          column = 4 ) ).

    ls_loc_pc_db = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-with_pseudo_comments ) )
      position = VALUE #( line   = 3
                          column = 4 ) ).

    ls_loc_pc_str = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-with_pseudo_comments ) )
      position = VALUE #( line   = 6
                          column = 4 ) ).

    cl_ci_atc_unit_driver=>create_asserter( )->check_and_assert(
        check             = NEW zcl_skylint_check_078( )
        object            = VALUE #( type = 'CLAS'
                                     name = c_test_class )
        expected_findings = VALUE #( code = zcl_skylint_check_078=>c_finding_codes-check_subrc
                                      ( location = ls_loc_no_pc_db )
                                      ( location = ls_loc_no_pc_str )
                                      ( location = ls_loc_pc_db )
                                      ( location = ls_loc_pc_str ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
