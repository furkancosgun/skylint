CLASS zcl_skylint_no_bypass_buf DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bypass_buffer TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_BYP_BUF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_BYPASS_BUFFER'.

ENDCLASS.


CLASS zcl_skylint_no_bypass_buf IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid BYPASSING BUFFER in SELECT statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bypass_buffer
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid BYPASSING BUFFER; leverage SAP table buffer for cached data access'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `BYPASSING` ) ( `BUFFER` ) ) ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-bypass_buffer ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
