CLASS zcl_skylint_ast_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_token_lexemes TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLASS-METHODS get_token_safe
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index     TYPE i
      EXPORTING es_token     TYPE if_ci_atc_source_code_provider=>ty_token
                ev_found     TYPE abap_bool.

    CLASS-METHODS get_statement_safe
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_index      TYPE i
      EXPORTING es_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                ev_found      TYPE abap_bool.

    CLASS-METHODS find_token_sequence
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_index)   TYPE i.

    CLASS-METHODS match_token_sequence
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i         DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS matches_token_at
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index          TYPE i
                iv_expected       TYPE string
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS token_has_ref
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_kind       TYPE if_ci_atc_source_code_provider=>ty_reference_kind
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS statement_has_db_access
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS statement_is_method_call
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS has_token_lexeme
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_ast_util IMPLEMENTATION.
  METHOD get_token_safe.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR es_token.
    ev_found = abap_false.

    IF iv_index <= 0 OR iv_index > lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    ASSIGN is_statement-tokens[ iv_index ] TO <ls_token>.
    IF sy-subrc = 0.
      es_token = <ls_token>.
      ev_found = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_statement_safe.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR es_statement.
    ev_found = abap_false.

    IF iv_index <= 0 OR iv_index > lines( it_statements ).
      RETURN.
    ENDIF.

    ASSIGN it_statements[ iv_index ] TO <ls_statement>.
    IF sy-subrc = 0.
      es_statement = <ls_statement>.
      ev_found = abap_true.
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
    DATA ls_act_token      TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_exp>   TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

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

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM iv_start_index.
      lv_start = sy-tabix.
      IF lv_start + lv_expected_count - 1 > lv_token_count.
        EXIT.
      ENDIF.

      lv_all_match = abap_true.
      DO lv_expected_count TIMES.
        lv_offset = sy-index - 1.
        lv_exp_idx = sy-index.
        lv_tok_idx = lv_start + lv_offset.

        ASSIGN it_expected[ lv_exp_idx ] TO <ls_exp>.
        IF sy-subrc <> 0.
          lv_all_match = abap_false.
          EXIT.
        ENDIF.
        ls_exp_token = <ls_exp>.

        READ TABLE is_statement-tokens INTO ls_act_token INDEX lv_tok_idx.
        IF sy-subrc <> 0.
          lv_all_match = abap_false.
          EXIT.
        ENDIF.

        IF iv_case_sensitive = abap_true.
          lv_expected = ls_exp_token.
          lv_actual = ls_act_token-lexeme.
        ELSE.
          lv_expected = to_upper( ls_exp_token ).
          lv_actual = to_upper( ls_act_token-lexeme ).
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
    ENDLOOP.
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
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found    TYPE abap_bool.
    DATA lv_actual   TYPE string.
    DATA lv_expected TYPE string.

    rv_matched = abap_false.

    IF iv_index <= 0.
      RETURN.
    ENDIF.

    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = iv_index
                    IMPORTING es_token     = ls_token
                              ev_found     = lv_found ).

    IF lv_found = abap_false.
      RETURN.
    ENDIF.

    IF iv_case_sensitive = abap_true.
      lv_actual = ls_token-lexeme.
      lv_expected = iv_expected.
    ELSE.
      lv_actual = to_upper( ls_token-lexeme ).
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

  METHOD statement_has_db_access.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      LOOP AT ls_tok-references INTO ls_ref.
        IF    ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read_database
           OR ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-write_database.
          rv_has = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_is_method_call.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    CASE is_statement-keyword.
      WHEN '+CALL_METHOD' OR 'CALL'.
        rv_has = abap_true.
        RETURN.
    ENDCASE.

    LOOP AT is_statement-tokens INTO ls_tok.
      IF token_has_ref( is_token = ls_tok
                        iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ) = abap_true.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_token_lexeme.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_first TYPE string.

    rv_has = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
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
ENDCLASS.
