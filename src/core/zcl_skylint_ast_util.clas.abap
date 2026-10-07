CLASS zcl_skylint_ast_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_token_lexemes TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLASS-METHODS get_token
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
                iv_index        TYPE i
      RETURNING VALUE(rs_token) TYPE zif_skylint_types=>ty_token.

    CLASS-METHODS get_token_lexeme
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_index          TYPE i
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_lexeme)  TYPE string.

    CLASS-METHODS get_first_token
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rs_token) TYPE zif_skylint_types=>ty_token.

    CLASS-METHODS get_last_token
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rs_token) TYPE zif_skylint_types=>ty_token.

    CLASS-METHODS get_statement
      IMPORTING it_statements       TYPE zif_skylint_types=>ty_statements
                iv_index            TYPE i
      RETURNING VALUE(rs_statement) TYPE zif_skylint_types=>ty_statement.

    CLASS-METHODS get_next_statement
      IMPORTING it_statements       TYPE zif_skylint_types=>ty_statements
                iv_current_index    TYPE i
      RETURNING VALUE(rs_statement) TYPE zif_skylint_types=>ty_statement.

    CLASS-METHODS get_previous_statement
      IMPORTING it_statements       TYPE zif_skylint_types=>ty_statements
                iv_current_index    TYPE i
      RETURNING VALUE(rs_statement) TYPE zif_skylint_types=>ty_statement.

    CLASS-METHODS find_token
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_lexeme         TYPE string
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_index)   TYPE i.

    CLASS-METHODS get_token_after
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_lexeme         TYPE string
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rs_token)   TYPE zif_skylint_types=>ty_token.

    CLASS-METHODS get_token_before
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_lexeme         TYPE string
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rs_token)   TYPE zif_skylint_types=>ty_token.

    CLASS-METHODS find_token_sequence
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_index)   TYPE i.

    CLASS-METHODS get_token_after_sequence
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rs_token)   TYPE zif_skylint_types=>ty_token.

    CLASS-METHODS match_token_sequence
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS matches_token_at
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
                iv_index          TYPE i
                iv_expected       TYPE string
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS statement_is_method_call
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS is_assignment
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS has_token_lexeme
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS token_is_literal
      IMPORTING is_token      TYPE zif_skylint_types=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS token_is_identifier
      IMPORTING is_token      TYPE zif_skylint_types=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_comparison_operator
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS has_compiler_reference
      IMPORTING is_token      TYPE zif_skylint_types=>ty_token
                iv_kind       TYPE zif_skylint_types=>ty_reference_kind
                iv_usage_mode TYPE zif_skylint_types=>ty_usage_mode OPTIONAL
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS token_count
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

    CLASS-METHODS statement_count
      IMPORTING it_statements   TYPE zif_skylint_types=>ty_statements
      RETURNING VALUE(rv_count) TYPE i.

    CLASS-METHODS is_declared_data
      IMPORTING it_statements  TYPE zif_skylint_types=>ty_statements
                iv_name       TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

  PRIVATE SECTION.
    CLASS-METHODS token_has_ref
      IMPORTING is_token      TYPE zif_skylint_types=>ty_token
                iv_kind       TYPE zif_skylint_types=>ty_reference_kind
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS normalize_identifier_name
      IMPORTING iv_raw         TYPE string
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_ast_util IMPLEMENTATION.
  METHOD get_token.
    FIELD-SYMBOLS <ls_token> TYPE zif_skylint_types=>ty_token.

    CLEAR rs_token.
    IF iv_index <= 0 OR iv_index > lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    ASSIGN is_statement-tokens[ iv_index ] TO <ls_token>.
    IF sy-subrc = 0.
      rs_token = <ls_token>.
    ENDIF.
  ENDMETHOD.

  METHOD get_token_lexeme.
    DATA ls_token TYPE zif_skylint_types=>ty_token.

    CLEAR rv_lexeme.
    ls_token = get_token( is_statement = is_statement
                          iv_index     = iv_index ).
    IF ls_token-lexeme IS NOT INITIAL.
      IF iv_case_sensitive = abap_true.
        rv_lexeme = ls_token-lexeme.
      ELSE.
        rv_lexeme = to_upper( ls_token-lexeme ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_first_token.
    rs_token = get_token( is_statement = is_statement
                          iv_index     = 1 ).
  ENDMETHOD.

  METHOD get_last_token.
    DATA lv_count TYPE i.

    CLEAR rs_token.
    lv_count = lines( is_statement-tokens ).
    IF lv_count > 0.
      rs_token = get_token( is_statement = is_statement
                            iv_index     = lv_count ).
    ENDIF.
  ENDMETHOD.

  METHOD get_statement.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    CLEAR rs_statement.
    IF iv_index <= 0 OR iv_index > lines( it_statements ).
      RETURN.
    ENDIF.

    ASSIGN it_statements[ iv_index ] TO <ls_statement>.
    IF sy-subrc = 0.
      rs_statement = <ls_statement>.
    ENDIF.
  ENDMETHOD.

  METHOD get_next_statement.
    rs_statement = get_statement( it_statements = it_statements
                                  iv_index      = iv_current_index + 1 ).
  ENDMETHOD.

  METHOD get_previous_statement.
    rs_statement = get_statement( it_statements = it_statements
                                  iv_index      = iv_current_index - 1 ).
  ENDMETHOD.

  METHOD find_token.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_act   TYPE string.
    DATA lv_exp   TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    rv_index = 0.
    lv_count = lines( is_statement-tokens ).
    IF iv_start_index <= 0 OR iv_start_index > lv_count.
      RETURN.
    ENDIF.

    IF iv_case_sensitive = abap_true.
      lv_exp = iv_lexeme.
    ELSE.
      lv_exp = to_upper( iv_lexeme ).
    ENDIF.

    lv_idx = iv_start_index.
    WHILE lv_idx <= lv_count.
      ASSIGN is_statement-tokens[ lv_idx ] TO <ls_tok>.
      IF sy-subrc = 0 AND <ls_tok>-references IS INITIAL.
        IF iv_case_sensitive = abap_true.
          lv_act = <ls_tok>-lexeme.
        ELSE.
          lv_act = to_upper( <ls_tok>-lexeme ).
        ENDIF.
        IF lv_act = lv_exp.
          rv_index = lv_idx.
          RETURN.
        ENDIF.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_token_after.
    DATA lv_idx TYPE i.

    CLEAR rs_token.
    lv_idx = find_token( is_statement      = is_statement
                         iv_lexeme         = iv_lexeme
                         iv_start_index    = iv_start_index
                         iv_case_sensitive = iv_case_sensitive ).
    IF lv_idx > 0.
      rs_token = get_token( is_statement = is_statement
                            iv_index     = lv_idx + 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD get_token_before.
    DATA lv_idx TYPE i.

    CLEAR rs_token.
    lv_idx = find_token( is_statement      = is_statement
                         iv_lexeme         = iv_lexeme
                         iv_start_index    = iv_start_index
                         iv_case_sensitive = iv_case_sensitive ).
    IF lv_idx > 1.
      rs_token = get_token( is_statement = is_statement
                            iv_index     = lv_idx - 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD find_token_sequence.
    DATA lv_expected_count TYPE i.
    DATA lv_token_count    TYPE i.
    DATA lv_start          TYPE i.
    DATA lv_offset         TYPE i.
    DATA lv_exp_idx        TYPE i.
    DATA lv_tok_idx        TYPE i.
    DATA lv_expected       TYPE string.
    DATA lv_actual         TYPE string.
    DATA lv_all_match      TYPE abap_bool.
    DATA ls_exp_token      TYPE string.
    DATA ls_act_token      TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_exp> TYPE string.

    rv_index = 0.
    lv_expected_count = lines( it_expected ).
    lv_token_count = lines( is_statement-tokens ).

    IF lv_expected_count = 0 OR lv_token_count = 0.
      RETURN.
    ENDIF.

    IF iv_start_index <= 0 OR iv_start_index > lv_token_count.
      RETURN.
    ENDIF.

    IF lv_expected_count > lv_token_count.
      RETURN.
    ENDIF.

    DO lv_token_count - iv_start_index + 1 TIMES.
      lv_start = iv_start_index + sy-index - 1.
      IF lv_start + lv_expected_count - 1 > lv_token_count.
        EXIT.
      ENDIF.

      lv_all_match = abap_true.
      DO lv_expected_count TIMES.
        lv_offset  = sy-index - 1.
        lv_exp_idx = sy-index.
        lv_tok_idx = lv_start + lv_offset.

        ASSIGN it_expected[ lv_exp_idx ] TO <ls_exp>.
        IF sy-subrc <> 0.
          lv_all_match = abap_false.
          EXIT.
        ENDIF.
        ls_exp_token = <ls_exp>.

        READ TABLE is_statement-tokens INTO ls_act_token INDEX lv_tok_idx.
        IF sy-subrc <> 0 OR ls_act_token-references IS NOT INITIAL.
          lv_all_match = abap_false.
          EXIT.
        ENDIF.

        IF iv_case_sensitive = abap_true.
          lv_expected = ls_exp_token.
          lv_actual   = ls_act_token-lexeme.
        ELSE.
          lv_expected = to_upper( ls_exp_token ).
          lv_actual   = to_upper( ls_act_token-lexeme ).
        ENDIF.

        IF lv_expected <> lv_actual.
          lv_all_match = abap_false.
          EXIT.
        ENDIF.
      ENDDO.

      IF lv_all_match = abap_true.
        rv_index = lv_start.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD get_token_after_sequence.
    DATA lv_idx TYPE i.
    DATA lv_cnt TYPE i.

    CLEAR rs_token.
    lv_idx = find_token_sequence( is_statement      = is_statement
                                  it_expected       = it_expected
                                  iv_start_index    = iv_start_index
                                  iv_case_sensitive = iv_case_sensitive ).
    IF lv_idx > 0.
      lv_cnt = lines( it_expected ).
      rs_token = get_token( is_statement = is_statement
                            iv_index     = lv_idx + lv_cnt ).
    ENDIF.
  ENDMETHOD.

  METHOD match_token_sequence.
    DATA lv_index TYPE i.

    rv_matched = abap_false.
    lv_index = find_token_sequence( is_statement      = is_statement
                                    it_expected       = it_expected
                                    iv_start_index    = iv_start_index
                                    iv_case_sensitive = iv_case_sensitive ).

    IF lv_index > 0.
      rv_matched = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD matches_token_at.
    DATA ls_token    TYPE zif_skylint_types=>ty_token.
    DATA lv_actual   TYPE string.
    DATA lv_expected TYPE string.

    rv_matched = abap_false.

    IF iv_index <= 0.
      RETURN.
    ENDIF.

    ls_token = get_token( is_statement = is_statement
                          iv_index     = iv_index ).

    IF ls_token-lexeme IS INITIAL OR ls_token-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF iv_case_sensitive = abap_true.
      lv_actual   = ls_token-lexeme.
      lv_expected = iv_expected.
    ELSE.
      lv_actual   = to_upper( ls_token-lexeme ).
      lv_expected = to_upper( iv_expected ).
    ENDIF.

    IF lv_actual = lv_expected.
      rv_matched = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD token_has_ref.
    rv_has = abap_false.

    LOOP AT is_token-references TRANSPORTING NO FIELDS
         WHERE kind = iv_kind.
      rv_has = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_is_method_call.
    DATA ls_tok TYPE zif_skylint_types=>ty_token.

    rv_has = abap_false.

    CASE is_statement-keyword.
      WHEN '+CALL_METHOD' OR 'CALL'.
        rv_has = abap_true.
        RETURN.
    ENDCASE.

    LOOP AT is_statement-tokens INTO ls_tok.
      IF token_has_ref( is_token = ls_tok
                        iv_kind  = zif_skylint_types=>compiler_reference_kinds-method ) = abap_true.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_assignment.
    rv_yes = xsdbool( is_statement-keyword = 'COMPUTE' ).
  ENDMETHOD.

  METHOD has_token_lexeme.
    DATA ls_tok   TYPE zif_skylint_types=>ty_token.
    DATA lv_first TYPE string.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok WHERE references IS INITIAL.
      IF ls_tok-lexeme IS INITIAL.
        CONTINUE.
      ENDIF.
      lv_first = ls_tok-lexeme(1).
      IF lv_first = '''' OR lv_first = '`'.
        CONTINUE.
      ENDIF.
      IF to_upper( ls_tok-lexeme ) = to_upper( iv_lexeme ).
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD token_is_literal.
    DATA lv_len   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_first TYPE string.
    DATA lv_last  TYPE string.

    rv_yes = abap_false.
    lv_len = strlen( is_token-lexeme ).
    IF lv_len = 0.
      RETURN.
    ENDIF.

    lv_first = is_token-lexeme(1).
    lv_off = lv_len - 1.
    lv_last = is_token-lexeme+lv_off(1).

    IF    ( lv_first = `'` AND lv_last = `'` )
       OR ( lv_first = '`' AND lv_last = '`' )
       OR ( lv_first = '|' AND lv_last = '|' ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF is_token-lexeme CO '0123456789'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD token_is_identifier.
    DATA lv_first TYPE string.

    rv_yes = abap_false.
    IF is_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_first = is_token-lexeme(1).
    IF lv_first CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_/<'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_comparison_operator.
    DATA lv_op TYPE string.

    lv_op = to_upper( iv_lexeme ).
    rv_yes = xsdbool(    lv_op = '='  OR lv_op = '<>' OR lv_op = '<'  OR lv_op = '>'
                      OR lv_op = '<=' OR lv_op = '>=' OR lv_op = 'EQ' OR lv_op = 'NE'
                      OR lv_op = 'LT' OR lv_op = 'GT' OR lv_op = 'LE' OR lv_op = 'GE'
                      OR lv_op = 'CS' OR lv_op = 'CP' OR lv_op = 'NS' OR lv_op = 'NP'
                      OR lv_op = 'CO' OR lv_op = 'CN' OR lv_op = 'CA' OR lv_op = 'NA' ).
  ENDMETHOD.

  METHOD has_compiler_reference.
    FIELD-SYMBOLS <ls_ref> TYPE zif_skylint_types=>ty_compiler_reference.

    rv_has = abap_false.
    LOOP AT is_token-references ASSIGNING <ls_ref> WHERE kind = iv_kind.
      IF iv_usage_mode IS INITIAL OR <ls_ref>-usage_mode = iv_usage_mode.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD token_count.
    rv_count = lines( is_statement-tokens ).
  ENDMETHOD.

  METHOD statement_count.
    rv_count = lines( it_statements ).
  ENDMETHOD.

  METHOD is_declared_data.
    DATA lv_name   TYPE string.
    DATA lv_suffix TYPE string.
    DATA lv_off    TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE zif_skylint_types=>ty_compiler_reference.

    rv_yes = abap_false.
    lv_name = normalize_identifier_name( iv_name ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.
    lv_suffix = |DA:{ lv_name }|.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references ASSIGNING <ls_ref>
             WHERE kind = zif_skylint_types=>compiler_reference_kinds-data.
          IF <ls_ref>-usage_mode = zif_skylint_types=>usage_modes-definition
             OR <ls_ref>-usage_mode = zif_skylint_types=>usage_modes-definition_with_write
             OR <ls_ref>-usage_mode = zif_skylint_types=>usage_modes-definition_with_assign.
            lv_off = strlen( <ls_ref>-full_name ) - strlen( lv_suffix ).
            IF lv_off >= 0 AND <ls_ref>-full_name+lv_off = lv_suffix.
              rv_yes = abap_true.
              RETURN.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD normalize_identifier_name.
    DATA lv_off TYPE i.
    DATA lv_len TYPE i.

    rv_name = to_upper( condense( iv_raw ) ).
    IF rv_name IS INITIAL.
      RETURN.
    ENDIF.
    IF rv_name(1) = '@'.
      rv_name = rv_name+1.
    ENDIF.
    lv_off = strlen( rv_name ) - 1.
    WHILE lv_off >= 0.
      IF rv_name+lv_off(1) = '('.
        lv_off = lv_off + 1.
        lv_len = strlen( rv_name ) - lv_off.
        IF lv_len > 0 AND rv_name+lv_off(lv_len) CA ')'.
          lv_len = lv_len - 1.
        ENDIF.
        IF lv_len > 0.
          rv_name = rv_name+lv_off(lv_len).
        ENDIF.
        RETURN.
      ENDIF.
      lv_off = lv_off - 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
