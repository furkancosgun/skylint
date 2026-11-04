CLASS /skyl/cl_no_abstract_final DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        abstract_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_ABS_FIN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_ABSTRACT_FINAL'.

ENDCLASS.


CLASS /skyl/cl_no_abstract_final IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'A class cannot be defined as both ABSTRACT and FINAL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-abstract_final
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Class cannot be both ABSTRACT and FINAL'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'DEFINITION' ) = abap_true
         AND /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'ABSTRACT' )   = abap_true
         AND /skyl/cl_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'FINAL' )      = abap_true.

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-abstract_final ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
