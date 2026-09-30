CLASS zcl_skylint_check_058 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        attribute_count TYPE if_ci_atc_check=>ty_finding_code VALUE 'ATTR_COUNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_CLASS_ATTR'.

    DATA mv_max_attributes TYPE i VALUE 5.

ENDCLASS.


CLASS zcl_skylint_check_058 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit number of member attributes in a class (God Class smell)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-attribute_count
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Class has too many member attributes; split into cohesive components'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_ATTRIBUTES'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_attributes ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lo_descr            TYPE REF TO cl_abap_typedescr.
    DATA lo_class            TYPE REF TO cl_abap_classdescr.
    DATA lv_max_attr         TYPE i.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_ATTRIBUTES'
                   IMPORTING ev_value = lv_max_attr ).

    IF lv_max_attr <= 0.
      lv_max_attr = mv_max_attributes.
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

    IF lines( lo_class->attributes ) > lv_max_attr.
      READ TABLE is_procedure-statements ASSIGNING <ls_statement> INDEX 1.
      IF sy-subrc = 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-attribute_count ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
