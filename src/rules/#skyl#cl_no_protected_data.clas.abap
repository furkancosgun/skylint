CLASS /skyl/cl_no_protected_data DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        protected_data TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_PROTDAT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_PROTECTED_DATA'.

ENDCLASS.


CLASS /skyl/cl_no_protected_data IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid declaring DATA or CLASS-DATA in PROTECTED SECTION'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-protected_data
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid protected attributes; make them private and provide methods instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_in_protected TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_in_protected = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PROTECTED'.
          IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                  iv_lexeme    = 'SECTION' ) = abap_true.
            lv_in_protected = abap_true.
          ENDIF.

        WHEN 'PUBLIC' OR 'PRIVATE'.
          IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                  iv_lexeme    = 'SECTION' ) = abap_true.
            lv_in_protected = abap_false.
          ENDIF.

        WHEN 'DATA' OR 'CLASS-DATA'.
          IF lv_in_protected = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-protected_data ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
