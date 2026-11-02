CLASS zcl_skylint_no_lead_wildcard DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        leading_wildcard TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_LD_WILD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_LEAD_WILDCARD'.

ENDCLASS.


CLASS zcl_skylint_no_lead_wildcard IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid leading wildcard (% or +) in LIKE conditions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-leading_wildcard
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid leading wildcard (% or +) in LIKE; prevents index usage causing full scan'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx     TYPE i.
    DATA ls_val_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_val     TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_idx = sy-tabix.
        IF <ls_token>-references IS NOT INITIAL OR to_upper( <ls_token>-lexeme ) <> 'LIKE'.
          CONTINUE.
        ENDIF.

        ls_val_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                      iv_index     = lv_idx + 1 ).
        IF ls_val_tok-references IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        IF zcl_skylint_ast_util=>token_is_literal( ls_val_tok ) = abap_false.
          CONTINUE.
        ENDIF.

        lv_val = ls_val_tok-lexeme.
        IF strlen( lv_val ) >= 2 AND ( lv_val(1) = `'` OR lv_val(1) = '`' ).
          lv_val = substring( val = lv_val
                              off = 1
                              len = strlen( lv_val ) - 2 ).
        ENDIF.

        IF lv_val IS NOT INITIAL AND ( lv_val(1) = '%' OR lv_val(1) = '+' ).
          report_token( is_token        = ls_val_tok
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-leading_wildcard ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
