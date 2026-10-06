CLASS zcl_skylint_sci_test_run DEFINITION
  PUBLIC FINAL
  INHERITING FROM cl_ci_test_verify
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      IMPORTING io_check    TYPE REF TO zcl_skylint_check_base
                iv_class    TYPE string
                it_expected TYPE zif_skylint_types=>ty_test_expecteds
      RAISING   cx_static_check.
ENDCLASS.


CLASS zcl_skylint_sci_test_run IMPLEMENTATION.
  METHOD execute.
    DATA lo_variant TYPE REF TO cl_ci_checkvariant.
    DATA lv_name    TYPE sci_chkv.
    DATA lt_variant TYPE sci_tstvar.
    DATA ls_variant LIKE LINE OF lt_variant.
    DATA ls_exp     TYPE zif_skylint_types=>ty_test_expected.
    DATA lv_objname TYPE sobj_name.
    DATA ls_method  TYPE seocpdkey.
    DATA lv_found   TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> LIKE LINE OF result_list.

    lv_name = |SKYLINT_UNIT_{ sy-datum }_{ sy-uzeit }|.

    ls_variant-testname = io_check->myname.
    INSERT ls_variant INTO TABLE lt_variant.

    lo_variant = cl_ci_checkvariant=>create( p_user = space
                                             p_name = lv_name ).
    lo_variant->set_variant( p_variant = lt_variant ).
    lo_variant->save( lo_variant->variant ).
    lo_variant->leave_change( ).

    TRY.
        LOOP AT it_expected INTO ls_exp WHERE code <> ''.
          ls_method-clsname = is_object-name.
          ls_method-cpdname = ls_exp-code.

          lv_objname = cl_oo_classname_service=>get_method_include( mtdkey = ls_method ).

          run( p_variant  = lo_variant->chkvinf-checkvname
               p_obj_type = is_object-type
               p_obj_name = is_object-name ).

          lv_found = abap_false.
          LOOP AT result_list ASSIGNING <ls_result>
              WHERE code = ls_exp-code
                AND sobjtype = 'PROG'
                AND sobjname = lv_objname.
            IF <ls_result>-line <> ls_exp-line.
              CONTINUE.
            ENDIF.
            IF <ls_result>-col <> ls_exp-column.
              CONTINUE.
            ENDIF.
            lv_found = abap_true.
            EXIT.
          ENDLOOP.
          cl_abap_unit_assert=>assert_true(
              act = lv_found
              msg = |Expected finding { ls_exp-code } at { ls_exp-line }:{ ls_exp-column } not found.| ).
        ENDLOOP.
      CLEANUP.
        lo_variant->delete( ).
    ENDTRY.

    lo_variant->delete( ).
  ENDMETHOD.
ENDCLASS.
