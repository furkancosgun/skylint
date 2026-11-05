CLASS /skyl/cl_no_into_fs DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        into_field_symbol TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_INTO_FS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INTO_FS'.

ENDCLASS.


CLASS /skyl/cl_no_into_fs IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Do not use INTO with a field symbol; use ASSIGNING instead'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-into_field_symbol
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Do not use INTO with a field symbol; use ASSIGNING instead'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA ls_target TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'READ' AND <ls_statement>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      ls_target = /skyl/cl_ast_util=>get_token_after( is_statement = <ls_statement>
                                                      iv_lexeme    = 'INTO' ).
      IF ls_target IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_target-lexeme(1) = '<'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-into_field_symbol ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
