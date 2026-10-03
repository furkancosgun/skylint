CLASS zcl_skylint_check_057 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        deep_inheritance TYPE zif_skylint_types=>ty_finding_code VALUE 'DEEP_INHRT',
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
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid deep class inheritance; prefer composition over inheritance'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_DEPTH'
                                                kind  = zif_skylint_types=>attribute_kinds-integer
                                                value = REF #( mv_max_depth ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_statement TYPE zif_skylint_types=>ty_statement.
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    DATA lt_supers    TYPE string_table.
    DATA lv_max_depth TYPE i.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_DEPTH'
                   IMPORTING ev_value = lv_max_depth ).

    IF lv_max_depth <= 0.
      lv_max_depth = mv_max_depth.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_code_block-object_name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    lt_supers = zcl_skylint_rtti_util=>get_super_classes( is_code_block-object_name ).

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                        iv_index      = 1 ).
    IF     lines( lt_supers )    > lv_max_depth
       AND ls_statement-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-deep_inheritance ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
