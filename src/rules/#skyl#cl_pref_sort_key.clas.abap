CLASS /skyl/cl_pref_sort_key DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        sort_key TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_SORTK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_SORT_KEY'.

ENDCLASS.


CLASS /skyl/cl_pref_sort_key IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Sort With an Explicit Sort Key'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-sort_key
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'SORT statement has no explicit BY key - implicit standard key is used'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SORT'.
        CONTINUE.
      ENDIF.

      IF /skyl/cl_ast_util=>find_token( is_statement = <ls_statement>
                                        iv_lexeme    = 'BY' ) = 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-sort_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
