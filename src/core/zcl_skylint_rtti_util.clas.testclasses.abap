CLASS ltcl_rtti_util DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_describe_class FOR TESTING.
    METHODS test_describe_interface FOR TESTING.
    METHODS test_describe_object FOR TESTING.
    METHODS test_get_super_classes FOR TESTING.
    METHODS test_is_static_method FOR TESTING.
    METHODS test_is_bool_returning FOR TESTING.
    METHODS test_get_method_descr FOR TESTING.
    METHODS test_has_compiler_ref FOR TESTING.
ENDCLASS.


CLASS ltcl_rtti_util IMPLEMENTATION.
  METHOD test_describe_class.
    DATA lo_class TYPE REF TO cl_abap_classdescr.

    lo_class = zcl_skylint_rtti_util=>describe_class( 'ZCL_SKYLINT_RTTI_UTIL' ).
    cl_abap_unit_assert=>assert_bound( lo_class ).

    lo_class = zcl_skylint_rtti_util=>describe_class( 'ZCL_NON_EXISTENT_CLASS_XYZ' ).
    cl_abap_unit_assert=>assert_not_bound( lo_class ).
  ENDMETHOD.

  METHOD test_describe_interface.
    DATA lo_intf TYPE REF TO cl_abap_intfdescr.

    lo_intf = zcl_skylint_rtti_util=>describe_interface( 'IF_CI_ATC_CHECK' ).
    cl_abap_unit_assert=>assert_bound( lo_intf ).

    lo_intf = zcl_skylint_rtti_util=>describe_interface( 'ZCL_SKYLINT_RTTI_UTIL' ).
    cl_abap_unit_assert=>assert_not_bound( lo_intf ).
  ENDMETHOD.

  METHOD test_describe_object.
    DATA lo_obj TYPE REF TO cl_abap_objectdescr.

    lo_obj = zcl_skylint_rtti_util=>describe_object( 'ZCL_SKYLINT_RTTI_UTIL' ).
    cl_abap_unit_assert=>assert_bound( lo_obj ).

    lo_obj = zcl_skylint_rtti_util=>describe_object( 'IF_CI_ATC_CHECK' ).
    cl_abap_unit_assert=>assert_bound( lo_obj ).

    lo_obj = zcl_skylint_rtti_util=>describe_object( 'NON_EXISTENT_OBJ' ).
    cl_abap_unit_assert=>assert_not_bound( lo_obj ).
  ENDMETHOD.

  METHOD test_get_super_classes.
    DATA lt_supers TYPE string_table.

    lt_supers = zcl_skylint_rtti_util=>get_super_classes( 'ZCL_SKYLINT_CHECK_001' ).
    cl_abap_unit_assert=>assert_not_initial( lt_supers ).
    cl_abap_unit_assert=>assert_equals( act = lt_supers[ 1 ]
                                        exp = 'ZCL_SKYLINT_CHECK_BASE' ).

    lt_supers = zcl_skylint_rtti_util=>get_super_classes( 'ZCL_NON_EXISTENT_CLASS' ).
    cl_abap_unit_assert=>assert_initial( lt_supers ).
  ENDMETHOD.

  METHOD test_is_static_method.
    DATA lv_is TYPE abap_bool.

    lv_is = zcl_skylint_rtti_util=>is_static_method( 'ZCL_SKYLINT_RTTI_UTIL=>DESCRIBE_CLASS' ).
    cl_abap_unit_assert=>assert_equals( act = lv_is
                                        exp = abap_true ).

    lv_is = zcl_skylint_rtti_util=>is_static_method( 'NON_EXISTENT=>METHOD' ).
    cl_abap_unit_assert=>assert_equals( act = lv_is
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD test_is_bool_returning.
    DATA ls_meth TYPE abap_methdescr.
    DATA lv_is   TYPE abap_bool.

    ls_meth = VALUE #( parameters = VALUE #( ( name      = 'RV_RES'
                                               parm_kind = cl_abap_objectdescr=>returning
                                               type_kind = cl_abap_typedescr=>typekind_char
                                               length    = 1 ) ) ).
    lv_is = zcl_skylint_rtti_util=>is_boolean_returning_method( ls_meth ).
    cl_abap_unit_assert=>assert_equals( act = lv_is
                                        exp = abap_true ).

    ls_meth = VALUE #( parameters = VALUE #( ( name      = 'RV_INT'
                                               parm_kind = cl_abap_objectdescr=>returning
                                               type_kind = cl_abap_typedescr=>typekind_int
                                               length    = 4 ) ) ).
    lv_is = zcl_skylint_rtti_util=>is_boolean_returning_method( ls_meth ).
    cl_abap_unit_assert=>assert_equals( act = lv_is
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD test_get_method_descr.
    DATA ls_meth  TYPE abap_methdescr.
    DATA lv_found TYPE abap_bool.

    zcl_skylint_rtti_util=>get_method_descr(
      EXPORTING iv_full_name = '\TY:ZCL_SKYLINT_RTTI_UTIL\ME:DESCRIBE_CLASS'
      IMPORTING es_method    = ls_meth
                ev_found     = lv_found ).
    cl_abap_unit_assert=>assert_equals( act = lv_found
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_meth-name
                                        exp = 'DESCRIBE_CLASS' ).
  ENDMETHOD.

  METHOD test_has_compiler_ref.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_has  TYPE abap_bool.

    ls_stmt = VALUE #( tokens = VALUE #( ( references = VALUE #(
        ( kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ) ) ) ) ).

    lv_has = zcl_skylint_rtti_util=>has_compiler_reference(
        is_statement = ls_stmt
        iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ).
    cl_abap_unit_assert=>assert_equals( act = lv_has
                                        exp = abap_true ).

    lv_has = zcl_skylint_rtti_util=>has_compiler_reference(
        is_statement = ls_stmt
        iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    cl_abap_unit_assert=>assert_equals( act = lv_has
                                        exp = abap_false ).
  ENDMETHOD.
ENDCLASS.
