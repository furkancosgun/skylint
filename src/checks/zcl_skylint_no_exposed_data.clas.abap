CLASS zcl_skylint_no_exposed_data DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        public_attribute TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_PUB_ATR',
        interface_data   TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_INTF_DA',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_attr TYPE string VALUE 'NO_PUBLIC_ATTR'.
    CONSTANTS c_pseudo_comment_intf TYPE string VALUE 'NO_INTERFACE_DATA'.

    DATA mv_check_public_attr TYPE abap_bool VALUE abap_true.
    DATA mv_check_intf_data   TYPE abap_bool VALUE abap_true.

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
    DATA lv_in_intf   TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'INTERFACE'.
          lv_in_intf = abap_true.

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
          IF lv_in_intf = abap_true.
            IF mv_check_intf_data = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-interface_data ).
            ENDIF.
          ELSEIF lv_in_public = abap_true.
            IF     mv_check_public_attr = abap_true
               AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                           iv_lexeme    = 'READ-ONLY' )  = abap_false.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-public_attribute ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
