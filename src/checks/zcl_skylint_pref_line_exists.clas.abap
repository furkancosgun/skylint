CLASS zcl_skylint_pref_line_exists DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LINE_EXISTS'.

    METHODS has_transporting_no_fields
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_line_exists IMPLEMENTATION.
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
         WHERE keyword = 'READ' OR keyword = 'LOOP'.
      IF has_transporting_no_fields( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_line_exists ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_transporting_no_fields.
    DATA lv_seq_index TYPE i.

    rv_has = abap_false.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `BINARY` ) ( `SEARCH` ) ) ) > 0.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                         iv_lexeme    = 'WHERE' ) > 0.
      RETURN.
    ENDIF.

    lv_seq_index = zcl_skylint_ast_util=>find_token_sequence(
                       is_statement = is_statement
                       it_expected  = VALUE #( ( `TRANSPORTING` ) ( `NO` ) ( `FIELDS` ) ) ).
    IF lv_seq_index > 0.
      rv_has = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
