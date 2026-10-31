CLASS zcl_skylint_no_shadow DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        shadow TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_SHADOW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_SHADOW'.

ENDCLASS.


CLASS zcl_skylint_no_shadow IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid local variables shadowing class attributes'
                                 remote_enablement = abap_false
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-shadow
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Local variable shadows a class attribute; rename it'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_rtti_name  TYPE string.
    DATA lv_name       TYPE string.
    DATA lt_attributes TYPE string_table.
    DATA ls_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_rtti_name = zcl_skylint_rtti_util=>resolve_class_rtti_name( is_procedure ).
    IF lv_rtti_name IS INITIAL.
      RETURN.
    ENDIF.

    lt_attributes = zcl_skylint_rtti_util=>get_attribute_names( lv_rtti_name ).
    IF lt_attributes IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        ls_ref = zcl_skylint_ast_util=>get_reference(
                     is_token = <ls_token>
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
        IF zcl_skylint_ast_util=>is_data_definition( ls_ref ) = abap_false.
          CONTINUE.
        ENDIF.

        lv_name = zcl_skylint_ast_util=>get_reference_name( ls_ref-full_name ).
        IF lv_name IS NOT INITIAL AND line_exists( lt_attributes[ table_line = lv_name ] ).
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-shadow ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
