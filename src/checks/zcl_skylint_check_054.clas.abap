CLASS zcl_skylint_check_054 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        sql_host_escape TYPE if_ci_atc_check=>ty_finding_code VALUE 'SQL_HOST_E',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SQL_HOST_VAR'.

    METHODS is_unescaped_host_var
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_unescaped_rhs_token
      IMPORTING iv_token      TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_054 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: SQL Escape Host Variables (@)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-sql_host_escape
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Host variables in ABAP SQL must be escaped with @'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE    keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'DELETE'
               OR keyword = 'INSERT' OR keyword = 'MODIFY'.
      IF is_unescaped_host_var( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-sql_host_escape ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_unescaped_host_var.
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lv_tok TYPE string.
    DATA lv_next TYPE string.
    DATA lv_in_where TYPE abap_bool.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_token2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_token5 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found TYPE abap_bool.
    DATA lv_found_next TYPE abap_bool.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_found5 TYPE abap_bool.
    DATA lv_next_up TYPE string.

    rv_res = abap_false.
    lv_in_where = abap_false.
    lv_count = lines( is_statement-tokens ).

    DO lv_count TIMES.
      lv_idx = sy-index.
      get_token_safe( EXPORTING is_statement = is_statement
                                 iv_index     = lv_idx
                       IMPORTING es_token     = ls_token
                                 ev_found     = lv_found ).
      IF lv_found = abap_false.
        CONTINUE.
      ENDIF.
      lv_tok = to_upper( ls_token-lexeme ).

      " 1. Track WHERE / HAVING / SET clause
      IF lv_tok = 'WHERE' OR lv_tok = 'HAVING' OR lv_tok = 'SET'.
        lv_in_where = abap_true.
      ENDIF.

      " 2. Check INTO targets
      IF lv_tok = 'INTO' AND lv_idx < lv_count.
        get_token_safe( EXPORTING is_statement = is_statement
                                   iv_index     = lv_idx + 1
                         IMPORTING es_token     = ls_next_token
                                   ev_found     = lv_found_next ).
      ENDIF.
      IF lv_tok = 'INTO' AND lv_idx < lv_count AND lv_found_next = abap_true.
        lv_next = to_upper( ls_next_token-lexeme ).
        CASE lv_next.
          WHEN 'TABLE'.
            get_token_safe( EXPORTING is_statement = is_statement
                                       iv_index     = lv_idx + 2
                             IMPORTING es_token     = ls_token2
                                       ev_found     = lv_found2 ).
            IF lv_found2 = abap_true AND ls_token2-lexeme(1) <> '@'.
              rv_res = abap_true.
              RETURN.
            ENDIF.
          WHEN 'CORRESPONDING'.
            get_token_safe( EXPORTING is_statement = is_statement
                                       iv_index     = lv_idx + 5
                             IMPORTING es_token     = ls_token5
                                       ev_found     = lv_found5 ).
            IF lv_found5 = abap_true AND ls_token5-lexeme(1) <> '@'.
              rv_res = abap_true.
              RETURN.
            ENDIF.
          WHEN OTHERS.
            lv_next_up = to_upper( ls_next_token-lexeme ).
            IF lv_next_up <> 'DISTINCT' AND lv_next_up(1) <> '(' AND ls_next_token-lexeme(1) <> '@'.
              rv_res = abap_true.
              RETURN.
            ENDIF.
        ENDCASE.
      ENDIF.

      " 3. Check FOR ALL ENTRIES IN <target>
      get_token_safe( EXPORTING is_statement = is_statement
                                 iv_index     = lv_idx + 1
                       IMPORTING es_token     = ls_next_token
                                 ev_found     = lv_found_next ).
      get_token_safe( EXPORTING is_statement = is_statement
                                 iv_index     = lv_idx + 2
                       IMPORTING es_token     = ls_token2
                                 ev_found     = lv_found2 ).
      IF lv_tok = 'ENTRIES' AND lv_found_next = abap_true AND lv_found2 = abap_true
         AND to_upper( ls_next_token-lexeme ) = 'IN' AND ls_token2-lexeme(1) <> '@'.
        rv_res = abap_true.
        RETURN.
      ENDIF.

      " 4. Check comparisons in WHERE / HAVING / SET clause
      IF lv_in_where = abap_true AND lv_idx < lv_count
         AND ( lv_tok = '=' OR lv_tok = '<>' OR lv_tok = '<' OR lv_tok = '>'
            OR lv_tok = '<=' OR lv_tok = '>=' OR lv_tok = 'LIKE' ).
        get_token_safe( EXPORTING is_statement = is_statement
                                   iv_index     = lv_idx + 1
                         IMPORTING es_token     = ls_next_token
                                   ev_found     = lv_found_next ).
      ENDIF.
      IF lv_in_where = abap_true AND lv_idx < lv_count AND lv_found_next = abap_true
         AND ( lv_tok = '=' OR lv_tok = '<>' OR lv_tok = '<' OR lv_tok = '>'
            OR lv_tok = '<=' OR lv_tok = '>=' OR lv_tok = 'LIKE' ).
        lv_next = ls_next_token-lexeme.
        IF is_unescaped_rhs_token( lv_next ) = abap_true.
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD is_unescaped_rhs_token.
    DATA lv_first TYPE c LENGTH 1.
    DATA lv_upper TYPE string.

    rv_res = abap_false.
    IF iv_token IS INITIAL.
      RETURN.
    ENDIF.

    lv_first = iv_token(1).
    " Escaped host variable (@...), string literals ('...', `...`), or numbers/parentheses
    IF    lv_first = '@' OR lv_first = '''' OR lv_first = '`'
       OR lv_first = '(' OR ( lv_first >= '0' AND lv_first <= '9' )
       OR lv_first = '+' OR lv_first = '-'.
      RETURN.
    ENDIF.

    " Join field (tab~field) or DB column reference
    IF iv_token CS '~'.
      RETURN.
    ENDIF.

    lv_upper = to_upper( iv_token ).
    " Built-in SQL keywords / constants
    IF    lv_upper = 'NULL' OR lv_upper = 'INITIAL' OR lv_upper = 'SPACE'
       OR lv_upper = 'TRUE' OR lv_upper = 'FALSE'.
      RETURN.
    ENDIF.

    " Unescaped host variable identifier
    rv_res = abap_true.
  ENDMETHOD.
ENDCLASS.
