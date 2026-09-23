CLASS zcl_skylint_analyzer DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_analyzer.

    CLASS-METHODS class_constructor.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_negation,
        operator TYPE string,
        negated  TYPE string,
      END OF ty_negation.

    CLASS-DATA gt_negations TYPE TABLE OF ty_negation.

    METHODS flatten_internal
      IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
      RETURNING VALUE(rv_flat) TYPE string.

    METHODS flatten_template
      IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
      RETURNING VALUE(rv_flat) TYPE string.

    METHODS break_internal
      IMPORTING iv_code         TYPE string
                iv_max_length   TYPE i
      RETURNING VALUE(rt_lines) TYPE if_ci_atc_quickfix=>ty_code
      RAISING   cx_static_check.

ENDCLASS.


CLASS zcl_skylint_analyzer IMPLEMENTATION.
  METHOD class_constructor.
    gt_negations = VALUE #( ( operator = 'IN'  negated = 'NOT IN' )
                            ( operator = 'IS'  negated = 'NOT IS' )
                            ( operator = '>'   negated = '<=' )
                            ( operator = 'GT'  negated = 'LE' )
                            ( operator = '<'   negated = '>=' )
                            ( operator = 'LT'  negated = 'GE' )
                            ( operator = '='   negated = '<>' )
                            ( operator = 'EQ'  negated = 'NE' )
                            ( operator = '<>'  negated = '=' )
                            ( operator = 'NE'  negated = 'EQ' )
                            ( operator = '<='  negated = '>' )
                            ( operator = 'LE'  negated = 'GT' )
                            ( operator = '>='  negated = '<' )
                            ( operator = 'GE'  negated = 'LT' ) ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~is_keyword.
    rv_yes = xsdbool( iv_token-references IS INITIAL AND iv_token-lexeme = iv_keyword ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~bracket_type.
    DATA(lv_first) = iv_token-lexeme(1).
    DATA(lv_len) = strlen( iv_token-lexeme ).
    DATA(lv_offset) = lv_len - 1.
    DATA(lv_last) = COND string(
      WHEN lv_offset > 0
      THEN iv_token-lexeme+lv_offset(1)
      ELSE lv_first ).

    rv_type = SWITCH #( lv_last
                        WHEN ')' THEN zif_skylint_analyzer=>bracket_type-closing
                        WHEN '(' THEN SWITCH #( lv_first
                                                WHEN ')'
                                                THEN zif_skylint_analyzer=>bracket_type-clopening
                                                ELSE zif_skylint_analyzer=>bracket_type-opening )
                        ELSE          zif_skylint_analyzer=>bracket_type-none ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~is_comparison_operator.
    DATA(lv_op) = to_upper( iv_token-lexeme ).
    CASE lv_op.
      WHEN 'IS' OR 'IN' OR '>' OR 'GT' OR '<' OR 'LT' OR '>=' OR 'GE' OR '<=' OR 'LE' OR '=' OR 'EQ' OR '<>' OR 'NE'.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD zif_skylint_analyzer~is_logical_connective.
    IF iv_token-references IS NOT INITIAL.
      rv_type = zif_skylint_analyzer=>connective-none.
      RETURN.
    ENDIF.
    rv_type = SWITCH #( iv_token-lexeme
                        WHEN 'AND'   THEN zif_skylint_analyzer=>connective-and
                        WHEN 'OR'    THEN zif_skylint_analyzer=>connective-or
                        WHEN 'EQUIV' THEN zif_skylint_analyzer=>connective-equiv
                        WHEN 'NOT'   THEN zif_skylint_analyzer=>connective-not
                        ELSE              zif_skylint_analyzer=>connective-none ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~find_token.
    rv_index = 0.
    LOOP AT it_tokens TRANSPORTING NO FIELDS FROM iv_start
         WHERE lexeme = iv_lexeme AND references IS INITIAL.
      rv_index = sy-tabix.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_skylint_analyzer~find_clause.
    rv_index = 0.
    SPLIT condense( iv_clause ) AT space INTO TABLE DATA(lt_parts).
    IF lt_parts IS INITIAL OR lt_parts[ 1 ] IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_tokens TRANSPORTING NO FIELDS FROM iv_start
         WHERE lexeme = lt_parts[ 1 ] AND references IS INITIAL.
      rv_index = sy-tabix.
      DATA(lv_part_idx) = 2.
      WHILE     lv_part_idx                <= lines( lt_parts )
            AND rv_index + lv_part_idx - 1 <= lines( it_tokens ).
        ASSIGN it_tokens[ rv_index + lv_part_idx - 1 ] TO FIELD-SYMBOL(<ls_t>).
        IF <ls_t>-lexeme = lt_parts[ lv_part_idx ] AND <ls_t>-references IS INITIAL.
          lv_part_idx += 1.
        ELSE.
          rv_index = 0.
          EXIT.
        ENDIF.
      ENDWHILE.
      IF rv_index <> 0.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_skylint_analyzer~has_clause.
    rv_yes = xsdbool( zif_skylint_analyzer~find_clause( it_tokens = it_tokens
                                                        iv_clause = iv_clause ) <> 0 ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~find_keyword_sequence.
    rv_pos = -1.
    IF it_keywords IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens TRANSPORTING NO FIELDS
         WHERE lexeme = it_keywords[ 1 ] AND references IS INITIAL.
      DATA(lv_start) = sy-tabix.
      IF lines( it_keywords ) = 1.
        rv_pos = lv_start.
        RETURN.
      ENDIF.

      DATA(lv_match) = abap_true.
      LOOP AT it_keywords ASSIGNING FIELD-SYMBOL(<lv_kw>) FROM 2.
        DATA(lv_idx) = lv_start + sy-tabix - 1.
        IF lv_idx > lines( is_statement-tokens ).
          lv_match = abap_false.
          EXIT.
        ENDIF.
        DATA(ls_next) = VALUE #( is_statement-tokens[ lv_idx ] OPTIONAL ).
        IF ls_next-references IS NOT INITIAL OR ls_next-lexeme <> <lv_kw>.
          lv_match = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_match = abap_true.
        rv_pos = lv_start.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_skylint_analyzer~find_closing_bracket.
    DATA(lv_type) = zif_skylint_analyzer~bracket_type( is_statement-tokens[ iv_open_pos ] ).
    IF     lv_type <> zif_skylint_analyzer=>bracket_type-opening
       AND lv_type <> zif_skylint_analyzer=>bracket_type-closing.
      RAISE EXCEPTION NEW zcx_skylint_error( iv_text = |Not a bracket| ).
    ENDIF.

    DATA(lv_counter) = 1.
    LOOP AT is_statement-tokens ASSIGNING FIELD-SYMBOL(<ls_token>) FROM iv_open_pos + 1.
      DATA(lv_idx) = sy-tabix.
      CASE zif_skylint_analyzer~bracket_type( <ls_token> ).
        WHEN zif_skylint_analyzer=>bracket_type-opening.
          lv_counter += 1.
        WHEN zif_skylint_analyzer=>bracket_type-closing.
          IF lv_counter = 1.
            rv_end = lv_idx.
            RETURN.
          ENDIF.
          lv_counter -= 1.
        WHEN zif_skylint_analyzer=>bracket_type-clopening.
          IF lv_counter = 1.
            rv_end = lv_idx.
            RETURN.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    rv_end = -1.
  ENDMETHOD.

  METHOD zif_skylint_analyzer~flatten.
    rv_code = flatten_internal( it_tokens ).
  ENDMETHOD.

  METHOD flatten_internal.
    rv_flat = REDUCE string( INIT lv = `` FOR ls_tok IN it_tokens NEXT lv = |{ lv }{ ls_tok-lexeme } | ).
    DATA(lv_len) = strlen( rv_flat ) - 1.
    IF lv_len >= 0 AND rv_flat+lv_len(1) = ` `.
      rv_flat = rv_flat(lv_len).
    ENDIF.
  ENDMETHOD.

  METHOD flatten_template.
    rv_flat = flatten_internal( it_tokens ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~break_lines.
    rt_lines = break_internal( iv_code       = iv_code
                               iv_max_length = iv_max_length ).
  ENDMETHOD.

  METHOD break_internal.
    IF strlen( iv_code ) <= iv_max_length.
      rt_lines = VALUE #( ( iv_code ) ).
      RETURN.
    ENDIF.

    DATA(lv_code) = iv_code.
    DATA(lv_i) = 0.
    DATA(lv_in_sq) = abap_false.
    DATA(lv_in_quotes) = abap_false.
    DATA(lv_in_tpl) = abap_false.
    DATA(lv_in_braces) = abap_false.
    DATA(lv_last_space) = 0.

    WHILE lv_i < strlen( lv_code ).
      CASE lv_code+lv_i(1).
        WHEN '`'.
          IF lv_in_quotes = abap_false AND lv_in_tpl = abap_false.
            lv_in_sq = xsdbool( lv_in_sq = abap_false ).
          ENDIF.
        WHEN `'`.
          IF lv_in_sq = abap_false AND lv_in_tpl = abap_false.
            lv_in_quotes = xsdbool( lv_in_quotes = abap_false ).
          ENDIF.
        WHEN '|'.
          IF lv_in_sq = abap_false AND lv_in_quotes = abap_false.
            lv_in_tpl = xsdbool( lv_in_tpl = abap_false ).
          ENDIF.
        WHEN `\`.
          lv_i += 1.
        WHEN '{'.
          IF lv_in_tpl = abap_true AND lv_in_sq = abap_false AND lv_in_quotes = abap_false.
            lv_in_braces = abap_true.
          ENDIF.
        WHEN '}'.
          IF lv_in_tpl = abap_true AND lv_in_sq = abap_false AND lv_in_quotes = abap_false.
            lv_in_braces = abap_false.
          ENDIF.
        WHEN ` `.
          IF     lv_in_sq = abap_false AND lv_in_quotes = abap_false
             AND ( lv_in_tpl = abap_false OR lv_in_braces = abap_true ).
            lv_last_space = lv_i.
          ENDIF.
      ENDCASE.

      lv_i += 1.

      IF lv_i > iv_max_length.
        IF lv_last_space = 0.
          RAISE EXCEPTION NEW zcx_skylint_error( iv_text = |Line break impossible| ).
        ENDIF.
        INSERT lv_code(lv_last_space) INTO TABLE rt_lines.
        lv_last_space += 1.
        IF lv_last_space >= strlen( lv_code ).
          RETURN.
        ENDIF.
        lv_code = lv_code+lv_last_space.
        IF strlen( lv_code ) <= iv_max_length.
          INSERT lv_code INTO TABLE rt_lines.
          RETURN.
        ENDIF.
        lv_i = 0.
        lv_last_space = 0.
        lv_in_sq = abap_false.
        lv_in_quotes = abap_false.
        lv_in_tpl = abap_false.
      ENDIF.
    ENDWHILE.

    IF lv_i > iv_max_length.
      RAISE EXCEPTION NEW zcx_skylint_error( iv_text = |Line break impossible| ).
    ELSE.
      INSERT lv_code INTO TABLE rt_lines.
    ENDIF.
  ENDMETHOD.

  METHOD zif_skylint_analyzer~format.
    DATA(lv_flat) = |{ zif_skylint_analyzer~flatten( it_tokens ) }.|.
    rt_code = zif_skylint_analyzer~break_lines( lv_flat ).
  ENDMETHOD.

  METHOD zif_skylint_analyzer~negate_operator.
    DATA(ls_dummy) = VALUE if_ci_atc_source_code_provider=>ty_token( lexeme = iv_operator ).
    IF zif_skylint_analyzer~is_comparison_operator( ls_dummy ) = abap_false.
      RAISE EXCEPTION NEW zcx_skylint_error( iv_text = |Not an operator| ).
    ENDIF.
    rv_negated = gt_negations[ operator = iv_operator ]-negated.
  ENDMETHOD.
ENDCLASS.
