CLASS zcl_skylint_check_027 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        public_attribute TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOPUBATTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_027 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable public attributes in classes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-public_attribute
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid public attributes; use private/protected with getters or READ-ONLY' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_public TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
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
ENDCLASS.
