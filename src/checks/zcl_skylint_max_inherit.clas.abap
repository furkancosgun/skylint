CLASS zcl_skylint_max_inherit DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'INHERIT_DEPTH'.

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
    DATA ls_statement TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    DATA lt_supers    TYPE string_table.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                        iv_index      = 1 ).
    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = ls_statement
                                               iv_lexeme    = 'INHERITING' ) = abap_false.
      RETURN.
    ENDIF.

    TRY.
        lo_class = zcl_skylint_rtti_util=>describe_class( is_procedure-id-main_unit-name ).
        IF lo_class IS NOT BOUND.
          RETURN.
        ENDIF.

        lt_supers = zcl_skylint_rtti_util=>get_super_classes( is_procedure-id-main_unit-name ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    IF lines( lt_supers ) > mv_max_depth AND ls_statement-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-deep_inheritance ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
