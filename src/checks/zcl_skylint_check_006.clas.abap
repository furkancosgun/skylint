CLASS zcl_skylint_check_006 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_exporting TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITEXPORT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OMIT_EXPORTING'.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_exporting TYPE zcl_skylint_check_base=>ty_quickfix_code VALUE 'OMIT_EXP',
      END OF c_quickfix_codes.

    METHODS is_exempt_statement
      IMPORTING iv_keyword       TYPE string
      RETURNING VALUE(rv_exempt) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_006 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Omit explicit EXPORTING in method calls'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-omit_exporting
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit explicit EXPORTING keyword in method invocation'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #(
                     ( code       = c_quickfix_codes-omit_exporting
                       short_text = 'Remove EXPORTING keyword' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_tok_idx TYPE i.
    DATA lt_expected TYPE ty_token_lexemes.
    DATA lo_details TYPE if_ci_atc_check=>ty_details.
    DATA lt_empty_code TYPE if_ci_atc_quickfix=>ty_code.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lt_expected = VALUE #( ( `EXPORTING` ) ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'METHODS' OR <ls_statement>-keyword = 'CLASS-METHODS'
         OR <ls_statement>-keyword = 'INTERFACES' OR <ls_statement>-keyword = 'CALL'.
        CONTINUE.
      ENDIF.

      IF statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_tok_idx = find_token_sequence( is_statement = <ls_statement>
                                        it_expected  = lt_expected ).
      IF lv_tok_idx = 0.
        CONTINUE.
      ENDIF.

      lv_stmt_idx = sy-tabix.
      lo_details = quickfix_replace( iv_quickfix_code = c_quickfix_codes-omit_exporting
                                     is_procedure_id  = is_procedure-id
                                     iv_statement_from = lv_stmt_idx
                                     iv_token_from    = lv_tok_idx
                                     iv_token_to      = lv_tok_idx
                                     it_new_code      = lt_empty_code ).
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-omit_exporting
                        io_details      = lo_details ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exempt_statement.
    CASE iv_keyword.
      WHEN 'CALL' OR 'EXPORT' OR 'METHODS' OR 'CLASS-METHODS'
        OR 'EVENTS' OR 'CLASS-EVENTS' OR 'INTERFACES' OR 'SUBMIT'
        OR 'FORM' OR 'FUNCTION' OR 'MODULE'.
        rv_exempt = abap_true.
      WHEN OTHERS.
        rv_exempt = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
