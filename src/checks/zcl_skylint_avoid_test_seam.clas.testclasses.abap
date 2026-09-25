CLASS ltcl_avoid_test_seam DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_skylint_avoid_test_seam.

    METHODS setup.
    METHODS test_meta_data    FOR TESTING RAISING cx_static_check.
    METHODS test_finding_code FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_avoid_test_seam IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW zcl_skylint_avoid_test_seam( ).
  ENDMETHOD.

  METHOD test_meta_data.
    DATA(lo_meta) = mo_cut->if_ci_atc_check~get_meta_data( ).
    cl_abap_unit_assert=>assert_bound( lo_meta ).

    DATA(lt_codes) = lo_meta->get_finding_code_infos( ).
    cl_abap_unit_assert=>assert_not_initial( lt_codes ).
  ENDMETHOD.

  METHOD test_finding_code.
    DATA(lo_meta) = mo_cut->if_ci_atc_check~get_meta_data( ).
    DATA(lt_codes) = lo_meta->get_finding_code_infos( ).

    ASSIGN lt_codes[ code = zcl_skylint_avoid_test_seam=>c_finding_codes-test_seam ] TO FIELD-SYMBOL(<ls_code>).
    cl_abap_unit_assert=>assert_subrc( exp = 0 ).
    cl_abap_unit_assert=>assert_equals( exp = 'CI_TEST_SEAM_USAGE'
                                        act = <ls_code>-pseudo_comment ).
  ENDMETHOD.
ENDCLASS.
