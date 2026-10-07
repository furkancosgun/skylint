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

    CLASS-METHODS find_db_table_index
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_index) TYPE i.

    CLASS-METHODS is_db_table_name
      IMPORTING iv_lexeme     TYPE zif_skylint_types=>ty_lexeme
      RETURNING VALUE(rv_yes) TYPE abap_bool.

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
                iv_chain_idx  TYPE i DEFAULT 0
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


CLASS lcl_abaplint_bridge DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS enrich
      IMPORTING iv_full_source TYPE string
                iv_object_name TYPE string OPTIONAL
                iv_abs_offset  TYPE i DEFAULT 0
      CHANGING  ct_statements  TYPE zif_skylint_types=>ty_statements.

  PRIVATE SECTION.
    CLASS-METHODS build_payload
      IMPORTING iv_full_source    TYPE string
                iv_object_name    TYPE string OPTIONAL
                iv_abs_offset     TYPE i DEFAULT 0
      RETURNING VALUE(rv_payload) TYPE string.

    CLASS-METHODS apply_payload
      IMPORTING iv_payload TYPE string
      CHANGING  ct_statements TYPE zif_skylint_types=>ty_statements.

    CLASS-METHODS apply_ref_line
      IMPORTING iv_line TYPE string
      CHANGING  ct_statements TYPE zif_skylint_types=>ty_statements.

    CLASS-METHODS feed_rtti
      IMPORTING iv_full_source TYPE string
                iv_object_name TYPE string OPTIONAL.
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
                iv_full_source      TYPE string OPTIONAL
                iv_class_definition TYPE abap_bool DEFAULT abap_false
                iv_abs_offset       TYPE i DEFAULT 0
                iv_object_name      TYPE string    OPTIONAL
      RETURNING VALUE(rt_findings)  TYPE zif_skylint_types=>ty_findings
      RAISING   cx_static_check.

    CLASS-METHODS build_code_block
      IMPORTING iv_source            TYPE string
                iv_full_source       TYPE string OPTIONAL
                iv_class_definition  TYPE abap_bool DEFAULT abap_false
                iv_abs_offset        TYPE i DEFAULT 0
                iv_object_name       TYPE string    OPTIONAL
      RETURNING VALUE(rs_code_block) TYPE zif_skylint_types=>ty_code_block.
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
    mv_col = 0.
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
      mv_col = 0.
    ELSE.
      mv_col = mv_col + 1.
    ENDIF.
    rv_ch = lv_ch.
  ENDMETHOD.

  METHOD is_blank.
    rv_yes = xsdbool( iv_ch = ` ` OR iv_ch = cl_abap_char_utilities=>horizontal_tab OR iv_ch = mv_nl ).
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
          IF mv_col = 0.
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
      IF is_blank( lv_ch ) = abap_true.
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

  METHOD scan_word.
    DATA lv_text TYPE string.
    DATA lv_ch   TYPE string.

    lv_text = ''.
    WHILE at_end( ) = abap_false.
      lv_ch = peek( ).
      IF is_blank( lv_ch ) = abap_true.
        EXIT.
      ENDIF.
      lv_text = lv_text && advance( ).
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
        OR 'STRING(' OR 'TABLE(' OR 'FILTER(' OR 'REDUCE('
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
      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-type.
      ls_ref-full_name   = |\\TY:{ lv_cls }|.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      INSERT ls_ref INTO TABLE ct_refs.

      IF lv_meth CS '('.
        IF lv_meth CP '*('.
          lv_len = strlen( lv_meth ) - 1.
          lv_meth = lv_meth(lv_len).
        ENDIF.
        CLEAR ls_ref.
        ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-method.
        ls_ref-full_name   = |\\TY:{ lv_cls }\\ME:{ lv_meth }|.
        ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
        ls_ref-usage_mode  = zif_skylint_types=>usage_modes-read.
        INSERT ls_ref INTO TABLE ct_refs.
      ENDIF.
    ELSEIF iv_upper CS '->' AND iv_upper CS '('.
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
    DATA ls_ref     TYPE zif_skylint_types=>ty_compiler_reference.
    DATA lv_mode    TYPE zif_skylint_types=>ty_usage_mode.
    DATA lv_tab_idx TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    CASE cs_statement-keyword.
      WHEN 'SELECT'.
        lv_mode = zif_skylint_types=>usage_modes-read_database.
      WHEN 'UPDATE' OR 'MODIFY' OR 'INSERT' OR 'DELETE'.
        lv_mode = zif_skylint_types=>usage_modes-write_database.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    lv_tab_idx = find_db_table_index( cs_statement ).
    IF lv_tab_idx <= 0.
      RETURN.
    ENDIF.

    ASSIGN cs_statement-tokens[ lv_tab_idx ] TO <ls_tok>.
    IF sy-subrc = 0.
      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-data.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      ls_ref-usage_mode  = lv_mode.
      ls_ref-full_name   = |\\DB:{ to_upper( <ls_tok>-lexeme ) }|.
      INSERT ls_ref INTO TABLE <ls_tok>-references.
    ENDIF.
  ENDMETHOD.

  METHOD find_db_table_index.
    DATA lv_count  TYPE i.
    DATA lv_idx    TYPE i.
    DATA ls_tok    TYPE zif_skylint_types=>ty_token.
    DATA lv_anchor TYPE string.
    FIELD-SYMBOLS <ls_t> TYPE zif_skylint_types=>ty_token.

    rv_index = 0.
    lv_count = lines( is_statement-tokens ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    CASE is_statement-keyword.
      WHEN 'SELECT' OR 'DELETE' OR 'MODIFY'.
        lv_anchor = 'FROM'.
      WHEN 'INSERT'.
        lv_anchor = 'INTO'.
      WHEN 'UPDATE'.
        lv_anchor = ''.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    IF lv_anchor IS NOT INITIAL.
      LOOP AT is_statement-tokens ASSIGNING <ls_t>.
        IF to_upper( <ls_t>-lexeme ) <> lv_anchor.
          CONTINUE.
        ENDIF.

        lv_idx = sy-tabix + 1.
        IF lv_idx <= lv_count.
          READ TABLE is_statement-tokens INTO ls_tok INDEX lv_idx.
          IF sy-subrc = 0 AND to_upper( ls_tok-lexeme ) = 'TABLE'.
            lv_idx = lv_idx + 1.
          ENDIF.
        ENDIF.
        IF lv_idx <= lv_count.
          READ TABLE is_statement-tokens INTO ls_tok INDEX lv_idx.
          IF sy-subrc = 0 AND is_db_table_name( ls_tok-lexeme ) = abap_true.
            rv_index = lv_idx.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF    is_statement-keyword = 'INSERT' OR is_statement-keyword = 'UPDATE'
       OR is_statement-keyword = 'DELETE' OR is_statement-keyword = 'MODIFY'.
      READ TABLE is_statement-tokens INTO ls_tok INDEX 2.
      IF sy-subrc = 0 AND is_db_table_name( ls_tok-lexeme ) = abap_true.
        rv_index = 2.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_db_table_name.
    DATA lv_upper TYPE string.

    rv_yes = abap_false.
    IF iv_lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_upper = to_upper( iv_lexeme ).
    IF lv_upper(1) CA `'@(*0123456789`.
      RETURN.
    ENDIF.

    CASE lv_upper.
      WHEN 'FROM' OR 'INTO' OR 'TABLE' OR 'WHERE' OR 'SET' OR 'SINGLE'
        OR 'UP' OR 'TO' OR 'ROWS' OR 'BY' OR 'APPENDING' OR 'CORRESPONDING'
        OR 'FIELDS' OR 'ALL' OR 'DISTINCT' OR 'FOR' OR 'REPORT' OR 'SCREEN'
        OR 'USING' OR 'CLIENT' OR 'CONNECTION' OR 'AND' OR 'OR'
        OR 'ORDER' OR 'GROUP' OR 'HAVING' OR 'JOIN' OR 'INNER'
        OR 'LEFT' OR 'RIGHT' OR 'OUTER' OR 'ON' OR 'AS'.
        RETURN.
      WHEN OTHERS.
        rv_yes = abap_true.
    ENDCASE.
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
    DATA lv_expect TYPE abap_bool.
    DATA lv_up     TYPE string.
    DATA ls_ref    TYPE zif_skylint_types=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_tok> TYPE zif_skylint_types=>ty_token.

    lv_expect = abap_false.
    LOOP AT cs_statement-tokens ASSIGNING <ls_tok>.
      lv_up = to_upper( <ls_tok>-lexeme ).
      IF lv_up CP 'CX_SY_*'.
        CLEAR ls_ref.
        ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-type.
        ls_ref-full_name   = |\\TY:{ lv_up }|.
        ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
        ls_ref-usage_mode  = zif_skylint_types=>usage_modes-read.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
        lv_expect = abap_false.
        CONTINUE.
      ENDIF.
      IF lv_up = 'TYPE' OR lv_up = 'LIKE'.
        lv_expect = abap_true.
        CONTINUE.
      ENDIF.
      IF lv_expect = abap_false.
        CONTINUE.
      ENDIF.
      IF lv_up = 'REF' OR lv_up = 'TO' OR lv_up = 'TABLE' OR lv_up = 'OF' OR lv_up = 'LINE'.
        CONTINUE.
      ENDIF.
      CLEAR ls_ref.
      ls_ref-kind        = zif_skylint_types=>compiler_reference_kinds-type.
      ls_ref-full_name   = |\\TY:{ lv_up }|.
      ls_ref-usage_grade = zif_skylint_types=>usage_grades-direct.
      ls_ref-usage_mode  = zif_skylint_types=>usage_modes-read.
      INSERT ls_ref INTO TABLE <ls_tok>-references.
      lv_expect = abap_false.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_parser IMPLEMENTATION.
  METHOD build_statements.
    DATA lt_cur       TYPE zif_skylint_types=>ty_tokens.
    DATA lt_prefix    TYPE zif_skylint_types=>ty_tokens.
    DATA lt_pending   TYPE string_table.
    DATA lv_in_chain  TYPE abap_bool.
    DATA lv_chain_idx TYPE i.
    DATA lv_header_kw TYPE string.
    DATA lv_depth     TYPE i.
    DATA ls_tok       TYPE zif_skylint_types=>ty_token.
    DATA lv_word      TYPE string.
    DATA lv_last      TYPE string.
    DATA lv_len       TYPE i.
    DATA lv_off       TYPE i.
    DATA lv_delta     TYPE i.

    CLEAR rt_statements.
    LOOP AT it_tokens INTO ls_tok.
      IF    ls_tok-type = zif_skylint_types=>token_types-comment
         OR ls_tok-type = zif_skylint_types=>token_types-pragma.
        collect_pseudo( EXPORTING is_token      = ls_tok
                        CHANGING  ct_statements = rt_statements
                                  ct_pending    = lt_pending ).
        CONTINUE.
      ENDIF.

      lv_word = ls_tok-lexeme.
      IF lv_word IS INITIAL.
        CONTINUE.
      ENDIF.
      lv_len = strlen( lv_word ).
      lv_off = lv_len - 1.
      lv_last = lv_word+lv_off(1).
      lv_delta = paren_delta( lv_word ).

      IF lv_last = '.' AND lv_depth + lv_delta <= 0.
        IF lv_len > 1.
          ls_tok-lexeme = lv_word(lv_off).
          APPEND ls_tok TO lt_cur.
        ENDIF.
        emit_statement( EXPORTING it_prefix     = lt_prefix
                                  it_body       = lt_cur
                                  it_pseudo     = lt_pending
                                  iv_in_chain   = lv_in_chain
                                  iv_header_kw  = lv_header_kw
                                  iv_chain_idx  = lv_chain_idx
                        CHANGING  ct_statements = rt_statements ).
        CLEAR lt_cur.
        CLEAR lt_prefix.
        CLEAR lt_pending.
        CLEAR lv_header_kw.
        lv_in_chain = abap_false.
        lv_chain_idx = 0.
        lv_depth = 0.
      ELSEIF lv_last = ':' AND lv_depth = 0 AND lv_in_chain = abap_false.
        IF lv_len > 1.
          ls_tok-lexeme = lv_word(lv_off).
          APPEND ls_tok TO lt_cur.
        ENDIF.
        lt_prefix = lt_cur.
        IF lines( lt_prefix ) > 0.
          lv_header_kw = to_upper( lt_prefix[ 1 ]-lexeme ).
        ENDIF.
        CLEAR lt_cur.
        lv_in_chain = abap_true.
        lv_chain_idx = 1.
      ELSEIF lv_last = ',' AND lv_depth = 0.
        IF lv_len > 1.
          ls_tok-lexeme = lv_word(lv_off).
          APPEND ls_tok TO lt_cur.
        ENDIF.
        IF lv_in_chain = abap_true.
          emit_statement( EXPORTING it_prefix     = lt_prefix
                                    it_body       = lt_cur
                                    it_pseudo     = lt_pending
                                    iv_in_chain   = abap_true
                                    iv_header_kw  = lv_header_kw
                                    iv_chain_idx  = lv_chain_idx
                          CHANGING  ct_statements = rt_statements ).
          CLEAR lt_cur.
          CLEAR lt_pending.
          lv_chain_idx = lv_chain_idx + 1.
          lv_depth = 0.
        ENDIF.
      ELSE.
        APPEND ls_tok TO lt_cur.
        lv_depth = lv_depth + lv_delta.
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
    IF iv_in_chain = abap_true AND iv_chain_idx > 1 AND lines( it_body ) > 0.
      ASSIGN it_body[ 1 ] TO <ls_t>.
      IF sy-subrc = 0.
        ls_stmt-position-line = <ls_t>-position-line.
      ENDIF.
      ASSIGN ls_stmt-tokens[ 1 ] TO <ls_t>.
      IF sy-subrc = 0.
        ls_stmt-position-column = <ls_t>-position-column.
      ENDIF.
    ELSE.
      ASSIGN ls_stmt-tokens[ 1 ] TO <ls_t>.
      IF sy-subrc = 0.
        ls_stmt-position = <ls_t>-position.
      ENDIF.
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
ENDCLASS.


CLASS lcl_code_block_builder IMPLEMENTATION.
  METHOD slice_code_block.
    DATA lv_started     TYPE abap_bool.
    DATA lv_method_name TYPE string.
    DATA ls_name_token  TYPE zif_skylint_types=>ty_token.
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
        IF lines( <ls_stmt>-tokens ) >= 2.
          ls_name_token = zcl_skylint_ast_util=>get_token( is_statement = <ls_stmt>
                                                           iv_index     = 2 ).
          lv_method_name = to_upper( ls_name_token-lexeme ).
        ENDIF.
      ENDIF.
      IF lv_started = abap_true.
        <ls_stmt>-index = lines( rs_code_block-statements ) + 1.
        APPEND <ls_stmt> TO rs_code_block-statements.
      ENDIF.
      IF lv_started = abap_true AND <ls_stmt>-keyword = 'ENDMETHOD'.
        IF lv_method_name IS NOT INITIAL.
          rs_code_block-block_name = |{ rs_code_block-object_name }=>{ lv_method_name }|.
        ENDIF.
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

  METHOD execute.
    DATA ls_proc TYPE zif_skylint_types=>ty_code_block.

    ls_proc = build_code_block( iv_source           = iv_source
                                iv_full_source      = iv_full_source
                                iv_class_definition = iv_class_definition
                                iv_abs_offset       = iv_abs_offset
                                iv_object_name      = iv_object_name ).

    rt_findings = io_check->lint( ls_proc ).
  ENDMETHOD.

  METHOD build_code_block.
    DATA lo_lexer TYPE REF TO lcl_lexer.
    DATA lt_toks  TYPE zif_skylint_types=>ty_tokens.
    DATA lt_stmts TYPE zif_skylint_types=>ty_statements.
    DATA lv_full  TYPE string.

    lo_lexer = NEW #( iv_source ).
    lt_toks = lo_lexer->run( ).
    lt_stmts = lcl_parser=>build_statements( lt_toks ).
    lv_full = iv_full_source.
    IF lv_full IS INITIAL.
      lv_full = iv_source.
    ENDIF.
    lcl_abaplint_bridge=>enrich( EXPORTING iv_full_source = lv_full
                                           iv_object_name = iv_object_name
                                           iv_abs_offset  = iv_abs_offset
                                 CHANGING  ct_statements  = lt_stmts ).
    rs_code_block = lcl_code_block_builder=>slice_code_block( it_statements       = lt_stmts
                                                              iv_class_definition = iv_class_definition
                                                              iv_object_name      = iv_object_name ).
  ENDMETHOD.
ENDCLASS.


CLASS lcl_abaplint_bridge IMPLEMENTATION.
  METHOD enrich.
    DATA lv_payload TYPE string.

    IF ct_statements IS INITIAL OR iv_full_source IS INITIAL.
      RETURN.
    ENDIF.

    lv_payload = build_payload( iv_full_source = iv_full_source
                                iv_object_name = iv_object_name
                                iv_abs_offset  = iv_abs_offset ).

    IF lv_payload IS INITIAL.
      RETURN.
    ENDIF.

    apply_payload( EXPORTING iv_payload    = lv_payload
                   CHANGING  ct_statements = ct_statements ).

    feed_rtti( iv_full_source = iv_full_source
               iv_object_name = iv_object_name ).
  ENDMETHOD.

  METHOD build_payload.
    DATA lv_full    TYPE string.
    DATA lv_obj     TYPE string.
    DATA lv_off     TYPE i.
    DATA lv_payload TYPE string.

    lv_full = iv_full_source.
    lv_obj = iv_object_name.
    lv_off = iv_abs_offset.

    WRITE '@KERNEL try {'.
    WRITE '@KERNEL   const core = await import("@abaplint/core");'.
    WRITE '@KERNEL   const full = lv_full.get(), on = (lv_obj.get() || "").trim();'.
    WRITE '@KERNEL   const sn = on || "ZSKYLINT_TEST", off = parseInt(lv_off.get() || "0", 10) || 0;'.
    WRITE '@KERNEL   const out = [], tyPre = "\\\\TY:" + sn.toUpperCase(), mePre = "\\\\ME:";'.
    WRITE '@KERNEL   const safe = (s) => (s + "").replace(/[|]/g, " ");'.
    WRITE '@KERNEL   const flat = (s) => safe(s).replace(/[\r\n]+/g, " ");'.
    WRITE '@KERNEL   try {'.
    WRITE '@KERNEL     const {Registry, MemoryFile, SyntaxLogic} = core;'.
    WRITE '@KERNEL     const reg = new Registry();'.
    WRITE '@KERNEL     reg.addFile(new MemoryFile(sn.toLowerCase() + ".clas.abap", full));'.
    WRITE '@KERNEL     await reg.parseAsync();'.
    WRITE '@KERNEL     const obj = reg.getFirstObject();'.
    WRITE '@KERNEL     if (obj) { walk(new SyntaxLogic(reg, obj).run().spaghetti.getTop()); }'.
    WRITE '@KERNEL   } catch (e) { }'.
    WRITE '@KERNEL   function walk(node) {'.
    WRITE '@KERNEL     const data = node.getData ? node.getData() : null;'.
    WRITE '@KERNEL     const refs = (data && data.references) || [];'.
    WRITE '@KERNEL     for (const r of refs) { emitOne(r); }'.
    WRITE '@KERNEL     const kids = node.getChildren ? node.getChildren() : [];'.
    WRITE '@KERNEL     for (const ch of kids) { walk(ch); }'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   function emitOne(r) { try { emitKind(r, relOf(r)); } catch (e) { } }'.
    WRITE '@KERNEL   function relOf(r) {'.
    WRITE '@KERNEL     const pos = r.position ? r.position.getStart() : null;'.
    WRITE '@KERNEL     if (!pos) { return [0, 0]; }'.
    WRITE '@KERNEL     return [pos.getRow() - off, pos.getCol()];'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   function emitKind(r, rel) {'.
    WRITE '@KERNEL     if (rel[0] < 1) { return; }'.
    WRITE '@KERNEL     const rt = (r.referenceType || "").toString();'.
    WRITE '@KERNEL     const id = (r.identifierName || "") + "";'.
    WRITE '@KERNEL     let kind = "";'.
    WRITE '@KERNEL     if (/method/i.test(rt)) { kind = "ME"; }'.
    WRITE '@KERNEL     else if (/type/i.test(rt)) { kind = "TY"; }'.
    WRITE '@KERNEL     else if (/data|variable/i.test(rt)) { kind = "DA"; }'.
    WRITE '@KERNEL     if (kind) { emitResolved(r, rel, kind, id); }'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   function emitResolved(r, rel, kind, id) {'.
    WRITE '@KERNEL     const res = r.resolved;'.
    WRITE '@KERNEL     const stat = isStaticRes(res);'.
    WRITE '@KERNEL     const fn2 = fnameOf(res, kind, id) || id.toUpperCase();'.
    WRITE '@KERNEL     if (fn2) { pushRef(rel, id || fn2, kind, fn2, stat); }'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   function isStaticRes(res) {'.
    WRITE '@KERNEL     try {'.
    WRITE '@KERNEL       const fn = res && res.isStatic;'.
    WRITE '@KERNEL       if (typeof fn === "function" && res.isStatic()) { return "X"; }'.
    WRITE '@KERNEL     } catch (e) { }'.
    WRITE '@KERNEL     return "";'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   function fnameOf(res, kind, id) {'.
    WRITE '@KERNEL     try {'.
    WRITE '@KERNEL       let nm = res && res.getName ? (res.getName() + "") : "";'.
    WRITE '@KERNEL       nm = nm.toUpperCase();'.
    WRITE '@KERNEL       if (nm) { return tyPre + mePre + nm; }'.
    WRITE '@KERNEL     } catch (e) { }'.
    WRITE '@KERNEL     if (kind === "ME" && id) { return tyPre + mePre + id.toUpperCase(); }'.
    WRITE '@KERNEL     return "";'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   function pushRef(rel, id, kind, fname, isStatic) {'.
    WRITE '@KERNEL     const cells = [rel[0], rel[1], flat(id), kind, flat(fname), "1", "5", isStatic];'.
    WRITE '@KERNEL     out.push(cells.join("|"));'.
    WRITE '@KERNEL   }'.

    WRITE '@KERNEL   lv_payload.set(out.join("\n"));'.
    WRITE '@KERNEL } catch (e) { }'.

    rv_payload = lv_payload.
  ENDMETHOD.

  METHOD apply_payload.
    DATA lt_lines TYPE string_table.
    DATA lv_line  TYPE string.

    SPLIT iv_payload AT cl_abap_char_utilities=>newline INTO TABLE lt_lines.
    LOOP AT lt_lines INTO lv_line.
      IF lv_line IS INITIAL.
        CONTINUE.
      ENDIF.
      apply_ref_line( EXPORTING iv_line       = lv_line
                      CHANGING  ct_statements = ct_statements ).
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_ref_line.
    DATA lt_parts TYPE string_table.
    DATA lv_rel   TYPE i.
    DATA lv_col   TYPE i.
    DATA lv_ident TYPE string.
    DATA lv_kind  TYPE string.
    DATA lv_fname TYPE string.
    DATA lv_grade TYPE string.
    DATA lv_mode  TYPE string.
    DATA ls_ref   TYPE zif_skylint_types=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_stmt> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE zif_skylint_types=>ty_token.

    CLEAR lt_parts.
    SPLIT iv_line AT '|' INTO TABLE lt_parts.
    IF lines( lt_parts ) < 7.
      RETURN.
    ENDIF.
    lv_rel = lt_parts[ 1 ].
    lv_col = lt_parts[ 2 ].
    lv_ident = to_upper( lt_parts[ 3 ] ).
    lv_kind = lt_parts[ 4 ].
    lv_fname = lt_parts[ 5 ].
    lv_grade = lt_parts[ 6 ].
    lv_mode = lt_parts[ 7 ].
    IF lv_kind <> 'ME' AND lv_kind <> 'DA' AND lv_kind <> 'TY'.
      RETURN.
    ENDIF.
    LOOP AT ct_statements ASSIGNING <ls_stmt>.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        IF <ls_tok>-position-line <> lv_rel.
          CONTINUE.
        ENDIF.
        IF ( lv_col < <ls_tok>-position-column
             OR lv_col >= <ls_tok>-position-column + strlen( <ls_tok>-lexeme ) )
           AND to_upper( <ls_tok>-lexeme ) NS lv_ident
           AND lv_ident NS to_upper( <ls_tok>-lexeme ).
          CONTINUE.
        ENDIF.
        CLEAR ls_ref.
        ls_ref-kind = lv_kind.
        ls_ref-full_name = lv_fname.
        ls_ref-usage_grade = lv_grade.
        ls_ref-usage_mode = lv_mode.
        INSERT ls_ref INTO TABLE <ls_tok>-references.
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD feed_rtti.
    DATA lv_full TYPE string.
    DATA lv_obj  TYPE string.

    IF iv_full_source IS INITIAL.
      RETURN.
    ENDIF.

    lv_full = iv_full_source.
    lv_obj = iv_object_name.

    WRITE '@KERNEL try {'.
    WRITE '@KERNEL   const full = lv_full.get(), on = (lv_obj.get() || "").trim();'.
    WRITE '@KERNEL   const sn = (on || "ZSKYLINT_TEST").toUpperCase();'.
    WRITE '@KERNEL   globalThis.__skylintFed = globalThis.__skylintFed || {};'.
    WRITE '@KERNEL   const h = (s) => {'.
    WRITE '@KERNEL     let x = 5381;'.
    WRITE '@KERNEL     for (let i = 0; i < s.length; i++) { x = (((x << 5) + x + s.charCodeAt(i)) >>> 0); }'.
    WRITE '@KERNEL     return "k" + x;'.
    WRITE '@KERNEL   };'.
    WRITE '@KERNEL   const fkey = h(full);'.
    WRITE '@KERNEL   let det = "";'.
    WRITE '@KERNEL   const clsRe = /^\s*CLASS\s+(\S+)\s+DEFINITION\b/i;'.
    WRITE '@KERNEL   for (const ln of full.split(/\r?\n/)) {'.
    WRITE '@KERNEL     const m = clsRe.exec(ln);'.
    WRITE '@KERNEL     if (m) { det = m[1].replace(/\.$/, "").toUpperCase(); break; }'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   if (det && !globalThis.__skylintFed[fkey]) {'.
    WRITE '@KERNEL     const files = [{filename: det.toLowerCase() + ".clas.abap", contents: full}];'.
    WRITE '@KERNEL     const {Transpiler} = await import("@abaplint/transpiler");'.
    WRITE '@KERNEL     let tout;'.
    WRITE '@KERNEL     for (let att = 0; att < 4; att++) {'.
    WRITE '@KERNEL       const topt = {ignoreSyntaxCheck: true, unknownTypes: "runtimeError"};'.
    WRITE '@KERNEL       try { tout = await new Transpiler(topt).runRaw(files); break; }'.
    WRITE '@KERNEL       catch (e) { const em = (e && e.message) || "";'.
    WRITE '@KERNEL         const sm = /Super class "([^"]+)" not found/.exec(em);'.
    WRITE '@KERNEL         if (!sm || files.length > 6) { tout = undefined; break; }'.
    WRITE '@KERNEL         const sname = sm[1];'.
    WRITE '@KERNEL         const stub = "CLASS " + sname + " DEFINITION PUBLIC CREATE PUBLIC.\n";'.
    WRITE '@KERNEL         files.push({filename: sname.toLowerCase() + ".clas.abap", contents: stub'.
    WRITE '@KERNEL           + " PUBLIC SECTION.\nENDCLASS.\nCLASS " + sname + " IMPLEMENTATION.\nENDCLASS."}); }'.
    WRITE '@KERNEL     }'.
    WRITE '@KERNEL     if (tout) {'.
    WRITE '@KERNEL       const before = new Set(Object.keys(abap.Classes));'.
    WRITE '@KERNEL       const mfn = files[0].filename;'.
    WRITE '@KERNEL       const isMain = (o) => ((o.filename === mfn) ? 1 : 0);'.
    WRITE '@KERNEL       const ordered = [...tout.objects].sort((a, b) => isMain(a) - isMain(b));'.
    WRITE '@KERNEL       const codes = ordered.filter((o) => o.chunk).map((o) => o.chunk.getCode());'.
    WRITE '@KERNEL       const AsyncFunction = Object.getPrototypeOf(async function(){}).constructor;'.
    WRITE '@KERNEL       await new AsyncFunction("abap", codes.join("\n;\n"))(abap);'.
    WRITE '@KERNEL       const fresh = Object.keys(abap.Classes).filter((k) => !before.has(k));'.
    WRITE '@KERNEL       const tgt = fresh.find((k) => k === det)'.
    WRITE '@KERNEL         || fresh.find((k) => k.endsWith("-" + det))'.
    WRITE '@KERNEL         || (fresh.length === 1 ? fresh[0] : "");'.
    WRITE '@KERNEL       if (tgt) { globalThis.__skylintFed[fkey] = tgt; }'.
    WRITE '@KERNEL     }'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL   const alias = globalThis.__skylintFed[fkey];'.
    WRITE '@KERNEL   if (det && alias && abap.Classes[alias]) {'.
    WRITE '@KERNEL     abap.Classes[sn] = abap.Classes[alias];'.
    WRITE '@KERNEL     abap.Classes[det] = abap.Classes[alias];'.
    WRITE '@KERNEL   }'.
    WRITE '@KERNEL } catch (e) { }'.
  ENDMETHOD.
ENDCLASS.
