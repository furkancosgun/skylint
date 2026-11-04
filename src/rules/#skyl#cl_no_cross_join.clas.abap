CLASS /skyl/cl_no_cross_join DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        cross_join TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CROSS_J',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CROSS_JOIN'.

ENDCLASS.


CLASS /skyl/cl_no_cross_join IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid CROSS JOIN in ABAP SQL queries'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-cross_join
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid CROSS JOIN; cartesian products cause heavy database and memory load'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      IF /skyl/cl_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CROSS` ) ( `JOIN` ) ) ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-cross_join ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
