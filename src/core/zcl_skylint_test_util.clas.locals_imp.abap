CLASS lcl_lexer DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_token,
        lexeme     TYPE string,
        line       TYPE i,
        column     TYPE i,
        is_comment TYPE abap_bool,
        is_pragma  TYPE abap_bool,
      END OF ty_token,
      ty_tokens TYPE STANDARD TABLE OF ty_token WITH EMPTY KEY.

    METHODS constructor
      IMPORTING iv_source TYPE string.

    METHODS run
      RETURNING VALUE(rt_tokens) TYPE ty_tokens.

  PRIVATE SECTION.
    DATA mv_src    TYPE string.
    DATA mv_len    TYPE i.
    DATA mv_pos    TYPE i.
    DATA mv_line   TYPE i.
    DATA mv_col    TYPE i.
    DATA mv_tline  TYPE i.
    DATA mv_tcol   TYPE i.
    DATA mv_nl     TYPE string.
    DATA mt_tokens TYPE ty_tokens.

    METHODS at_end
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS peek
      IMPORTING iv_offset    TYPE i DEFAULT 0
      RETURNING VALUE(rv_ch) TYPE string.

    METHODS advance
      RETURNING VALUE(rv_ch) TYPE string.

    METHODS is_blank
      IMPORTING iv_ch         TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_field_symbol_ahead
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS skip_blanks.

    METHODS ends_line
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS emit_text
      IMPORTING iv_text TYPE string.

    METHODS emit_comment
      IMPORTING iv_text TYPE string.

    METHODS emit_pragma
      IMPORTING iv_text TYPE string.

    METHODS scan_comment.

    METHODS scan_pragma.

    METHODS scan_string
      IMPORTING iv_quote TYPE string.

    METHODS scan_template.

    METHODS scan_field_symbol.

    METHODS scan_word.
ENDCLASS.


CLASS lcl_parser DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS build_statements
      IMPORTING it_tokens             TYPE lcl_lexer=>ty_tokens
      RETURNING VALUE(rt_statements)  TYPE if_ci_atc_source_code_provider=>ty_statements.

    CLASS-METHODS has_method
      IMPORTING it_statements    TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rv_yes)    TYPE abap_bool.

    CLASS-METHODS slice_procedure
      IMPORTING it_statements          TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_class_definition    TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rs_procedure)    TYPE if_ci_atc_source_code_provider=>ty_procedure.

  PRIVATE SECTION.
    CLASS-METHODS emit_statement
      IMPORTING it_prefix     TYPE lcl_lexer=>ty_tokens
                it_body       TYPE lcl_lexer=>ty_tokens
                it_pseudo     TYPE string_table
                iv_in_chain   TYPE abap_bool
                iv_header_kw  TYPE string
      CHANGING  ct_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    CLASS-METHODS collect_pseudo
      IMPORTING is_token      TYPE lcl_lexer=>ty_token
      CHANGING  ct_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                ct_pending    TYPE string_table.

    CLASS-METHODS pseudo_words
      IMPORTING iv_text          TYPE string
      RETURNING VALUE(rt_words)  TYPE string_table.

    CLASS-METHODS paren_delta
      IMPORTING iv_lexeme       TYPE string
      RETURNING VALUE(rv_delta) TYPE i.

    CLASS-METHODS determine_keyword
      IMPORTING it_tokens        TYPE lcl_lexer=>ty_tokens
                iv_in_chain      TYPE abap_bool
                iv_header_kw     TYPE string
      RETURNING VALUE(rv_keyword) TYPE string.

    CLASS-METHODS is_assignment
      IMPORTING it_tokens     TYPE lcl_lexer=>ty_tokens
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_method_call
      IMPORTING it_tokens     TYPE lcl_lexer=>ty_tokens
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS add_refs
      CHANGING cs_statement TYPE if_ci_atc_source_code_provider=>ty_statement.
ENDCLASS.


CLASS lcl_test_code_provider DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES if_ci_atc_source_code_provider.

    METHODS set_procedure
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

  PRIVATE SECTION.
    DATA ms_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.
    DATA mv_has_proc  TYPE abap_bool.
ENDCLASS.


CLASS lcl_runner DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS join_source
      IMPORTING iv_source        TYPE string OPTIONAL
                it_source        TYPE string_table OPTIONAL
      RETURNING VALUE(rv_source) TYPE string.

    CLASS-METHODS execute
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rt_findings)  TYPE if_ci_atc_check=>ty_findings
      RAISING cx_static_check.

  PRIVATE SECTION.
    CLASS-METHODS wrap_if_needed
      IMPORTING iv_source        TYPE string
      RETURNING VALUE(rv_source) TYPE string.
ENDCLASS.


CLASS lcl_lexer IMPLEMENTATION.
  METHOD constructor.
    DATA lv_nl TYPE string.

    mv_src = iv_source.
    lv_nl = cl_abap_char_utilities=>newline.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN mv_src WITH lv_nl.
    mv_len = strlen( mv_src ).
    mv_pos = 0.
    mv_line = 1.
    mv_col = 1.
    mv_nl = lv_nl.
  ENDMETHOD.

  METHOD at_end.
    rv_yes = xsdbool( mv_pos >= mv_len ).
  ENDMETHOD.

  METHOD peek.
    DATA lv_at TYPE i.

    CLEAR rv_ch.
    IF iv_offset < 0.
      RETURN.
    ENDIF.
    lv_at = mv_pos + iv_offset.
    IF lv_at >= mv_len.
      RETURN.
    ENDIF.
    rv_ch = mv_src+lv_at(1).
  ENDMETHOD.

  METHOD advance.
    DATA lv_ch TYPE string.

    IF mv_pos >= mv_len.
      rv_ch = ''.
      RETURN.
    ENDIF.
    lv_ch = mv_src+mv_pos(1).
    mv_pos = mv_pos + 1.
    IF lv_ch = mv_nl.
      mv_line = mv_line + 1.
      mv_col = 1.
    ELSE.
      mv_col = mv_col + 1.
    ENDIF.
    rv_ch = lv_ch.
  ENDMETHOD.

  METHOD is_blank.
    IF iv_ch = ` ` OR iv_ch = cl_abap_char_utilities=>horizontal_tab OR iv_ch = mv_nl.
      rv_yes = abap_true.
    ELSE.
      rv_yes = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_field_symbol_ahead.
    DATA lv_idx   TYPE i.
    DATA lv_ch    TYPE string.
    DATA lv_next  TYPE string.
    DATA lv_first TYPE string.
    DATA lv_rest  TYPE string.

    rv_yes = abap_false.
    lv_first = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_'.
    lv_rest = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789/%-'.
    IF peek( ) <> '<'.
      RETURN.
    ENDIF.
    lv_next = peek( 1 ).
    IF xsdbool( lv_next CA lv_first ) = abap_false.
      RETURN.
    ENDIF.
    lv_idx = 2.
    WHILE mv_pos + lv_idx < mv_len.
      lv_ch = peek( lv_idx ).
      IF lv_ch = '>'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
      IF xsdbool( lv_ch CA lv_rest ) = abap_false.
        RETURN.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD skip_blanks.
    WHILE at_end( ) = abap_false.
      IF is_blank( peek( ) ) = abap_true.
        advance( ).
      ELSE.
        RETURN.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD ends_line.
    IF at_end( ) = abap_true.
      rv_yes = abap_true.
    ELSEIF peek( ) = mv_nl.
      rv_yes = abap_true.
    ELSE.
      rv_yes = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD emit_text.
    DATA ls_token TYPE ty_token.

    ls_token-lexeme = iv_text.
    ls_token-line = mv_tline.
    ls_token-column = mv_tcol.
    APPEND ls_token TO mt_tokens.
  ENDMETHOD.

  METHOD emit_comment.
    DATA ls_token TYPE ty_token.

    ls_token-lexeme = iv_text.
    ls_token-line = mv_tline.
    ls_token-column = mv_tcol.
    ls_token-is_comment = abap_true.
    APPEND ls_token TO mt_tokens.
  ENDMETHOD.

  METHOD emit_pragma.
    DATA ls_token TYPE ty_token.

    ls_token-lexeme = iv_text.
    ls_token-line = mv_tline.
    ls_token-column = mv_tcol.
    ls_token-is_pragma = abap_true.
    APPEND ls_token TO mt_tokens.
  ENDMETHOD.

  METHOD run.
    DATA lv_ch   TYPE string.
    DATA lv_next TYPE string.

    CLEAR mt_tokens.
    WHILE at_end( ) = abap_false.
      skip_blanks( ).
      IF at_end( ) = abap_true.
        EXIT.
      ENDIF.
      mv_tline = mv_line.
      mv_tcol = mv_col.
      lv_ch = peek( ).
      lv_next = peek( 1 ).
      CASE lv_ch.
        WHEN '"'.
          scan_comment( ).
        WHEN '*'.
          IF mv_col = 1.
            scan_comment( ).
          ELSE.
            scan_word( ).
          ENDIF.
        WHEN '#'.
          IF lv_next = '#'.
            scan_pragma( ).
          ELSE.
            scan_word( ).
          ENDIF.
        WHEN ''''.
          scan_string( '''' ).
        WHEN '`'.
          scan_string( '`' ).
        WHEN '|'.
          scan_template( ).
        WHEN '<'.
          IF is_field_symbol_ahead( ) = abap_true.
            scan_field_symbol( ).
          ELSE.
            scan_word( ).
          ENDIF.
        WHEN OTHERS.
          scan_word( ).
      ENDCASE.
    ENDWHILE.
    rt_tokens = mt_tokens.
  ENDMETHOD.

  METHOD scan_comment.
    DATA lv_text TYPE string.

    lv_text = ''.
    WHILE ends_line( ) = abap_false.
      lv_text = lv_text && advance( ).
    ENDWHILE.
    emit_comment( lv_text ).
  ENDMETHOD.

  METHOD scan_pragma.
    DATA lv_text TYPE string.
    DATA lv_ch   TYPE string.

    lv_text = advance( ) && advance( ).
    WHILE at_end( ) = abap_false.
      lv_ch = peek( ).
      IF xsdbool( lv_ch CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/%' ) = abap_false.
        EXIT.
      ENDIF.
      lv_text = lv_text && advance( ).
    ENDWHILE.
    emit_pragma( lv_text ).
  ENDMETHOD.

  METHOD scan_string.
    DATA lv_text TYPE string.
    DATA lv_ch   TYPE string.

    lv_text = advance( ).
    WHILE ends_line( ) = abap_false.
      lv_ch = peek( ).
      IF lv_ch = iv_quote.
        lv_text = lv_text && advance( ).
        IF peek( ) = iv_quote.
          lv_text = lv_text && advance( ).
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
        lv_text = lv_text && advance( ).
      ENDIF.
    ENDWHILE.
    emit_text( lv_text ).
  ENDMETHOD.

  METHOD scan_template.
    DATA lv_text  TYPE string.
    DATA lv_ch    TYPE string.
    DATA lv_depth TYPE i.

    lv_text = advance( ).
    lv_depth = 0.
    WHILE ends_line( ) = abap_false.
      lv_ch = peek( ).
      IF lv_ch = '\'.
        lv_text = lv_text && advance( ).
        IF at_end( ) = abap_false.
          lv_text = lv_text && advance( ).
        ENDIF.
      ELSEIF lv_ch = '{'.
        lv_depth = lv_depth + 1.
        lv_text = lv_text && advance( ).
      ELSEIF lv_ch = '}' AND lv_depth > 0.
        lv_depth = lv_depth - 1.
        lv_text = lv_text && advance( ).
      ELSEIF lv_ch = '|' AND lv_depth = 0.
        lv_text = lv_text && advance( ).
        EXIT.
      ELSE.
        lv_text = lv_text && advance( ).
      ENDIF.
    ENDWHILE.
    emit_text( lv_text ).
  ENDMETHOD.

  METHOD scan_field_symbol.
    DATA lv_text TYPE string.
    DATA lv_ch   TYPE string.

    lv_text = advance( ).
    WHILE at_end( ) = abap_false.
      lv_ch = peek( ).
      IF lv_ch = '>'.
        lv_text = lv_text && advance( ).
        EXIT.
      ENDIF.
      IF xsdbool( lv_ch CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/%-' ) = abap_false.
        EXIT.
      ENDIF.
      lv_text = lv_text && advance( ).
    ENDWHILE.
    emit_text( lv_text ).
  ENDMETHOD.

  METHOD scan_word.
    DATA lv_text TYPE string.
    DATA lv_ch   TYPE string.
    DATA lv_done TYPE abap_bool.

    lv_text = ''.
    lv_done = abap_false.
    WHILE lv_done = abap_false AND at_end( ) = abap_false.
      lv_ch = peek( ).
      IF is_blank( lv_ch ) = abap_true.
        lv_done = abap_true.
      ELSE.
        CASE lv_ch.
          WHEN '.' OR ',' OR ':' OR ')' OR ']' OR '}' OR '[' OR '{'.
            IF lv_text IS INITIAL.
              lv_text = advance( ).
            ENDIF.
            lv_done = abap_true.
          WHEN '('.
            lv_text = lv_text && advance( ).
            lv_done = abap_true.
          WHEN OTHERS.
            lv_text = lv_text && advance( ).
        ENDCASE.
      ENDIF.
    ENDWHILE.
    IF lv_text IS NOT INITIAL.
      emit_text( lv_text ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_parser IMPLEMENTATION.
  METHOD build_statements.
    DATA lt_cur     TYPE lcl_lexer=>ty_tokens.
    DATA lt_prefix  TYPE lcl_lexer=>ty_tokens.
    DATA lt_pending TYPE string_table.
    DATA lv_in_chain TYPE abap_bool.
    DATA lv_header_kw TYPE string.
    DATA lv_depth   TYPE i.
    DATA ls_tok     TYPE lcl_lexer=>ty_token.

    CLEAR rt_statements.
    LOOP AT it_tokens INTO ls_tok.
      IF ls_tok-is_comment = abap_true OR ls_tok-is_pragma = abap_true.
        collect_pseudo( EXPORTING is_token      = ls_tok
                        CHANGING  ct_statements = rt_statements
                                  ct_pending    = lt_pending ).
      ELSEIF ls_tok-lexeme = ':' AND lv_depth = 0.
        IF lv_in_chain = abap_false.
          lv_in_chain = abap_true.
          lt_prefix = lt_cur.
          IF lines( lt_prefix ) > 0.
            lv_header_kw = to_upper( lt_prefix[ 1 ]-lexeme ).
          ENDIF.
        ENDIF.
        CLEAR lt_cur.
      ELSEIF ls_tok-lexeme = ',' AND lv_depth = 0 AND lv_in_chain = abap_true.
        emit_statement( EXPORTING it_prefix     = lt_prefix
                                  it_body       = lt_cur
                                  it_pseudo     = lt_pending
                                  iv_in_chain   = abap_true
                                  iv_header_kw  = lv_header_kw
                        CHANGING  ct_statements = rt_statements ).
        CLEAR lt_cur.
        CLEAR lt_pending.
        lv_depth = 0.
      ELSEIF ls_tok-lexeme = '.' AND lv_depth = 0.
        emit_statement( EXPORTING it_prefix     = lt_prefix
                                  it_body       = lt_cur
                                  it_pseudo     = lt_pending
                                  iv_in_chain   = lv_in_chain
                                  iv_header_kw  = lv_header_kw
                        CHANGING  ct_statements = rt_statements ).
        CLEAR lt_cur.
        CLEAR lt_prefix.
        CLEAR lt_pending.
        CLEAR lv_header_kw.
        lv_in_chain = abap_false.
        lv_depth = 0.
      ELSE.
        APPEND ls_tok TO lt_cur.
        lv_depth = lv_depth + paren_delta( ls_tok-lexeme ).
        IF lv_depth < 0.
          lv_depth = 0.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD emit_statement.
    DATA lt_all      TYPE lcl_lexer=>ty_tokens.
    DATA ls_lex      TYPE lcl_lexer=>ty_token.
    DATA ls_atc      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_stmt     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_word     TYPE string.
    DATA lv_col      TYPE i.
    FIELD-SYMBOLS <ls_t> TYPE if_ci_atc_source_code_provider=>ty_token.

    IF iv_in_chain = abap_true.
      APPEND LINES OF it_prefix TO lt_all.
    ENDIF.
    APPEND LINES OF it_body TO lt_all.
    IF lines( lt_all ) = 0.
      RETURN.
    ENDIF.

    CLEAR ls_stmt.
    LOOP AT lt_all INTO ls_lex.
      CLEAR ls_atc.
      ls_atc-lexeme = ls_lex-lexeme.
      ls_atc-position-line = ls_lex-line.
      lv_col = ls_lex-column.
      IF lv_col > 255.
        lv_col = 255.
      ENDIF.
      ls_atc-position-column = lv_col.
      APPEND ls_atc TO ls_stmt-tokens.
    ENDLOOP.

    READ TABLE ls_stmt-tokens ASSIGNING <ls_t> INDEX 1.
    IF sy-subrc = 0.
      ls_stmt-position = <ls_t>-position.
    ENDIF.

    LOOP AT it_pseudo INTO lv_word.
      IF line_exists( ls_stmt-pseudo_comments[ table_line = lv_word ] ) = abap_false.
        INSERT lv_word INTO TABLE ls_stmt-pseudo_comments.
      ENDIF.
    ENDLOOP.

    ls_stmt-keyword = determine_keyword( it_tokens    = lt_all
                                        iv_in_chain  = iv_in_chain
                                        iv_header_kw = iv_header_kw ).
    ls_stmt-is_in_scope = abap_true.
    add_refs( CHANGING cs_statement = ls_stmt ).
    APPEND ls_stmt TO ct_statements.
  ENDMETHOD.

  METHOD collect_pseudo.
    DATA lt_words TYPE string_table.
    DATA lv_word  TYPE string.
    DATA lv_idx   TYPE i.
    FIELD-SYMBOLS <ls_last> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_token-is_pragma = abap_true AND strlen( is_token-lexeme ) > 2.
      lv_word = is_token-lexeme+2.
      APPEND lv_word TO lt_words.
    ELSE.
      lt_words = pseudo_words( is_token-lexeme ).
    ENDIF.
    IF lines( lt_words ) = 0.
      RETURN.
    ENDIF.

    lv_idx = lines( ct_statements ).
    IF lv_idx > 0.
      READ TABLE ct_statements ASSIGNING <ls_last> INDEX lv_idx.
      IF sy-subrc = 0 AND <ls_last>-position-line = is_token-line.
        LOOP AT lt_words INTO lv_word.
          IF line_exists( <ls_last>-pseudo_comments[ table_line = lv_word ] ) = abap_false.
            INSERT lv_word INTO TABLE <ls_last>-pseudo_comments.
          ENDIF.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT lt_words INTO lv_word.
      APPEND lv_word TO ct_pending.
    ENDLOOP.
  ENDMETHOD.

  METHOD pseudo_words.
    DATA lv_upper TYPE string.
    DATA lv_off   TYPE i.
    DATA lv_rest  TYPE string.
    DATA lv_part  TYPE string.
    DATA lt_clean TYPE string_table.

    CLEAR rt_words.
    lv_upper = to_upper( iv_text ).
    FIND FIRST OCCURRENCE OF '#EC' IN lv_upper MATCH OFFSET lv_off.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lv_off = lv_off + 3.
    IF lv_off >= strlen( iv_text ).
      RETURN.
    ENDIF.
    lv_rest = iv_text+lv_off.
    REPLACE ALL OCCURRENCES OF ',' IN lv_rest WITH ` `.
    SPLIT lv_rest AT ` ` INTO TABLE rt_words.
    lt_clean = rt_words.
    CLEAR rt_words.
    LOOP AT lt_clean INTO lv_part.
      CONDENSE lv_part.
      IF lv_part IS NOT INITIAL.
        APPEND lv_part TO rt_words.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD paren_delta.
    DATA lv_first TYPE string.
    DATA lv_off   TYPE i.
    DATA lv_ch    TYPE string.

    rv_delta = 0.
    IF iv_lexeme IS INITIAL.
      RETURN.
    ENDIF.
    lv_first = iv_lexeme(1).
    IF lv_first = '''' OR lv_first = '`' OR lv_first = '|'.
      RETURN.
    ENDIF.
    lv_off = 0.
    WHILE lv_off < strlen( iv_lexeme ).
      lv_ch = iv_lexeme+lv_off(1).
      CASE lv_ch.
        WHEN '(' OR '[' OR '{'.
          rv_delta = rv_delta + 1.
        WHEN ')' OR ']' OR '}'.
          rv_delta = rv_delta - 1.
      ENDCASE.
      lv_off = lv_off + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD determine_keyword.
    DATA ls_first TYPE lcl_lexer=>ty_token.
    DATA lv_first TYPE string.

    IF iv_in_chain = abap_true AND iv_header_kw IS NOT INITIAL.
      rv_keyword = iv_header_kw.
      RETURN.
    ENDIF.
    IF lines( it_tokens ) = 0.
      rv_keyword = ''.
      RETURN.
    ENDIF.
    READ TABLE it_tokens INTO ls_first INDEX 1.
    IF sy-subrc <> 0.
      rv_keyword = ''.
      RETURN.
    ENDIF.
    lv_first = to_upper( ls_first-lexeme ).
    IF is_assignment( it_tokens ) = abap_true.
      rv_keyword = 'COMPUTE'.
    ELSEIF is_method_call( it_tokens ) = abap_true.
      rv_keyword = '+CALL_METHOD'.
    ELSE.
      rv_keyword = lv_first.
    ENDIF.
  ENDMETHOD.

  METHOD is_assignment.
    DATA ls_tok   TYPE lcl_lexer=>ty_token.
    DATA lv_first TYPE string.
    DATA lv_depth TYPE i.

    rv_yes = abap_false.
    IF lines( it_tokens ) = 0.
      RETURN.
    ENDIF.
    READ TABLE it_tokens INTO ls_tok INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lv_first = to_upper( ls_tok-lexeme ).
    CASE lv_first.
      WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE' OR 'WAIT' OR 'WHEN' OR 'WHERE'.
        RETURN.
      WHEN 'UNTIL' OR 'LOOP' OR 'SELECT' OR 'UPDATE' OR 'DELETE' OR 'MODIFY'.
        RETURN.
      WHEN 'READ' OR 'ASSERT' OR 'AUTHORITY-CHECK' OR 'RAISE' OR 'CALL' OR 'PERFORM'.
        RETURN.
      WHEN 'SUBMIT' OR 'SET' OR 'GET' OR 'ASSIGN' OR 'DESCRIBE' OR 'MESSAGE'.
        RETURN.
      WHEN 'CONSTANTS' OR 'DATA' OR 'TYPES' OR 'STATICS' OR 'CLASS-DATA'.
        RETURN.
      WHEN 'FIELD-SYMBOLS' OR 'FIELD-SYMBOL'.
        RETURN.
    ENDCASE.

    LOOP AT it_tokens INTO ls_tok.
      IF ls_tok-lexeme = '=' AND lv_depth = 0.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
      lv_depth = lv_depth + paren_delta( ls_tok-lexeme ).
      IF lv_depth < 0.
        lv_depth = 0.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_method_call.
    DATA ls_first  TYPE lcl_lexer=>ty_token.
    DATA lv_first  TYPE string.
    DATA ls_tok    TYPE lcl_lexer=>ty_token.
    DATA lv_has_op TYPE abap_bool.
    DATA lv_has_br TYPE abap_bool.

    rv_yes = abap_false.
    IF lines( it_tokens ) = 0.
      RETURN.
    ENDIF.
    READ TABLE it_tokens INTO ls_first INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lv_first = to_upper( ls_first-lexeme ).
    CASE lv_first.
      WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE' OR 'LOOP' OR 'SELECT'.
        RETURN.
      WHEN 'WHEN' OR 'WHERE' OR 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'CALL'.
        RETURN.
      WHEN 'VALUE' OR 'NEW' OR 'COND' OR 'SWITCH' OR 'LINES' OR 'REF'.
        RETURN.
      WHEN 'CONV' OR 'CAST' OR 'EXACT' OR 'CORRESPONDING'.
        RETURN.
    ENDCASE.

    IF lv_first CP '*('.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    LOOP AT it_tokens INTO ls_tok.
      lv_first = to_upper( ls_tok-lexeme ).
      IF lv_first CS '->' OR lv_first CS '=>'.
        lv_has_op = abap_true.
      ENDIF.
      IF lv_first CS '('.
        lv_has_br = abap_true.
      ENDIF.
    ENDLOOP.
    IF lv_has_op = abap_true AND lv_has_br = abap_true.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD add_refs.
    DATA lv_up   TYPE string.
    DATA lv_cls  TYPE string.
    DATA lv_meth TYPE string.
    DATA lv_len  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_name TYPE string.
    DATA ls_ref  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT cs_statement-tokens ASSIGNING <ls_tok>.
      lv_up = to_upper( <ls_tok>-lexeme ).
      IF lv_up CS '=>'.
        SPLIT lv_up AT '=>' INTO lv_cls lv_meth.
        IF lv_meth CP '*('.
          lv_len = strlen( lv_meth ) - 1.
          lv_meth = lv_meth(lv_len).
        ENDIF.
        CLEAR ls_ref.
        ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
        ls_ref-full_name = |\\TY:{ lv_cls }|.
        ls_ref-usage_grade = if_ci_atc_source_code_provider=>usage_grades-direct.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
        CLEAR ls_ref.
        ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
        ls_ref-full_name = |\\TY:{ lv_cls }\\ME:{ lv_meth }|.
        ls_ref-usage_grade = if_ci_atc_source_code_provider=>usage_grades-direct.
        ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
      ELSEIF lv_up CS '->'.
        SPLIT lv_up AT '->' INTO lv_cls lv_meth.
        IF lv_meth CP '*('.
          lv_len = strlen( lv_meth ) - 1.
          lv_meth = lv_meth(lv_len).
        ENDIF.
        CLEAR ls_ref.
        ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
        IF lv_cls = 'ME'.
          ls_ref-full_name = |\\TY:ZSKYLINT_TEST\\ME:{ lv_meth }|.
        ELSE.
          ls_ref-full_name = |{ lv_cls }->{ lv_meth }|.
        ENDIF.
        ls_ref-usage_grade = if_ci_atc_source_code_provider=>usage_grades-direct.
        ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
      ENDIF.

      lv_name = ''.
      IF lv_up CP 'DATA(*)' OR lv_up CP '@DATA(*)' OR lv_up CP 'FINAL(*)'.
        FIND FIRST OCCURRENCE OF '(' IN lv_up MATCH OFFSET lv_off.
        IF sy-subrc = 0.
          lv_off = lv_off + 1.
          lv_len = strlen( lv_up ) - lv_off - 1.
          IF lv_len > 0.
            lv_name = lv_up+lv_off(lv_len).
          ENDIF.
        ENDIF.
      ELSEIF lv_up CP 'FIELD-SYMBOL(*)' OR lv_up CP 'FIELD-SYMBOLS(*)'.
        FIND FIRST OCCURRENCE OF '(' IN lv_up MATCH OFFSET lv_off.
        IF sy-subrc = 0.
          lv_off = lv_off + 1.
          lv_len = strlen( lv_up ) - lv_off - 1.
          IF lv_len > 0.
            lv_name = lv_up+lv_off(lv_len).
          ENDIF.
        ENDIF.
      ENDIF.
      IF lv_name IS NOT INITIAL.
        CLEAR ls_ref.
        ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
        ls_ref-full_name = |\\TY:ZSKYLINT_TEST\\ME:TEST\\DA:{ lv_name }|.
        ls_ref-usage_grade = if_ci_atc_source_code_provider=>usage_grades-definition.
        ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_method.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_yes = abap_false.
    LOOP AT it_statements ASSIGNING <ls_stmt> WHERE keyword = 'METHOD'.
      rv_yes = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD slice_procedure.
    DATA lv_started TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rs_procedure.
    rs_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
    rs_procedure-id-main_unit-name = zcl_skylint_test_util=>c_test_class.
    IF iv_class_definition = abap_true.
      rs_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      rs_procedure-id-name = '0'.
      APPEND LINES OF it_statements TO rs_procedure-statements.
      RETURN.
    ENDIF.
    rs_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-method.
    rs_procedure-id-name = |ZSKYLINT_TEST=>TEST|.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF lv_started = abap_false AND <ls_stmt>-keyword = 'METHOD'.
        lv_started = abap_true.
      ENDIF.
      IF lv_started = abap_true.
        APPEND <ls_stmt> TO rs_procedure-statements.
      ENDIF.
      IF lv_started = abap_true AND <ls_stmt>-keyword = 'ENDMETHOD'.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_test_code_provider IMPLEMENTATION.
  METHOD set_procedure.
    ms_procedure = is_procedure.
    mv_has_proc = abap_true.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_procedures.
    DATA lt_procs TYPE if_ci_atc_source_code_provider=>ty_procedures.

    CREATE DATA procedures.
    IF mv_has_proc = abap_true.
      INSERT ms_procedure INTO TABLE lt_procs.
      procedures->* = lt_procs.
    ENDIF.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~object_to_comp_unit.
    compilation_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-class.
    compilation_unit-name = zcl_skylint_test_util=>c_test_class.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_statement_location.
    location-object-type = 'CLAS'.
    location-object-name = zcl_skylint_test_util=>c_test_class.
    location-position = statement-position.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_statement_checksum.
    checksum = 0.
  ENDMETHOD.

  METHOD if_ci_atc_source_code_provider~get_called_procedure.
    CLEAR procedure.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_runner IMPLEMENTATION.
  METHOD join_source.
    DATA lv_line TYPE string.

    CLEAR rv_source.
    IF iv_source IS NOT INITIAL.
      rv_source = iv_source.
    ENDIF.
    LOOP AT it_source INTO lv_line.
      IF rv_source IS INITIAL.
        rv_source = lv_line.
      ELSE.
        rv_source = rv_source && cl_abap_char_utilities=>newline && lv_line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD wrap_if_needed.
    DATA lo_lexer TYPE REF TO lcl_lexer.
    DATA lt_toks   TYPE lcl_lexer=>ty_tokens.
    DATA lt_stmts  TYPE if_ci_atc_source_code_provider=>ty_statements.

    lo_lexer = NEW #( iv_source ).
    lt_toks = lo_lexer->run( ).
    lt_stmts = lcl_parser=>build_statements( lt_toks ).
    IF lcl_parser=>has_method( lt_stmts ) = abap_true.
      rv_source = iv_source.
    ELSE.
      rv_source = |METHOD test.| && cl_abap_char_utilities=>newline
               && iv_source && cl_abap_char_utilities=>newline && |ENDMETHOD.|.
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    DATA lo_lexer    TYPE REF TO lcl_lexer.
    DATA lo_provider TYPE REF TO lcl_test_code_provider.
    DATA lv_src      TYPE string.
    DATA lt_toks     TYPE lcl_lexer=>ty_tokens.
    DATA lt_stmts    TYPE if_ci_atc_source_code_provider=>ty_statements.
    DATA ls_proc     TYPE if_ci_atc_source_code_provider=>ty_procedure.

    IF iv_class_definition = abap_true.
      lv_src = iv_source.
    ELSE.
      lv_src = wrap_if_needed( iv_source ).
    ENDIF.
    lo_lexer = NEW #( lv_src ).
    lt_toks = lo_lexer->run( ).
    lt_stmts = lcl_parser=>build_statements( lt_toks ).
    ls_proc = lcl_parser=>slice_procedure( it_statements       = lt_stmts
                                           iv_class_definition = iv_class_definition ).

    lo_provider = NEW #( ).
    lo_provider->set_procedure( ls_proc ).
    rt_findings = io_check->run_for_testing( is_procedure     = ls_proc
                                             io_code_provider = lo_provider ).
  ENDMETHOD.
ENDCLASS.
