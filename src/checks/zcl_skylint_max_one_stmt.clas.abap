CLASS zcl_skylint_max_one_stmt DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        max_one_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'ONE_STMT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'ONE_STMT'.

ENDCLASS.


CLASS zcl_skylint_max_one_stmt IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Max One Statement Per Line'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-max_one_statement
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Only one statement is allowed per line'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_prev_end_line TYPE i VALUE 0.
    DATA lv_stmt_start    TYPE i.
    DATA lv_stmt_end      TYPE i.
    DATA ls_tok_first     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_last      TYPE if_ci_atc_source_code_provider=>ty_token.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      ls_tok_first = zcl_skylint_ast_util=>get_first_token( <ls_statement> ).
      ls_tok_last  = zcl_skylint_ast_util=>get_last_token( <ls_statement> ).

      lv_stmt_start = ls_tok_first-position-line.
      lv_stmt_end   = ls_tok_last-position-line.

      IF lv_prev_end_line > 0 AND lv_stmt_start = lv_prev_end_line.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-max_one_statement ).
      ENDIF.

      lv_prev_end_line = lv_stmt_end.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
