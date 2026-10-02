CLASS zcl_skylint_check_058 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        attribute_count TYPE zif_skylint_types=>ty_finding_code VALUE 'ATTR_COUNT',
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
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Class has too many member attributes; split into cohesive components'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_ATTRIBUTES'
                                                kind  = zif_skylint_types=>attribute_kinds-elementary
                                                value = REF #( mv_max_attributes ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_statement TYPE zif_skylint_types=>ty_statement.
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    DATA lv_max_attr  TYPE i.

    IF is_procedure-id-kind <> zif_skylint_types=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_ATTRIBUTES'
                   IMPORTING ev_value = lv_max_attr ).

    IF lv_max_attr <= 0.
      lv_max_attr = mv_max_attributes.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_procedure-id-main_unit-name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                        iv_index      = 1 ).
    IF     lines( lo_class->attributes ) > lv_max_attr
       AND ls_statement-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-attribute_count ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
