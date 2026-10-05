CLASS lcl_lexer DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_source TYPE string.

    METHODS run
      RETURNING VALUE(rt_tokens) TYPE zif_skylint_types=>ty_tokens.

  PRIVATE SECTION.
    DATA mv_src      TYPE string.
    DATA mv_len      TYPE i.
    DATA mv_pos      TYPE i.
    DATA mv_line     TYPE i.
    DATA mv_col      TYPE i.
    DATA mv_tok_line TYPE i.
    DATA mv_tok_col  TYPE i.
    DATA mv_nl       TYPE string.
    DATA mt_tokens   TYPE zif_skylint_types=>ty_tokens.

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

    METHODS emit_token
      IMPORTING iv_text TYPE string
                iv_type TYPE zif_skylint_types=>ty_token_type.

    METHODS scan_comment.
    METHODS scan_pragma.

    METHODS scan_string
      IMPORTING iv_quote TYPE string.

    METHODS scan_template.
    METHODS scan_field_symbol.
    METHODS scan_word.
ENDCLASS.


CLASS lcl_compiler DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS classify_statement
      IMPORTING it_tokens         TYPE zif_skylint_types=>ty_tokens
                iv_in_chain       TYPE abap_bool
                iv_header_kw      TYPE string
      RETURNING VALUE(rv_keyword) TYPE zif_skylint_types=>ty_keyword.

    CLASS-METHODS is_assignment
      IMPORTING it_tokens     TYPE zif_skylint_types=>ty_tokens
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_method_call
      IMPORTING it_tokens     TYPE zif_skylint_types=>ty_tokens
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS enrich_references
      CHANGING cs_statement TYPE zif_skylint_types=>ty_statement.

  PRIVATE SECTION.
    CLASS-METHODS add_method_references
      IMPORTING iv_upper TYPE string
      CHANGING  ct_refs  TYPE zif_skylint_types=>ty_compiler_references.

    CLASS-METHODS add_inline_declaration_refs
      IMPORTING iv_upper TYPE string
      CHANGING  ct_refs  TYPE zif_skylint_types=>ty_compiler_references.

    CLASS-METHODS add_explicit_declaration_refs
      CHANGING cs_statement TYPE zif_skylint_types=>ty_statement.

    CLASS-METHODS add_database_references
      CHANGING cs_statement TYPE zif_skylint_types=>ty_statement.

    CLASS-METHODS add_system_var_references
      CHANGING cs_statement TYPE zif_skylint_types=>ty_statement.

    CLASS-METHODS add_type_references
      CHANGING cs_statement TYPE zif_skylint_types=>ty_statement.
ENDCLASS.


CLASS lcl_parser DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS build_statements
      IMPORTING it_tokens            TYPE zif_skylint_types=>ty_tokens
      RETURNING VALUE(rt_statements) TYPE zif_skylint_types=>ty_statements.

    CLASS-METHODS has_method
      IMPORTING it_statements TYPE zif_skylint_types=>ty_statements
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS paren_delta
      IMPORTING iv_lexeme       TYPE string
      RETURNING VALUE(rv_delta) TYPE i.

  PRIVATE SECTION.
    CLASS-METHODS emit_statement
      IMPORTING it_prefix     TYPE zif_skylint_types=>ty_tokens
                it_body       TYPE zif_skylint_types=>ty_tokens
                it_pseudo     TYPE string_table
                iv_in_chain   TYPE abap_bool
                iv_header_kw  TYPE string
      CHANGING  ct_statements TYPE zif_skylint_types=>ty_statements.

    CLASS-METHODS collect_pseudo
      IMPORTING is_token      TYPE zif_skylint_types=>ty_token
      CHANGING  ct_statements TYPE zif_skylint_types=>ty_statements
                ct_pending    TYPE string_table.

    CLASS-METHODS pseudo_words
      IMPORTING iv_text         TYPE string
      RETURNING VALUE(rt_words) TYPE string_table.
ENDCLASS.


CLASS lcl_code_block_builder DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS slice_code_block
      IMPORTING it_statements        TYPE zif_skylint_types=>ty_statements
                iv_class_definition  TYPE abap_bool DEFAULT abap_false
                iv_object_name       TYPE string    OPTIONAL
      RETURNING VALUE(rs_code_block) TYPE zif_skylint_types=>ty_code_block.
ENDCLASS.


CLASS lcl_runner DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS join_source
      IMPORTING iv_source        TYPE string       OPTIONAL
                it_source        TYPE string_table OPTIONAL
      RETURNING VALUE(rv_source) TYPE string.

    CLASS-METHODS execute
      IMPORTING io_check            TYPE REF TO zcl_skylint_check_base
                iv_source           TYPE string
                iv_class_definition TYPE abap_bool DEFAULT abap_false
                iv_object_name      TYPE string    OPTIONAL
      RETURNING VALUE(rt_findings)  TYPE zif_skylint_types=>ty_findings
      RAISING   cx_static_check.

    CLASS-METHODS build_code_block
      IMPORTING iv_source            TYPE string
                iv_class_definition  TYPE abap_bool DEFAULT abap_false
                iv_object_name       TYPE string    OPTIONAL
      RETURNING VALUE(rs_code_block) TYPE zif_skylint_types=>ty_code_block.

    CLASS-METHODS wrap_source
      IMPORTING iv_source           TYPE string
                iv_class_definition TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_source)    TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS wrap_if_needed
      IMPORTING iv_source        TYPE string
      RETURNING VALUE(rv_source) TYPE string.
ENDCLASS.


CLASS lcl_applier DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS apply
      IMPORTING it_lines        TYPE string_table
                is_code_block   TYPE zif_skylint_types=>ty_code_block
                is_recorded     TYPE zif_skylint_types=>ty_quickfix
      RETURNING VALUE(rt_lines) TYPE string_table.

  PRIVATE SECTION.
    CLASS-METHODS statement_lines
      IMPORTING is_code_block TYPE zif_skylint_types=>ty_code_block
                iv_index      TYPE i
      EXPORTING ev_first      TYPE i
                ev_last       TYPE i
                ev_found      TYPE abap_bool.

    CLASS-METHODS join_code
      IMPORTING it_code        TYPE zif_skylint_types=>ty_code_lines
      RETURNING VALUE(rv_text) TYPE string.

    CLASS-METHODS apply_token_replace
      IMPORTING it_lines        TYPE string_table
                is_code_block   TYPE zif_skylint_types=>ty_code_block
                is_recorded     TYPE zif_skylint_types=>ty_quickfix
      RETURNING VALUE(rt_lines) TYPE string_table.

    CLASS-METHODS apply_statement_replace
      IMPORTING it_lines        TYPE string_table
                is_code_block   TYPE zif_skylint_types=>ty_code_block
                is_recorded     TYPE zif_skylint_types=>ty_quickfix
      RETURNING VALUE(rt_lines) TYPE string_table.

    CLASS-METHODS insert_lines
      IMPORTING it_lines        TYPE string_table
                iv_at           TYPE i
                it_code         TYPE zif_skylint_types=>ty_code_lines
      RETURNING VALUE(rt_lines) TYPE string_table.

    CLASS-METHODS delete_lines
      IMPORTING it_lines        TYPE string_table
                iv_from         TYPE i
                iv_to           TYPE i
      RETURNING VALUE(rt_lines) TYPE string_table.
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
    rv_yes = xsdbool( iv_ch = ` ` OR iv_ch = cl_abap_char_utilities=>horizontal_tab OR iv_ch = mv_nl ).
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
    rv_yes = xsdbool( at_end( ) = abap_true OR peek( ) = mv_nl ).
  ENDMETHOD.

  METHOD emit_token.
    DATA ls_token TYPE zif_skylint_types=>ty_token.

    ls_token-lexeme = iv_text.
    ls_token-type   = iv_type.
    ls_token-position-line = mv_tok_line.
    IF mv_tok_col > 255.
      ls_token-position-column = 255.
    ELSE.
      ls_token-position-column = mv_tok_col.
    ENDIF.
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
      mv_tok_line = mv_line.
      mv_tok_col = mv_col.
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
    emit_token( iv_text = lv_text
                iv_type = zif_skylint_types=>token_types-comment ).
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
    emit_token( iv_text = lv_text
                iv_type = zif_skylint_types=>token_types-pragma ).
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
    emit_token( iv_text = lv_text
                iv_type = zif_skylint_types=>token_types-literal ).
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
    emit_token( iv_text = lv_text
                iv_type = zif_skylint_types=>token_types-literal ).
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
    emit_token( iv_text = lv_text
                iv_type = zif_skylint_types=>token_types-identifier ).
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
      emit_token( iv_text = lv_text
                  iv_type = zif_skylint_types=>token_types-identifier ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_compiler IMPLEMENTATION.
  METHOD classify_statement.
    DATA ls_first TYPE zif_skylint_types=>ty_token.

    IF iv_in_chain = abap_true AND iv_header_kw IS NOT INITIAL.
      rv_keyword = iv_header_kw.
      RETURN.
    ENDIF.

    IF lines( it_tokens ) = 0.
      rv_keyword = ''.
      RETURN.
    ENDIF.

    IF is_assignment( it_tokens ) = abap_true.
      rv_keyword = 'COMPUTE'.
    ELSEIF is_method_call( it_tokens ) = abap_true.
      rv_keyword = '+CALL_METHOD'.
    ELSE.
      READ TABLE it_tokens INTO ls_first INDEX 1.
      IF sy-subrc = 0.
        rv_keyword = to_upper( ls_first-lexeme ).
      ELSE.
        rv_keyword = ''.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_assignment.
    DATA ls_tok2 TYPE zif_skylint_types=>ty_token.

    rv_yes = abap_false.
    IF lines( it_tokens ) < 3.
      RETURN.
    ENDIF.

    READ TABLE it_tokens INTO ls_tok2 INDEX 2.
    IF sy-subrc = 0.
      CASE ls_tok2-lexeme.
        WHEN '=' OR '+=' OR '-=' OR '*=' OR '/=' OR '&&=' OR '?='.
          rv_yes = abap_true.
      ENDCASE.
    ENDIF.
  ENDMETHOD.

  METHOD is_method_call.
    DATA ls_first TYPE zif_skylint_types=>ty_token.
    DATA lv_first TYPE string.

    rv_yes = abap_false.
    IF lines( it_tokens ) = 0.
      RETURN.
    ENDIF.

    READ TABLE it_tokens INTO ls_first INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lv_first = to_upper( ls_first-lexeme ).

    IF lv_first NP '*('.
      RETURN.
    ENDIF.

    CASE lv_first.
      WHEN 'VALUE(' OR 'NEW(' OR 'COND(' OR 'SWITCH(' OR 'REF('
        OR 'CONV(' OR 'CAST(' OR 'EXACT(' OR 'CORRESPONDING('
        OR 'LINES(' OR 'XSDBOOL(' OR 'BOOLC(' OR 'STRLEN('
        OR 'DATA(' OR '@DATA(' OR 'FIELD-SYMBOL('.
        RETURN.
    ENDCASE.

    rv_yes = abap_true.
  ENDMETHOD.

  METHOD enrich_references.
    DATA lv_up TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    LOOP AT cs_statement-tokens ASSIGNING <ls_tok>.
      lv_up = to_upper( <ls_tok>-lexeme ).
      add_method_references( EXPORTING iv_upper = lv_up
                             CHANGING  ct_refs  = <ls_tok>-references ).
      add_inline_declaration_refs( EXPORTING iv_upper = lv_up
                                   CHANGING  ct_refs  = <ls_tok>-references ).
    ENDLOOP.

    add_explicit_declaration_refs( CHANGING cs_statement = cs_statement ).
    add_database_references( CHANGING cs_statement = cs_statement ).
    add_system_var_references( CHANGING cs_statement = cs_statement ).
    add_type_references( CHANGING cs_statement = cs_statement ).
  ENDMETHOD.

  METHOD add_method_references.
    DATA lv_cls  TYPE string.
    DATA lv_meth TYPE string.
    DATA lv_len  TYPE i.
    DATA ls_ref  TYPE zif_skylint_types=>ty_compiler_reference.

    IF iv_upper CS '=>'.
      SPLIT iv_upper AT '=>' INTO lv_cls lv_meth.
      IF lv_meth CP '*('.
        lv_len = strlen( lv_meth ) - 1.
        lv_meth = lv_meth(lv_len).
      ENDIF.
      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-type.
      ls_ref-full_name   = |\\TY:{ lv_cls }|.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      INSERT ls_ref INTO TABLE ct_refs.

      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-method.
      ls_ref-full_name   = |\\TY:{ lv_cls }\\ME:{ lv_meth }|.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      ls_ref-usage_mode  = zif_skylint_types=>usage_modes-read.
      INSERT ls_ref INTO TABLE ct_refs.
    ELSEIF iv_upper CS '->'.
      SPLIT iv_upper AT '->' INTO lv_cls lv_meth.
      IF lv_meth CP '*('.
        lv_len = strlen( lv_meth ) - 1.
        lv_meth = lv_meth(lv_len).
      ENDIF.
      CLEAR ls_ref.
      ls_ref-kind = zif_skylint_types=>compiler_reference_kinds-method.
      IF lv_cls = 'ME'.
        ls_ref-full_name = |\\TY:ZSKYLINT_TEST\\ME:{ lv_meth }|.
      ELSE.
        ls_ref-full_name = |{ lv_cls }->{ lv_meth }|.
      ENDIF.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      ls_ref-usage_mode  = zif_skylint_types=>usage_modes-read.
      INSERT ls_ref INTO TABLE ct_refs.
    ENDIF.
  ENDMETHOD.

  METHOD add_inline_declaration_refs.
    DATA lv_off  TYPE i.
    DATA lv_len  TYPE i.
    DATA lv_name TYPE string.
    DATA ls_ref  TYPE zif_skylint_types=>ty_compiler_reference.

    lv_name = ''.
    IF iv_upper CP 'DATA(*)' OR iv_upper CP '@DATA(*)' OR iv_upper CP 'FINAL(*)'.
      FIND FIRST OCCURRENCE OF '(' IN iv_upper MATCH OFFSET lv_off.
      IF sy-subrc = 0.
        lv_off = lv_off + 1.
        lv_len = strlen( iv_upper ) - lv_off - 1.
        IF lv_len > 0.
          lv_name = iv_upper+lv_off(lv_len).
        ENDIF.
      ENDIF.
    ELSEIF iv_upper CP 'FIELD-SYMBOL(*)' OR iv_upper CP 'FIELD-SYMBOLS(*)'.
      FIND FIRST OCCURRENCE OF '(' IN iv_upper MATCH OFFSET lv_off.
      IF sy-subrc = 0.
        lv_off = lv_off + 1.
        lv_len = strlen( iv_upper ) - lv_off - 1.
        IF lv_len > 0.
          lv_name = iv_upper+lv_off(lv_len).
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_name IS NOT INITIAL.
      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-data.
      ls_ref-full_name   = |\\TY:ZSKYLINT_TEST\\ME:TEST\\DA:{ lv_name }|.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-definition.
      ls_ref-usage_mode  = zif_skylint_types=>usage_modes-definition_with_write.
      INSERT ls_ref INTO TABLE ct_refs.
    ENDIF.
  ENDMETHOD.

  METHOD add_explicit_declaration_refs.
    DATA lv_var_name TYPE string.
    DATA ls_ref      TYPE zif_skylint_types=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    IF     cs_statement-keyword <> 'DATA'          AND cs_statement-keyword <> 'CONSTANTS'
       AND cs_statement-keyword <> 'FIELD-SYMBOLS' AND cs_statement-keyword <> 'STATICS'.
      RETURN.
    ENDIF.

    IF lines( cs_statement-tokens ) >= 2.
      ASSIGN cs_statement-tokens[ 2 ] TO <ls_tok>.
      IF sy-subrc = 0.
        lv_var_name = to_upper( <ls_tok>-lexeme ).
        CLEAR ls_ref.
        ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-data.
        ls_ref-full_name   = |\\TY:ZSKYLINT_TEST\\ME:TEST\\DA:{ lv_var_name }|.
        ls_ref-usage_grade = zif_skylint_types=>usage_grades-definition.
        ls_ref-usage_mode  = zif_skylint_types=>usage_modes-definition.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD add_database_references.
    DATA ls_ref   TYPE zif_skylint_types=>ty_compiler_reference.
    DATA lv_mode  TYPE zif_skylint_types=>ty_usage_mode.
    DATA lv_is_db TYPE abap_bool.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    CASE cs_statement-keyword.
      WHEN 'SELECT'.
        lv_is_db = abap_true.
        lv_mode = zif_skylint_types=>usage_modes-read_database.
      WHEN 'UPDATE' OR 'MODIFY' OR 'INSERT' OR 'DELETE'.
        lv_is_db = abap_true.
        lv_mode = zif_skylint_types=>usage_modes-write_database.
    ENDCASE.

    IF lv_is_db = abap_true AND lines( cs_statement-tokens ) > 0.
      ASSIGN cs_statement-tokens[ 1 ] TO <ls_tok>.
      IF sy-subrc = 0.
        CLEAR ls_ref.
        ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-data.
        ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
        ls_ref-usage_mode  = lv_mode.
        ls_ref-full_name   = |\\DB:{ cs_statement-keyword }|.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD add_system_var_references.
    DATA lv_up     TYPE string.
    DATA ls_ref    TYPE zif_skylint_types=>ty_compiler_reference.
    DATA lv_is_tgt TYPE abap_bool.
    DATA lv_idx    TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    LOOP AT cs_statement-tokens ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      lv_up = to_upper( <ls_tok>-lexeme ).
      IF NOT ( lv_up CP 'SY-*' OR lv_up CP 'SYST-*' ).
        CONTINUE.
      ENDIF.

      lv_is_tgt = abap_false.
      IF lv_idx = 1 AND cs_statement-keyword = 'COMPUTE'.
        lv_is_tgt = abap_true.
      ENDIF.

      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-data.
      ls_ref-full_name   = |\\PR:ZSKYLINT\\DA:{ lv_up }|.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      IF lv_is_tgt = abap_true.
        ls_ref-usage_mode = zif_skylint_types=>usage_modes-write.
      ELSE.
        ls_ref-usage_mode = zif_skylint_types=>usage_modes-read.
      ENDIF.
      INSERT ls_ref INTO TABLE <ls_tok>-references.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_type_references.
    DATA lv_prev TYPE string.
    DATA lv_up   TYPE string.
    DATA ls_ref  TYPE zif_skylint_types=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    LOOP AT cs_statement-tokens ASSIGNING <ls_tok>.
      lv_up = to_upper( <ls_tok>-lexeme ).
      IF    (     ( lv_prev = 'TYPE' OR lv_prev = 'LIKE' )
              AND lv_up <> '('    AND lv_up <> ')'
              AND lv_up <> 'LINE' AND lv_up <> 'REF' AND lv_up <> 'TABLE' )
         OR lv_up CP 'CX_SY_*'.
        CLEAR ls_ref.
        ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-type.
        ls_ref-full_name   = |\\TY:{ lv_up }|.
        ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
        ls_ref-usage_mode  = zif_skylint_types=>usage_modes-read.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
      ENDIF.
      lv_prev = lv_up.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_parser IMPLEMENTATION.
  METHOD build_statements.
    DATA lt_cur       TYPE zif_skylint_types=>ty_tokens.
    DATA lt_prefix    TYPE zif_skylint_types=>ty_tokens.
    DATA lt_pending   TYPE string_table.
    DATA lv_in_chain  TYPE abap_bool.
    DATA lv_header_kw TYPE string.
    DATA lv_depth     TYPE i.
    DATA ls_tok       TYPE zif_skylint_types=>ty_token.

    CLEAR rt_statements.
    LOOP AT it_tokens INTO ls_tok.
      IF    ls_tok-type = zif_skylint_types=>token_types-comment
         OR ls_tok-type = zif_skylint_types=>token_types-pragma.
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
    DATA lt_all  TYPE zif_skylint_types=>ty_tokens.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA lv_word TYPE string.
    FIELD-SYMBOLS <ls_t> TYPE zif_skylint_types=>ty_token.

    IF iv_in_chain = abap_true.
      APPEND LINES OF it_prefix TO lt_all.
    ENDIF.
    APPEND LINES OF it_body TO lt_all.
    IF lines( lt_all ) = 0.
      RETURN.
    ENDIF.

    CLEAR ls_stmt.
    ls_stmt-tokens = lt_all.
    ASSIGN ls_stmt-tokens[ 1 ] TO <ls_t>.
    IF sy-subrc = 0.
      ls_stmt-position = <ls_t>-position.
    ENDIF.

    LOOP AT it_pseudo INTO lv_word.
      IF NOT line_exists( ls_stmt-pseudo_comments[ table_line = lv_word ] ).
        INSERT lv_word INTO TABLE ls_stmt-pseudo_comments.
      ENDIF.
    ENDLOOP.

    ls_stmt-keyword = lcl_compiler=>classify_statement( it_tokens    = lt_all
                                                        iv_in_chain  = iv_in_chain
                                                        iv_header_kw = iv_header_kw ).

    lcl_compiler=>enrich_references( CHANGING cs_statement = ls_stmt ).
    APPEND ls_stmt TO ct_statements.
  ENDMETHOD.

  METHOD collect_pseudo.
    DATA lt_words TYPE string_table.
    DATA lv_word  TYPE string.
    DATA lv_idx   TYPE i.
    FIELD-SYMBOLS <ls_last> TYPE zif_skylint_types=>ty_statement.

    IF is_token-type = zif_skylint_types=>token_types-pragma AND strlen( is_token-lexeme ) > 2.
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
      ASSIGN ct_statements[ lv_idx ] TO <ls_last>.
      IF sy-subrc = 0 AND <ls_last>-position-line = is_token-position-line.
        LOOP AT lt_words INTO lv_word.
          IF NOT line_exists( <ls_last>-pseudo_comments[ table_line = lv_word ] ).
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
      lv_part = condense( lv_part ).
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

  METHOD has_method.
    " TODO: variable is assigned but never used (ABAP cleaner)
    FIELD-SYMBOLS <ls_stmt> TYPE zif_skylint_types=>ty_statement.

    rv_yes = abap_false.
    LOOP AT it_statements ASSIGNING <ls_stmt> WHERE keyword = 'METHOD'.
      rv_yes = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_code_block_builder IMPLEMENTATION.
  METHOD slice_code_block.
    DATA lv_started TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt> TYPE zif_skylint_types=>ty_statement.

    CLEAR rs_code_block.
    rs_code_block-object_type = zif_skylint_types=>object_types-class.
    IF iv_object_name IS NOT INITIAL.
      rs_code_block-object_name = iv_object_name.
    ELSE.
      rs_code_block-object_name = 'ZSKYLINT_TEST'.
    ENDIF.
    IF iv_class_definition = abap_true.
      rs_code_block-block_kind = zif_skylint_types=>block_kinds-class_definition.
      rs_code_block-block_name = '0'.
      LOOP AT it_statements ASSIGNING <ls_stmt>.
        <ls_stmt>-index = sy-tabix.
        APPEND <ls_stmt> TO rs_code_block-statements.
      ENDLOOP.
      RETURN.
    ENDIF.
    rs_code_block-block_kind = zif_skylint_types=>block_kinds-method.
    rs_code_block-block_name = |{ rs_code_block-object_name }=>TEST|.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF lv_started = abap_false AND <ls_stmt>-keyword = 'METHOD'.
        lv_started = abap_true.
      ENDIF.
      IF lv_started = abap_true.
        <ls_stmt>-index = lines( rs_code_block-statements ) + 1.
        APPEND <ls_stmt> TO rs_code_block-statements.
      ENDIF.
      IF lv_started = abap_true AND <ls_stmt>-keyword = 'ENDMETHOD'.
        RETURN.
      ENDIF.
    ENDLOOP.
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
    DATA lt_toks  TYPE zif_skylint_types=>ty_tokens.
    DATA lt_stmts TYPE zif_skylint_types=>ty_statements.

    lo_lexer = NEW #( iv_source ).
    lt_toks = lo_lexer->run( ).
    lt_stmts = lcl_parser=>build_statements( lt_toks ).
    IF lcl_parser=>has_method( lt_stmts ) = abap_true.
      rv_source = iv_source.
    ELSE.
      rv_source = |METHOD test.{ cl_abap_char_utilities=>newline }|
               && |{ iv_source }{ cl_abap_char_utilities=>newline }ENDMETHOD.|.
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    DATA ls_proc TYPE zif_skylint_types=>ty_code_block.

    ls_proc = build_code_block( iv_source           = iv_source
                                iv_class_definition = iv_class_definition
                                iv_object_name      = iv_object_name ).

    rt_findings = io_check->lint( ls_proc ).
  ENDMETHOD.

  METHOD wrap_source.
    IF iv_class_definition = abap_true.
      rv_source = iv_source.
    ELSE.
      rv_source = wrap_if_needed( iv_source ).
    ENDIF.
  ENDMETHOD.

  METHOD build_code_block.
    DATA lo_lexer TYPE REF TO lcl_lexer.
    DATA lv_src   TYPE string.
    DATA lt_toks  TYPE zif_skylint_types=>ty_tokens.
    DATA lt_stmts TYPE zif_skylint_types=>ty_statements.

    lv_src = wrap_source( iv_source           = iv_source
                          iv_class_definition = iv_class_definition ).
    lo_lexer = NEW #( lv_src ).
    lt_toks = lo_lexer->run( ).
    lt_stmts = lcl_parser=>build_statements( lt_toks ).
    rs_code_block = lcl_code_block_builder=>slice_code_block( it_statements       = lt_stmts
                                                              iv_class_definition = iv_class_definition
                                                              iv_object_name      = iv_object_name ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_applier IMPLEMENTATION.
  METHOD apply.
    IF is_recorded-token_from > 0.
      rt_lines = apply_token_replace( it_lines      = it_lines
                                      is_code_block = is_code_block
                                      is_recorded   = is_recorded ).
    ELSE.
      rt_lines = apply_statement_replace( it_lines      = it_lines
                                          is_code_block = is_code_block
                                          is_recorded   = is_recorded ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_token_replace.
    DATA ls_stmt     TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok_from TYPE zif_skylint_types=>ty_token.
    DATA ls_tok_to   TYPE zif_skylint_types=>ty_token.
    DATA lv_line     TYPE string.
    DATA lv_line_no  TYPE i.
    DATA lv_new      TYPE string.
    DATA lv_col_from TYPE i.
    DATA lv_col_to   TYPE i.
    DATA lv_cut_from TYPE i.
    DATA lv_cut_to   TYPE i.
    DATA lv_len      TYPE i.
    DATA lv_head     TYPE string.
    DATA lv_tail     TYPE string.

    rt_lines = it_lines.
    ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                   iv_index      = is_recorded-statement_from ).
    IF ls_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.
    ls_tok_from = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                                   iv_index     = is_recorded-token_from ).
    ls_tok_to = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                                 iv_index     = is_recorded-token_to ).
    IF ls_tok_from-lexeme IS INITIAL OR ls_tok_to-lexeme IS INITIAL.
      RETURN.
    ENDIF.
    lv_line_no = ls_tok_from-position-line.
    READ TABLE rt_lines INTO lv_line INDEX lv_line_no.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lv_len = strlen( lv_line ).
    lv_col_from = ls_tok_from-position-column.
    lv_col_to = ls_tok_to-position-column + strlen( ls_tok_to-lexeme ).
    lv_cut_from = lv_col_from - 1.
    lv_cut_to = lv_col_to - 1.
    IF lv_cut_from < 0.
      lv_cut_from = 0.
    ENDIF.
    IF lv_cut_from > lv_len.
      lv_cut_from = lv_len.
    ENDIF.
    IF lv_cut_to < 0.
      lv_cut_to = 0.
    ENDIF.
    IF lv_cut_to > lv_len.
      lv_cut_to = lv_len.
    ENDIF.
    lv_new = join_code( is_recorded-new_code ).
    lv_head = lv_line(lv_cut_from).
    lv_tail = lv_line+lv_cut_to.
    lv_line = lv_head && lv_new && lv_tail.
    MODIFY rt_lines FROM lv_line INDEX lv_line_no.
  ENDMETHOD.

  METHOD apply_statement_replace.
    DATA lv_stmt_to TYPE i.
    DATA lv_start   TYPE i.
    DATA lv_end     TYPE i.
    DATA lv_found   TYPE abap_bool.

    rt_lines = it_lines.
    lv_stmt_to = is_recorded-statement_to.
    IF lv_stmt_to IS INITIAL.
      lv_stmt_to = is_recorded-statement_from.
    ENDIF.
    statement_lines( EXPORTING is_code_block = is_code_block
                               iv_index      = is_recorded-statement_from
                     IMPORTING ev_first      = lv_start
                               ev_found      = lv_found ).
    statement_lines( EXPORTING is_code_block = is_code_block
                               iv_index      = lv_stmt_to
                     IMPORTING ev_last       = lv_end
                               ev_found      = lv_found ).
    IF lv_found = abap_false.
      RETURN.
    ENDIF.
    rt_lines = delete_lines( it_lines = rt_lines
                             iv_from  = lv_start
                             iv_to    = lv_end ).
    rt_lines = insert_lines( it_lines = rt_lines
                             iv_at    = lv_start
                             it_code  = is_recorded-new_code ).
  ENDMETHOD.

  METHOD insert_lines.
    DATA lv_row TYPE string.
    DATA lv_ins TYPE i.

    rt_lines = it_lines.
    lv_ins = iv_at.
    LOOP AT it_code INTO lv_row.
      INSERT lv_row INTO rt_lines INDEX lv_ins.
      lv_ins = lv_ins + 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_lines.
    DATA lv_del TYPE i.

    rt_lines = it_lines.
    IF iv_to < iv_from.
      RETURN.
    ENDIF.
    lv_del = iv_to - iv_from + 1.
    DO lv_del TIMES.
      DELETE rt_lines INDEX iv_from.
    ENDDO.
  ENDMETHOD.

  METHOD statement_lines.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.

    CLEAR ev_first.
    CLEAR ev_last.
    ev_found = abap_false.
    ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                   iv_index      = iv_index ).
    IF ls_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.
    ev_found = abap_true.
    ev_first = ls_stmt-position-line.
    ev_last = ev_first.
    LOOP AT ls_stmt-tokens INTO ls_tok.
      IF ls_tok-position-line > ev_last.
        ev_last = ls_tok-position-line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD join_code.
    DATA lv_row TYPE string.

    CLEAR rv_text.
    LOOP AT it_code INTO lv_row.
      IF rv_text IS INITIAL.
        rv_text = lv_row.
      ELSE.
        rv_text = |{ rv_text } { lv_row }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
