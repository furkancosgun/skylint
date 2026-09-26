CLASS zcl_skylint_check_012 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_line_exists TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFLINEX',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_LINE_EXISTS'.

    METHODS has_transporting_no_fields
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_012 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_line_exists
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'READ'.
      IF has_transporting_no_fields( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_line_exists ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_transporting_no_fields.
    DATA lv_tok_cnt TYPE i.
    DATA lv_idx     TYPE i.
    DATA lv_t1_idx  TYPE i.
    DATA lv_t2_idx  TYPE i.
    DATA lv_lex     TYPE string.
    DATA lv_t1_lex  TYPE string.
    DATA lv_t2_lex  TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    lv_tok_cnt = lines( is_statement-tokens ).

    DO lv_tok_cnt TIMES.
      lv_idx = sy-index.
      READ TABLE is_statement-tokens ASSIGNING <ls_token> INDEX lv_idx.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_lex = to_upper( <ls_token>-lexeme ).
      IF lv_lex <> 'TRANSPORTING'.
        CONTINUE.
      ENDIF.

      lv_t1_idx = lv_idx + 1.
      lv_t2_idx = lv_idx + 2.
      IF lv_t2_idx > lv_tok_cnt.
        CONTINUE.
      ENDIF.

      READ TABLE is_statement-tokens ASSIGNING <ls_token> INDEX lv_t1_idx.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lv_t1_lex = to_upper( <ls_token>-lexeme ).

      READ TABLE is_statement-tokens ASSIGNING <ls_token> INDEX lv_t2_idx.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lv_t2_lex = to_upper( <ls_token>-lexeme ).

      IF lv_t1_lex = 'NO' AND lv_t2_lex = 'FIELDS'.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
