CLASS zcl_skylint_rtti_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS parse_full_name
      IMPORTING iv_full_name    TYPE string
      EXPORTING ev_program_name TYPE string
                ev_class_name   TYPE string
                ev_meth_name    TYPE string.

    CLASS-METHODS get_method_descr
      IMPORTING iv_full_name TYPE string
      EXPORTING es_method    TYPE abap_methdescr
                ev_found     TYPE abap_bool.

    CLASS-METHODS is_static_method
      IMPORTING iv_full_name TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    CLASS-METHODS get_single_importing_param
      IMPORTING iv_full_name  TYPE string
      EXPORTING ev_param_name TYPE string
                ev_is_single  TYPE abap_bool.

    CLASS-METHODS describe_class
      IMPORTING iv_class_name        TYPE string
      RETURNING VALUE(ro_classdescr) TYPE REF TO cl_abap_classdescr.

    CLASS-METHODS describe_object
      IMPORTING iv_name            TYPE string
      RETURNING VALUE(ro_objdescr) TYPE REF TO cl_abap_objectdescr.

    CLASS-METHODS get_super_classes
      IMPORTING iv_class_name           TYPE string
      RETURNING VALUE(rt_super_classes) TYPE string_table.

    CLASS-METHODS has_compiler_reference
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_kind       TYPE if_ci_atc_source_code_provider=>ty_reference_kind
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_rtti_util IMPLEMENTATION.
  METHOD parse_full_name.
    DATA lv_str   TYPE string.
    DATA lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLEAR: ev_program_name,
           ev_class_name,
           ev_meth_name.
    lv_str = to_upper( iv_full_name ).

    IF lv_str CS '->'.
      SPLIT lv_str AT '->' INTO ev_class_name ev_meth_name.
      IF ev_meth_name CS '('.
        SPLIT ev_meth_name AT '(' INTO ev_meth_name lv_str.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_str CS '=>'.
      SPLIT lv_str AT '=>' INTO ev_class_name ev_meth_name.
      IF ev_meth_name CS '('.
        SPLIT ev_meth_name AT '(' INTO ev_meth_name lv_str.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_str CS '\'.
      SPLIT lv_str AT '\' INTO TABLE lt_parts.
      LOOP AT lt_parts INTO lv_str.
        IF lv_str CP 'PROGRAM=*'.
          ev_program_name = lv_str+8.
        ELSEIF lv_str CP 'PR:*'.
          ev_program_name = lv_str+3.
        ELSEIF lv_str CP 'CLASS=*'.
          ev_class_name = lv_str+6.
        ELSEIF lv_str CP 'INTF=*'.
          ev_class_name = lv_str+5.
        ELSEIF lv_str CP 'TY:*'.
          ev_class_name = lv_str+3.
        ELSEIF lv_str CP 'METHOD=*'.
          ev_meth_name = lv_str+7.
        ELSEIF lv_str CP 'ME:*'.
          ev_meth_name = lv_str+3.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_method_descr.
    DATA lv_program   TYPE string.
    DATA lv_class     TYPE string.
    DATA lv_meth      TYPE string.
    DATA lv_rtti_name TYPE string.
    DATA lo_descr     TYPE REF TO cl_abap_typedescr.
    DATA lo_obj       TYPE REF TO cl_abap_objectdescr.

    CLEAR: es_method,
           ev_found.

    parse_full_name( EXPORTING iv_full_name    = iv_full_name
                     IMPORTING ev_program_name = lv_program
                               ev_class_name   = lv_class
                               ev_meth_name    = lv_meth ).

    IF lv_class IS INITIAL OR lv_meth IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_program IS NOT INITIAL.
      lv_rtti_name = |\\PROGRAM={ lv_program }\\CLASS={ lv_class }|.
    ELSE.
      lv_rtti_name = lv_class.
    ENDIF.

    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_rtti_name
                                         RECEIVING  p_descr_ref    = lo_descr
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).

    IF sy-subrc <> 0 AND lv_program IS NOT INITIAL.
      lv_rtti_name = |\\PROGRAM={ lv_program }\\INTF={ lv_class }|.
      cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_rtti_name
                                           RECEIVING  p_descr_ref    = lo_descr
                                           EXCEPTIONS type_not_found = 1
                                                      OTHERS         = 2 ).
    ENDIF.

    IF     sy-subrc = 0 AND lo_descr IS BOUND
       AND ( lo_descr->kind = cl_abap_typedescr=>kind_class OR lo_descr->kind = cl_abap_typedescr=>kind_intf ).
      lo_obj ?= lo_descr.
      READ TABLE lo_obj->methods INTO es_method WITH KEY name = to_upper( lv_meth ).
      IF sy-subrc = 0.
        ev_found = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_static_method.
    DATA ls_meth  TYPE abap_methdescr.
    DATA lv_found TYPE abap_bool.

    rv_is = abap_false.
    get_method_descr( EXPORTING iv_full_name = iv_full_name
                      IMPORTING es_method    = ls_meth
                                ev_found     = lv_found ).
    IF lv_found = abap_true AND ls_meth-is_class = abap_true.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_single_importing_param.
    DATA ls_meth         TYPE abap_methdescr.
    DATA lv_found        TYPE abap_bool.
    DATA lv_input_count  TYPE i.
    DATA ls_single_param TYPE abap_parmdescr.
    FIELD-SYMBOLS <ls_param> TYPE abap_parmdescr.

    CLEAR: ev_param_name,
           ev_is_single.

    get_method_descr( EXPORTING iv_full_name = iv_full_name
                      IMPORTING es_method    = ls_meth
                                ev_found     = lv_found ).
    IF lv_found = abap_false.
      RETURN.
    ENDIF.

    LOOP AT ls_meth-parameters ASSIGNING <ls_param>.
      IF <ls_param>-parm_kind <> cl_abap_objectdescr=>returning.
        lv_input_count += 1.
        ls_single_param = <ls_param>.
      ENDIF.
    ENDLOOP.

    IF lv_input_count = 1 AND ls_single_param-parm_kind = cl_abap_objectdescr=>importing.
      ev_is_single = abap_true.
      ev_param_name = ls_single_param-name.
    ENDIF.
  ENDMETHOD.

  METHOD describe_class.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = iv_class_name
                                         RECEIVING  p_descr_ref    = lo_descr
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF sy-subrc = 0 AND lo_descr IS BOUND AND lo_descr->kind = cl_abap_typedescr=>kind_class.
      ro_classdescr ?= lo_descr.
    ENDIF.
  ENDMETHOD.

  METHOD describe_object.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = iv_name
                                         RECEIVING  p_descr_ref    = lo_descr
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF     sy-subrc = 0 AND lo_descr IS BOUND
       AND ( lo_descr->kind = cl_abap_typedescr=>kind_class OR lo_descr->kind = cl_abap_typedescr=>kind_intf ).
      ro_objdescr ?= lo_descr.
    ENDIF.
  ENDMETHOD.

  METHOD get_super_classes.
    DATA lo_class      TYPE REF TO cl_abap_classdescr.
    DATA lo_super      TYPE REF TO cl_abap_classdescr.
    DATA lv_super_name TYPE string.

    lo_class = describe_class( iv_class_name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    lo_super = lo_class->get_super_class_type( ).
    WHILE lo_super IS BOUND.
      lv_super_name = lo_super->get_relative_name( ).
      INSERT lv_super_name INTO TABLE rt_super_classes.
      lo_super = lo_super->get_super_class_type( ).
    ENDWHILE.
  ENDMETHOD.

  METHOD has_compiler_reference.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_has = abap_false.
    LOOP AT is_statement-tokens INTO ls_token.
      LOOP AT ls_token-references INTO ls_ref WHERE kind = iv_kind.
        rv_has = abap_true.
        RETURN.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
