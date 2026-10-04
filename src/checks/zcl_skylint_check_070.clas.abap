CLASS zcl_skylint_check_070 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dyn_sql TYPE zif_skylint_types=>ty_finding_code VALUE 'DYN_SQL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_070 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid dynamic SQL table or clause names without sanitization'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-dyn_sql
                       severity = zif_skylint_types=>severities-warning
                       text     = 'Avoid dynamic table or clause in SQL; use static SQL or sanitize' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_is_dynamic TYPE abap_bool.
    DATA ls_next       TYPE zif_skylint_types=>ty_token.
    DATA lv_lexeme     TYPE string.
    DATA lv_next_lex   TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'DELETE' OR keyword = 'MODIFY'.
      lv_is_dynamic = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_lexeme = to_upper( <ls_token>-lexeme ).
        IF NOT ( lv_lexeme = 'FROM' OR lv_lexeme = 'WHERE' OR lv_lexeme = 'JOIN' ).
          CONTINUE.
        ENDIF.

        ls_next = zcl_skylint_ast_util=>get_token_after( is_statement   = <ls_statement>
                                                         iv_lexeme      = lv_lexeme
                                                         iv_start_index = sy-tabix ).
        lv_next_lex = ls_next-lexeme.
        IF lv_next_lex IS NOT INITIAL AND ( lv_next_lex CP '(*' OR lv_next_lex = '(' ).
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
