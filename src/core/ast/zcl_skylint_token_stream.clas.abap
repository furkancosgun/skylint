CLASS zcl_skylint_token_stream DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS find_statements_by_keyword
      IMPORTING iv_keyword        TYPE string
      RETURNING VALUE(rt_results) TYPE zif_skylint_types=>ty_statements.

    METHODS find_statements_with_clause
      IMPORTING iv_clause         TYPE string
      RETURNING VALUE(rt_results) TYPE zif_skylint_types=>ty_statements.

    METHODS statement_has_token
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS statement_has_keyword_sequence
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                it_keywords   TYPE string_table
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS get_statements
      RETURNING VALUE(rt_statements) TYPE zif_skylint_types=>ty_statements.

  PRIVATE SECTION.
    DATA ms_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

ENDCLASS.


CLASS zcl_skylint_token_stream IMPLEMENTATION.
  METHOD constructor.
    ms_procedure = is_procedure.
  ENDMETHOD.

  METHOD find_statements_by_keyword.
    LOOP AT ms_procedure-statements ASSIGNING FIELD-SYMBOL(<ls_st>)
         WHERE keyword = iv_keyword.
      INSERT <ls_st> INTO TABLE rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD find_statements_with_clause.
    DATA lt_parts TYPE string_table.

    SPLIT condense( iv_clause ) AT space INTO TABLE lt_parts.
    IF lt_parts IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_first_part) = lt_parts[ 1 ].
    DATA(lv_part_count) = lines( lt_parts ).

    LOOP AT ms_procedure-statements ASSIGNING FIELD-SYMBOL(<ls_st>).

      DATA(lv_found) = abap_false.

      " TODO: variable is assigned but never used (ABAP cleaner)
      LOOP AT <ls_st>-tokens ASSIGNING FIELD-SYMBOL(<ls_token>)
           WHERE references IS INITIAL AND lexeme = lv_first_part.

        IF lv_part_count = 1.
          lv_found = abap_true.
          EXIT.
        ENDIF.

        DATA(lv_match) = abap_true.
        DATA(lv_tabix) = sy-tabix.
        LOOP AT lt_parts ASSIGNING FIELD-SYMBOL(<lv_part>) FROM 2.
          lv_tabix += 1.
          ASSIGN <ls_st>-tokens[ lv_tabix ] TO FIELD-SYMBOL(<ls_next>).
          IF sy-subrc <> 0 OR <ls_next>-references IS NOT INITIAL OR <ls_next>-lexeme <> <lv_part>.
            lv_match = abap_false.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_match = abap_true.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_true.
        INSERT <ls_st> INTO TABLE rt_results.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_has_token.
    rv_yes = abap_false.
    LOOP AT is_statement-tokens TRANSPORTING NO FIELDS
         WHERE lexeme = iv_lexeme AND references IS INITIAL.
      rv_yes = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_has_keyword_sequence.
    IF it_keywords IS INITIAL.
      rv_yes = abap_false.
      RETURN.
    ENDIF.

    DATA(lv_first_kw) = it_keywords[ 1 ].

    " TODO: variable is assigned but never used (ABAP cleaner)
    LOOP AT is_statement-tokens ASSIGNING FIELD-SYMBOL(<ls_start>)
         WHERE references IS INITIAL AND lexeme = lv_first_kw.
      IF lines( it_keywords ) = 1.
        rv_yes = abap_true.
        RETURN.
      ENDIF.

      DATA(lv_match) = abap_true.
      DATA(lv_tabix) = sy-tabix.
      LOOP AT it_keywords ASSIGNING FIELD-SYMBOL(<lv_kw>) FROM 2.
        lv_tabix += 1.
        ASSIGN is_statement-tokens[ lv_tabix ] TO FIELD-SYMBOL(<ls_next>).
        IF sy-subrc <> 0 OR <ls_next>-references IS NOT INITIAL OR <ls_next>-lexeme <> <lv_kw>.
          lv_match = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_match = abap_true.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_yes = abap_false.
  ENDMETHOD.

  METHOD get_statements.
    rt_statements = CORRESPONDING #( ms_procedure-statements ).
  ENDMETHOD.
ENDCLASS.
