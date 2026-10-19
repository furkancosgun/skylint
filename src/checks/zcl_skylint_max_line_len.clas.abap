CLASS zcl_skylint_max_line_len DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        line_length TYPE if_ci_atc_check=>ty_finding_code VALUE 'LINE_LEN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LINE_LEN'.

    DATA mv_max_length TYPE i VALUE 120.

ENDCLASS.


CLASS zcl_skylint_max_line_len IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Maximum Line Length'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-line_length
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Line length exceeds configured maximum limit'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'MAX_LENGTH'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_max_length ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_line        TYPE i.
    DATA lv_end_col     TYPE i.
    DATA lv_token_count TYPE i.
    DATA lv_token_idx   TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF mv_max_length <= 0.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_token_count = lines( <ls_statement>-tokens ).
      lv_token_idx   = 0.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_token_idx += 1.
        lv_line    = <ls_token>-position-line.
        lv_end_col = <ls_token>-position-column + strlen( <ls_token>-lexeme ) - 1.
        IF lv_token_idx = lv_token_count.
          lv_end_col += 1.
        ENDIF.

        IF lv_end_col > mv_max_length.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-line_length ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
