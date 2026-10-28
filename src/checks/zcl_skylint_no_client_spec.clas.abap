CLASS zcl_skylint_no_client_spec DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        client_spec TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CLNT_SP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CLIENT_SPEC'.
ENDCLASS.


CLASS zcl_skylint_no_client_spec IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-client_spec
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid explicit client specification in ABAP SQL'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword <> 'SELECT'
         AND <ls_statement>-keyword <> 'UPDATE'
         AND <ls_statement>-keyword <> 'MODIFY'
         AND <ls_statement>-keyword <> 'DELETE'
         AND <ls_statement>-keyword <> 'INSERT'.
        CONTINUE.
      ENDIF.
      IF    zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                       it_expected  = VALUE #( ( `USING` ) ( `CLIENT` ) ) ) > 0
         OR zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                       it_expected  = VALUE #( ( `CLIENT` )
                                                                               ( `SPECIFIED` ) ) )          > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-client_spec ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
