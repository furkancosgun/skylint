CLASS zcl_skylint_check_055 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_class TYPE zif_skylint_types=>ty_finding_code VALUE 'STAT_CLASS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_STATIC_CLS'.

ENDCLASS.


CLASS zcl_skylint_check_055 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid static-only classes; prefer instantiable interface-based design'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-static_class
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid static-only classes; declare instance methods and interfaces'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lo_class      TYPE REF TO cl_abap_classdescr.
    DATA ls_meth       TYPE abap_methdescr.
    DATA lv_static_cnt TYPE i.
    DATA lv_has_inst   TYPE abap_bool.
    DATA ls_statement  TYPE zif_skylint_types=>ty_statement.

    IF is_procedure-id-kind <> zif_skylint_types=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_procedure-id-main_unit-name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.
    IF lines( lo_class->methods ) = 0.
      RETURN.
    ENDIF.

    lv_static_cnt = 0.
    lv_has_inst = abap_false.

    LOOP AT lo_class->methods INTO ls_meth.
      IF ls_meth-is_class = abap_true.
        lv_static_cnt += 1.
      ELSEIF ls_meth-name <> 'CONSTRUCTOR'.
        lv_has_inst = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                        iv_index      = 1 ).
    IF     lv_static_cnt         > 0
       AND lv_has_inst           = abap_false
       AND ls_statement-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-static_class ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
