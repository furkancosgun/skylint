CLASS /skyl/cl_pref_union DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_union TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_UNION',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_UNION'.

ENDCLASS.


CLASS /skyl/cl_pref_union IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer UNION over UNION ALL in SQL queries'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_union
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer UNION over UNION ALL in SQL queries'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lt_seq TYPE /skyl/cl_ast_util=>ty_token_lexemes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lt_seq = VALUE #( ( `UNION` )
                      ( `ALL` ) ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      IF /skyl/cl_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = lt_seq ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_union ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
