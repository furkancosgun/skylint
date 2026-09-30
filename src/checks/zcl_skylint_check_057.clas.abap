CLASS zcl_skylint_check_057 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        deep_inheritance TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEEP_INHRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEEP_INHERITANCE'.

    DATA mv_max_depth TYPE i VALUE 1.

ENDCLASS.


CLASS zcl_skylint_check_057 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid deep class inheritance hierarchies'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-deep_inheritance
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid deep class inheritance; prefer composition over inheritance'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_DEPTH'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_depth ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lo_descr    TYPE REF TO cl_abap_typedescr.
    DATA lo_class    TYPE REF TO cl_abap_classdescr.
    DATA lo_super    TYPE REF TO cl_abap_classdescr.
    DATA lv_depth    TYPE i.
    DATA lv_max_depth TYPE i.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_DEPTH'
                   IMPORTING ev_value = lv_max_depth ).

    IF lv_max_depth <= 0.
      lv_max_depth = mv_max_depth.
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
    lv_depth = 0.

    lo_super = lo_class->get_super_class_type( ).
    WHILE lo_super IS BOUND.
      lv_depth += 1.
      lo_super = lo_super->get_super_class_type( ).
    ENDWHILE.

    IF lv_depth > lv_max_depth.
      READ TABLE is_procedure-statements ASSIGNING <ls_statement> INDEX 1.
      IF sy-subrc = 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-deep_inheritance ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
