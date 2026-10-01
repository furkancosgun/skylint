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
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    DATA lt_supers    TYPE string_table.
    DATA lv_max_depth TYPE i.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_DEPTH'
                   IMPORTING ev_value = lv_max_depth ).

    IF lv_max_depth <= 0.
      lv_max_depth = mv_max_depth.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_procedure-id-main_unit-name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    lt_supers = zcl_skylint_rtti_util=>get_super_classes( is_procedure-id-main_unit-name ).

    IF lines( lt_supers ) > lv_max_depth.
      ASSIGN is_procedure-statements[ 1 ] TO <ls_statement>.
      IF sy-subrc = 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-deep_inheritance ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
