CLASS zcl_skylint_no_exposed_data DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        public_attribute TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOPUBATTR',
        interface_data   TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTF_DATA',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_attr TYPE string VALUE 'PUBLIC_ATTR'.
    CONSTANTS c_pseudo_comment_intf TYPE string VALUE 'INTF_DATA'.

    DATA mv_check_public_attr TYPE abap_bool VALUE abap_true.
    DATA mv_check_intf_data   TYPE abap_bool VALUE abap_true.

    METHODS is_interface
      IMPORTING is_procedure      TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is_intf) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_exposed_data IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable data in public classes and interfaces'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-public_attribute
                       text           = 'Avoid public attributes; use private/protected with getters or READ-ONLY'
                       pseudo_comment = c_pseudo_comment_attr )
                     ( code           = c_finding_codes-interface_data
                       text           = 'Avoid mutable DATA in interfaces; declare CONSTANTS or move to class'
                       pseudo_comment = c_pseudo_comment_intf ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_PUBLIC_ATTR'
                                                value = REF #( mv_check_public_attr ) )
                                              ( name  = 'CHECK_INTF_DATA'
                                                value = REF #( mv_check_intf_data ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_public TYPE abap_bool.
    DATA lv_is_intf   TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_is_intf = is_interface( is_procedure ).

    IF lv_is_intf = abap_true.
      IF mv_check_intf_data = abap_false.
        RETURN.
      ENDIF.
      LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
        IF <ls_statement>-keyword <> 'DATA' AND <ls_statement>-keyword <> 'CLASS-DATA'.
          CONTINUE.
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-interface_data ).
      ENDLOOP.
      RETURN.
    ENDIF.

    IF mv_check_public_attr = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PUBLIC'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'SECTION' ) = abap_true.
            lv_in_public = abap_true.
          ENDIF.
        WHEN 'PROTECTED' OR 'PRIVATE'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'SECTION' ) = abap_true.
            lv_in_public = abap_false.
          ENDIF.
        WHEN 'DATA' OR 'CLASS-DATA'.
          IF     lv_in_public = abap_true
             AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'READ-ONLY' )  = abap_false.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-public_attribute ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
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
