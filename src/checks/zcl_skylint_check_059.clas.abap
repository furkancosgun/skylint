CLASS zcl_skylint_check_059 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        interface_data TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTF_DATA',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'INTERFACE_DATA'.

ENDCLASS.


CLASS zcl_skylint_check_059 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable DATA declarations in interfaces; allow only CONSTANTS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-interface_data
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid mutable DATA in interfaces; declare CONSTANTS or move to class'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lo_obj TYPE REF TO cl_abap_objectdescr.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lo_obj = zcl_skylint_rtti_util=>describe_object( is_procedure-id-main_unit-name ).
    IF lo_obj IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN is_procedure-statements[ 1 ] TO <ls_statement>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lo_obj->attributes TRANSPORTING NO FIELDS WHERE is_constant = abap_false.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-interface_data ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
