CLASS zcl_skylint_no_metaprogramming DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        metaprogramming TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_METAPRG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_METAPROGRAMMING'.

ENDCLASS.


CLASS zcl_skylint_no_metaprogramming IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Metaprogramming and Dynamic Code Generation'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-metaprogramming
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid dynamic code generation and metaprogramming constructs'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'SYNTAX-CHECK'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-metaprogramming ).

        WHEN 'GENERATE'.
          IF    zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `SUBROUTINE` ) = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `REPORT` )     = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `DYNPRO` )     = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-metaprogramming ).
          ENDIF.

        WHEN 'INSERT'.
          IF    zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `REPORT` )     = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `TEXTPOOL` )   = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-metaprogramming ).
          ENDIF.

        WHEN 'DELETE'.
          IF    zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `REPORT` )     = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `TEXTPOOL` )   = abap_true
             OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                        iv_index     = 2
                                                        iv_expected  = `DYNPRO` )     = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-metaprogramming ).
          ENDIF.

        WHEN 'EXPORT'.
          IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 2
                                                     iv_expected  = `DYNPRO` ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-metaprogramming ).
          ENDIF.

        WHEN 'EDITOR-CALL'.
          IF zcl_skylint_ast_util=>find_token_sequence(
                 is_statement = <ls_statement>
                 it_expected  = VALUE #( ( `EDITOR-CALL` ) ( `FOR` ) ( `REPORT` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-metaprogramming ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
