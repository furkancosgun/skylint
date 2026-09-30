CLASS zcl_skylint_check_056 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_method_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'BOOL_NAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'BOOL_METHOD_NAME'.

ENDCLASS.


CLASS zcl_skylint_check_056 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_method_name
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Boolean-returning method should use predicate name (IS_, HAS_, CAN_)'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lo_descr             TYPE REF TO cl_abap_typedescr.
    DATA lo_class             TYPE REF TO cl_abap_classdescr.
    DATA ls_meth              TYPE abap_methdescr.
    DATA ls_param             TYPE abap_parmdescr.
    DATA lv_is_bool_returning TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    cl_abap_typedescr=>describe_by_name(
      EXPORTING
        p_name         = is_procedure-id-main_unit-name
      RECEIVING
        p_descr_ref    = lo_descr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0 OR lo_descr IS NOT BOUND OR lo_descr->kind <> cl_abap_typedescr=>kind_class.
      RETURN.
    ENDIF.

    lo_class ?= lo_descr.

    READ TABLE is_procedure-statements ASSIGNING <ls_statement> INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lo_class->methods INTO ls_meth.
      lv_is_bool_returning = abap_false.
      LOOP AT ls_meth-parameters INTO ls_param WHERE parm_kind = cl_abap_objectdescr=>returning.
        IF ls_param-type_kind = cl_abap_typedescr=>typekind_char AND ls_param-length = 1.
          lv_is_bool_returning = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF     lv_is_bool_returning = abap_true
         AND ls_meth-name        NP 'IS_*'     AND ls_meth-name NP 'HAS_*'
         AND ls_meth-name        NP 'CAN_*'    AND ls_meth-name NP 'CHECK_*'
         AND ls_meth-name        NP 'ARE_*'    AND ls_meth-name NP 'WAS_*'
         AND ls_meth-name        NP 'SHOULD_*'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-bool_method_name ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
