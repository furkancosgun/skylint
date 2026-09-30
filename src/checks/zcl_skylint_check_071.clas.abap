CLASS zcl_skylint_check_071 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FINAL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_FINAL_METHOD'.
ENDCLASS.


CLASS zcl_skylint_check_071 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer marking non-overridden methods as FINAL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_final
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Declare method as FINAL if it is not intended to be redefined'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA lo_class TYPE REF TO cl_abap_classdescr.
    DATA ls_meth  TYPE abap_methdescr.

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

    LOOP AT lo_class->methods INTO ls_meth
         WHERE is_final     = abap_false
           AND is_abstract  = abap_false
           AND is_redefined = abap_false.
      IF ls_meth-name <> 'CONSTRUCTOR' AND ls_meth-name <> 'CLASS_CONSTRUCTOR'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_final ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
