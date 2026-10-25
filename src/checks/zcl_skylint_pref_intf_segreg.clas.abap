CLASS zcl_skylint_pref_intf_segreg DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        interface_segregation TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTF_SEGR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'INTF_SEGREGATION'.

    DATA mv_max_methods TYPE i VALUE 5.

    METHODS is_interface
      IMPORTING is_procedure      TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is_intf) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_intf_segreg IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Prefer interface segregation (small interfaces)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-interface_segregation
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Interface has too many methods; prefer interface segregation'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                     ( name  = 'MAX_METHODS'
                                       value = REF #( mv_max_methods ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_method_count TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    IF is_interface( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    lv_method_count = 0.
    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword = 'METHODS' OR <ls_stmt>-keyword = 'CLASS-METHODS'.
        lv_method_count += 1.
      ENDIF.
    ENDLOOP.

    IF lv_method_count > mv_max_methods.
      ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = 1 ).
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-interface_segregation ).
    ENDIF.
  ENDMETHOD.

  METHOD is_interface.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-interface.
      rv_is_intf = abap_true.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    rv_is_intf = xsdbool( ls_first_stmt-keyword = 'INTERFACE' ).
  ENDMETHOD.
ENDCLASS.
