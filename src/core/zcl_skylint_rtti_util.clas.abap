CLASS zcl_skylint_rtti_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS describe_class
      IMPORTING iv_class_name        TYPE clike
      RETURNING VALUE(ro_classdescr) TYPE REF TO cl_abap_classdescr.

    CLASS-METHODS describe_object
      IMPORTING iv_name            TYPE clike
      RETURNING VALUE(ro_objdescr) TYPE REF TO cl_abap_objectdescr.

    CLASS-METHODS get_super_classes
      IMPORTING iv_class_name           TYPE clike
      RETURNING VALUE(rt_super_classes) TYPE string_table.

    CLASS-METHODS get_attribute_names
      IMPORTING iv_class_name   TYPE clike
      RETURNING VALUE(rt_names) TYPE string_table.

    CLASS-METHODS get_method_descr
      IMPORTING iv_full_name TYPE clike
      EXPORTING es_method    TYPE abap_methdescr
                ev_found     TYPE abap_bool.

    CLASS-METHODS is_static_method
      IMPORTING iv_full_name TYPE clike
      RETURNING VALUE(rv_is) TYPE abap_bool.

    CLASS-METHODS is_boolean_returning_method
      IMPORTING is_method    TYPE abap_methdescr
      RETURNING VALUE(rv_is) TYPE abap_bool.

    CLASS-METHODS get_single_importing_param
      IMPORTING iv_full_name  TYPE clike
      EXPORTING ev_param_name TYPE string
                ev_is_single  TYPE abap_bool.

    CLASS-METHODS has_compiler_reference
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_kind       TYPE if_ci_atc_source_code_provider=>ty_reference_kind
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS parse_full_name
      IMPORTING iv_full_name    TYPE clike
      EXPORTING ev_program_name TYPE string
                ev_class_name   TYPE string
                ev_meth_name    TYPE string
                ev_data_name    TYPE string.

ENDCLASS.


CLASS zcl_skylint_rtti_util IMPLEMENTATION.
  METHOD describe_object.
    DATA lo_descr   TYPE REF TO cl_abap_typedescr.
    DATA lv_program TYPE string.
    DATA lv_class   TYPE string.

    parse_full_name( EXPORTING iv_full_name    = iv_name
                     IMPORTING ev_program_name = lv_program
                               ev_class_name   = lv_class ).
    IF lv_class IS INITIAL.
      lv_class = iv_name.
    ENDIF.

    IF lv_program IS NOT INITIAL.
      cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = |\\PROGRAM={ lv_program }\\CLASS={ lv_class }|
                                           RECEIVING  p_descr_ref    = lo_descr
                                           EXCEPTIONS type_not_found = 1
                                                      OTHERS         = 2 ).
      IF sy-subrc <> 0 OR lo_descr IS NOT BOUND.
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = |\\PROGRAM={ lv_program }\\INTF={ lv_class }|
                                             RECEIVING  p_descr_ref    = lo_descr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
      ENDIF.
      IF ( sy-subrc <> 0 OR lo_descr IS NOT BOUND ) AND lv_class IS NOT INITIAL.
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_class
                                             RECEIVING  p_descr_ref    = lo_descr
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).
      ENDIF.
    ELSE.
      cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = lv_class
                                           RECEIVING  p_descr_ref    = lo_descr
                                           EXCEPTIONS type_not_found = 1
                                                      OTHERS         = 2 ).
    ENDIF.

    IF sy-subrc <> 0 OR lo_descr IS NOT BOUND OR (     lo_descr->kind <> cl_abap_typedescr=>kind_class
                                                   AND lo_descr->kind <> cl_abap_typedescr=>kind_intf ).
      RETURN.
    ENDIF.
    ro_objdescr ?= lo_descr.
  ENDMETHOD.

  METHOD describe_class.
    DATA lo_obj TYPE REF TO cl_abap_objectdescr.

    lo_obj = describe_object( iv_class_name ).
    IF lo_obj IS BOUND AND lo_obj->kind = cl_abap_typedescr=>kind_class.
      ro_classdescr ?= lo_obj.
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

    lo_super = lo_class.
    WHILE lo_super IS BOUND.
      lo_super->get_super_class_type( RECEIVING  p_descr_ref           = lo_super
                                      EXCEPTIONS super_class_not_found = 1
                                                 OTHERS                = 2 ).
      IF sy-subrc <> 0 OR lo_super IS NOT BOUND.
        EXIT.
      ENDIF.
      lv_super_name = lo_super->get_relative_name( ).
      INSERT lv_super_name INTO TABLE rt_super_classes.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_attribute_names.
    DATA lo_class TYPE REF TO cl_abap_classdescr.
    DATA lv_name  TYPE string.
    FIELD-SYMBOLS <ls_attribute> TYPE abap_attrdescr.

    lo_class = describe_class( iv_class_name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    LOOP AT lo_class->attributes ASSIGNING <ls_attribute>.
      lv_name = <ls_attribute>-name.
      INSERT lv_name INTO TABLE rt_names.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_full_name.
    DATA lv_str   TYPE string.
    DATA lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_part  TYPE string.

    CLEAR: ev_program_name,
           ev_class_name,
           ev_meth_name,
           ev_data_name.
    lv_str = iv_full_name.

    IF lv_str CS '=>'.
      SPLIT lv_str AT '=>' INTO ev_class_name ev_meth_name.
      IF ev_meth_name CS '('.
        SPLIT ev_meth_name AT '(' INTO ev_meth_name lv_str.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_str CS '\'.
      SPLIT lv_str AT '\' INTO TABLE lt_parts.
      LOOP AT lt_parts INTO lv_part.
        IF lv_part CP 'PR:*'.
          ev_program_name = lv_part+3.
        ELSEIF lv_part CP 'PROGRAM=*'.
          ev_program_name = lv_part+8.
        ELSEIF lv_part CP 'TY:*'.
          ev_class_name = lv_part+3.
        ELSEIF lv_part CP 'CLASS=*'.
          ev_class_name = lv_part+6.
        ELSEIF lv_part CP 'INTF=*'.
          ev_class_name = lv_part+5.
        ELSEIF lv_part CP 'ME:*'.
          ev_meth_name = lv_part+3.
        ELSEIF lv_part CP 'DA:*'.
          ev_data_name = lv_part+3.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD get_method_descr.
    DATA lv_program TYPE string.
    DATA lv_class   TYPE string.
    DATA lv_meth    TYPE string.
    DATA lo_obj     TYPE REF TO cl_abap_objectdescr.

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
      lo_obj = describe_object( |\\PROGRAM={ lv_program }\\CLASS={ lv_class }| ).
      IF lo_obj IS NOT BOUND.
        lo_obj = describe_object( |\\PROGRAM={ lv_program }\\INTF={ lv_class }| ).
      ENDIF.
    ELSE.
      lo_obj = describe_object( lv_class ).
    ENDIF.

    IF lo_obj IS BOUND.
      READ TABLE lo_obj->methods INTO es_method WITH KEY name = lv_meth.
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

  METHOD is_boolean_returning_method.
    FIELD-SYMBOLS <ls_param> TYPE abap_parmdescr.

    rv_is = abap_false.
    LOOP AT is_method-parameters ASSIGNING <ls_param>
         WHERE parm_kind = cl_abap_objectdescr=>returning.
      IF <ls_param>-type_kind = cl_abap_typedescr=>typekind_char AND <ls_param>-length = 1.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
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

  METHOD has_compiler_reference.
    rv_has = zcl_skylint_ast_util=>statement_has_reference( is_statement = is_statement
                                                            iv_kind      = iv_kind ).
  ENDMETHOD.
ENDCLASS.
