CLASS zcl_skylint_token_navigator DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_token_navigator.

  PRIVATE SECTION.
    METHODS get_next_keyword_token
      IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
                io_after       TYPE REF TO if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(ro_next) TYPE REF TO if_ci_atc_source_code_provider=>ty_token.

    METHODS find_keyword_sequence_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                it_keywords     TYPE string_table
      RETURNING VALUE(ro_token) TYPE REF TO if_ci_atc_source_code_provider=>ty_token.

ENDCLASS.


CLASS zcl_skylint_token_navigator IMPLEMENTATION.
  METHOD zif_skylint_token_navigator~is_keyword.
    rv_yes = xsdbool( iv_token-references IS INITIAL AND iv_token-lexeme = iv_keyword ).
  ENDMETHOD.

  METHOD zif_skylint_token_navigator~bracket_type.
    DATA(lv_lexeme) = iv_token-lexeme.
    DATA(lv_len)    = strlen( lv_lexeme ).

    IF lv_len = 0.
      rv_type = zif_skylint_types=>bracket_type-none.
      RETURN.
    ENDIF.

    DATA(lv_first)  = lv_lexeme(1).
    DATA(lv_offset) = lv_len - 1.
    DATA(lv_last)   = COND string( WHEN lv_offset > 0
                                   THEN lv_lexeme+lv_offset(1)
                                   ELSE lv_first ).

    rv_type = SWITCH #( lv_last
                        WHEN ')' THEN SWITCH #( lv_first
                                                WHEN '('
                                                THEN zif_skylint_types=>bracket_type-clopening
                                                ELSE zif_skylint_types=>bracket_type-closing )
                        WHEN '(' THEN zif_skylint_types=>bracket_type-opening
                        ELSE          zif_skylint_types=>bracket_type-none ).
  ENDMETHOD.

  METHOD zif_skylint_token_navigator~find_token.
    DATA(lv_from_found) = xsdbool( iv_from IS INITIAL ).

    LOOP AT it_tokens REFERENCE INTO DATA(lr_token)
         WHERE references IS INITIAL.
      IF lv_from_found = abap_false.
        IF lr_token = iv_from.
          lv_from_found = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.
      IF lr_token->lexeme = iv_lexeme.
        ro_token = lr_token.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_skylint_token_navigator~find_clause.
    DATA(lv_from_found) = xsdbool( iv_from IS INITIAL ).

    DATA lt_parts TYPE string_table.
    SPLIT condense( iv_clause ) AT space INTO TABLE lt_parts.
    IF lt_parts IS INITIAL OR lt_parts[ 1 ] IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_first_part) = lt_parts[ 1 ].

    LOOP AT it_tokens REFERENCE INTO DATA(lr_candidate)
         WHERE references IS INITIAL AND lexeme = lv_first_part.
      IF lv_from_found = abap_false.
        IF lr_candidate = iv_from.
          lv_from_found = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.

      DATA(lv_match) = abap_true.
      DATA(lv_token_ref) = lr_candidate.

      LOOP AT lt_parts REFERENCE INTO DATA(lr_part) FROM 2.
        lv_token_ref = get_next_keyword_token( it_tokens = it_tokens
                                               io_after  = lv_token_ref ).
        IF lv_token_ref IS INITIAL OR lv_token_ref->lexeme <> lr_part->*.
          lv_match = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_match = abap_true.
        ro_token = lr_candidate.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_skylint_token_navigator~has_clause.
    rv_yes = xsdbool( zif_skylint_token_navigator~find_clause( it_tokens = it_tokens
                                                               iv_clause = iv_clause ) IS NOT INITIAL ).
  ENDMETHOD.

  METHOD zif_skylint_token_navigator~has_keyword_sequence.
    rv_yes = xsdbool( find_keyword_sequence_token( is_statement = is_statement
                                                   it_keywords  = it_keywords ) IS NOT INITIAL ).
  ENDMETHOD.

  METHOD zif_skylint_token_navigator~find_closing_bracket.
    DATA(lv_type) = zif_skylint_token_navigator~bracket_type( io_open_token->* ).

    IF     lv_type <> zif_skylint_types=>bracket_type-opening
       AND lv_type <> zif_skylint_types=>bracket_type-clopening.
      RAISE EXCEPTION NEW zcx_skylint_error( message = |Token is not an opening bracket| ).
    ENDIF.

    DATA(lv_counter)   = 1.
    DATA(lv_past_open) = abap_false.

    LOOP AT is_statement-tokens REFERENCE INTO DATA(lr_token).
      IF lv_past_open = abap_false.
        IF lr_token = io_open_token.
          lv_past_open = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.

      CASE zif_skylint_token_navigator~bracket_type( lr_token->* ).
        WHEN zif_skylint_types=>bracket_type-opening.
          lv_counter += 1.
        WHEN zif_skylint_types=>bracket_type-closing.
          IF lv_counter = 1.
            ro_close_token = lr_token.
            RETURN.
          ENDIF.
          lv_counter -= 1.
        WHEN zif_skylint_types=>bracket_type-clopening.
          IF lv_counter = 1.
            ro_close_token = lr_token.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    RAISE EXCEPTION NEW zcx_skylint_error( message = |Matching closing bracket not found| ).
  ENDMETHOD.

  METHOD get_next_keyword_token.
    DATA(lv_after_found) = abap_false.
    LOOP AT it_tokens REFERENCE INTO DATA(lr_token).
      IF lv_after_found = abap_false.
        IF lr_token = io_after.
          lv_after_found = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.
      IF lr_token->references IS INITIAL.
        ro_next = lr_token.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD find_keyword_sequence_token.
    IF it_keywords IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_first_kw) = it_keywords[ 1 ].

    LOOP AT is_statement-tokens REFERENCE INTO DATA(lr_start)
         WHERE references IS INITIAL AND lexeme = lv_first_kw.
      IF lines( it_keywords ) = 1.
        ro_token = lr_start.
        RETURN.
      ENDIF.

      DATA(lv_match)   = abap_true.
      DATA(lv_current) = lr_start.

      LOOP AT it_keywords REFERENCE INTO DATA(lr_kw) FROM 2.
        lv_current = get_next_keyword_token( it_tokens = is_statement-tokens
                                             io_after  = lv_current ).
        IF lv_current IS INITIAL OR lv_current->lexeme <> lr_kw->*.
          lv_match = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_match = abap_true.
        ro_token = lr_start.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
