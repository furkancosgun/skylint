CLASS zcl_skylint_max_inherit DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        deep_inheritance TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_INHRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_INHERIT'.

    DATA mv_max_depth TYPE i VALUE 3.

ENDCLASS.


CLASS zcl_skylint_max_inherit IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid deep class inheritance hierarchies'
                 remote_enablement = abap_false
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
    DATA ls_statement  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lt_supers     TYPE string_table.
    DATA lv_class_name TYPE string.
    DATA lv_rtti_name  TYPE string.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                        iv_index      = 1 ).
    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = ls_statement
                                               iv_lexeme    = 'INHERITING' ) = abap_false.
      RETURN.
    ENDIF.

    lv_class_name = zcl_skylint_ast_util=>get_declaration_name( ls_statement ).
    lv_rtti_name = zcl_skylint_rtti_util=>resolve_class_rtti_name( is_procedure  = is_procedure
                                                                   iv_class_name = lv_class_name ).

    TRY.
        lt_supers = zcl_skylint_rtti_util=>get_super_classes( lv_rtti_name ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    IF lines( lt_supers ) > mv_max_depth AND ls_statement-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-deep_inheritance ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
