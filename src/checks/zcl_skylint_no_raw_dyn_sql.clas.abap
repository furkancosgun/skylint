CLASS zcl_skylint_no_raw_dyn_sql DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dyn_sql TYPE if_ci_atc_check=>ty_finding_code VALUE 'DYN_SQL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RAW_DYN_SQL'.
ENDCLASS.


CLASS zcl_skylint_no_raw_dyn_sql IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid dynamic SQL table or clause names without sanitization'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-dyn_sql
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid dynamic table or clause in SQL; use static SQL or sanitize'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_is_dynamic TYPE abap_bool.
    DATA ls_next       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lexeme     TYPE string.
    DATA lv_next_lex   TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'DELETE' OR keyword = 'MODIFY'.
      lv_is_dynamic = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF <ls_token>-references IS NOT INITIAL.
          CONTINUE.
        ENDIF.
        lv_lexeme = <ls_token>-lexeme.
        IF NOT ( lv_lexeme = 'FROM' OR lv_lexeme = 'WHERE' OR lv_lexeme = 'JOIN' ).
          CONTINUE.
        ENDIF.

        ls_next = zcl_skylint_ast_util=>get_token_after( is_statement   = <ls_statement>
                                                         iv_lexeme      = lv_lexeme
                                                         iv_start_index = sy-tabix ).
        lv_next_lex = ls_next-lexeme.
        IF lv_next_lex IS NOT INITIAL AND lv_next_lex CP '(*)'.
          lv_is_dynamic = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_is_dynamic = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dyn_sql ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
