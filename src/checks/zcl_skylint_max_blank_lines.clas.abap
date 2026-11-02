CLASS zcl_skylint_max_blank_lines DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        max_blank TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_BLANKL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_BLANK_LINES'.

    DATA mv_max_blanks TYPE i VALUE 1.

    METHODS get_statement_end
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE i.

ENDCLASS.


CLASS zcl_skylint_max_blank_lines IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'No Excessive Consecutive Empty Lines'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-max_blank
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Too many consecutive empty lines - collapse them'
                                                pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_BLANKS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_blanks ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_prev TYPE i.
    DATA lv_end  TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_end = get_statement_end( <ls_statement> ).

      IF lv_prev > 0 AND <ls_statement>-position-line - lv_prev - 1 > mv_max_blanks.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-max_blank ).
      ENDIF.

      IF lv_end > lv_prev.
        lv_prev = lv_end.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_statement_end.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_line = is_statement-position-line.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-position-line > rv_line.
        rv_line = <ls_token>-position-line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
