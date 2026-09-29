CLASS ltcl_check_065 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    CONSTANTS c_test_class TYPE c LENGTH 30 VALUE 'ZCL_SKYLINT_TEST_065'.
    CONSTANTS:
      BEGIN OF c_methods,
        without_pseudo_comments TYPE c LENGTH 30 VALUE 'WITHOUT_PSEUDO_COMMENTS',
        with_pseudo_comments    TYPE c LENGTH 30 VALUE 'WITH_PSEUDO_COMMENTS',
      END OF c_methods.

    METHODS execute_test_class FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_065 IMPLEMENTATION.
  METHOD execute_test_class.
    DATA ls_loc_no_pc_1 TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_no_pc_2 TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_with_pc_1 TYPE if_ci_atc_check=>ty_location.
    DATA ls_loc_with_pc_2 TYPE if_ci_atc_check=>ty_location.

    ls_loc_no_pc_1 = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-without_pseudo_comments ) )
      position = VALUE #( line = 5 column = 6 ) ).

    ls_loc_no_pc_2 = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-without_pseudo_comments ) )
      position = VALUE #( line = 8 column = 6 ) ).

    ls_loc_with_pc_1 = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-with_pseudo_comments ) )
      position = VALUE #( line = 5 column = 6 ) ).

    ls_loc_with_pc_2 = VALUE #(
      object   = cl_ci_atc_unit_driver=>get_method_object(
                   VALUE #( class  = c_test_class
                            method = c_methods-with_pseudo_comments ) )
      position = VALUE #( line = 8 column = 6 ) ).

    cl_ci_atc_unit_driver=>create_asserter( )->check_and_assert(
        check             = NEW zcl_skylint_check_065( )
        object            = VALUE #( type = 'CLAS' name = c_test_class )
        expected_findings = VALUE #( ( code     = zcl_skylint_check_065=>c_finding_codes-obsolete_loop_control
                                       location = ls_loc_no_pc_1 )
                                     ( code     = zcl_skylint_check_065=>c_finding_codes-obsolete_loop_control
                                       location = ls_loc_no_pc_2 )
                                     ( code     = zcl_skylint_check_065=>c_finding_codes-obsolete_loop_control
                                       location = ls_loc_with_pc_1 )
                                     ( code     = zcl_skylint_check_065=>c_finding_codes-obsolete_loop_control
                                       location = ls_loc_with_pc_2 ) )
        asserter_config   = VALUE #( quickfixes = abap_false ) ).
  ENDMETHOD.
ENDCLASS.
