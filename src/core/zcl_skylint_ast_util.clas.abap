CLASS zcl_skylint_ast_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_token_lexemes TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLASS-METHODS get_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index        TYPE i
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS get_token_lexeme
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index         TYPE i
      RETURNING VALUE(rv_lexeme) TYPE string.

    CLASS-METHODS get_first_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS get_last_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS get_statement
      IMPORTING it_statements       TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_index            TYPE i
      RETURNING VALUE(rs_statement) TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLASS-METHODS get_next_statement
      IMPORTING it_statements       TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_current_index    TYPE i
      RETURNING VALUE(rs_statement) TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLASS-METHODS get_previous_statement
      IMPORTING it_statements       TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_current_index    TYPE i
      RETURNING VALUE(rs_statement) TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLASS-METHODS find_token
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme            TYPE string
                iv_start_index       TYPE i DEFAULT 1
                iv_ignore_references TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_index)      TYPE i.

    CLASS-METHODS get_token_after
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme       TYPE string
                iv_start_index  TYPE i DEFAULT 1
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS get_token_before
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme       TYPE string
                iv_start_index  TYPE i DEFAULT 1
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS find_token_sequence
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected     TYPE ty_token_lexemes
                iv_start_index  TYPE i DEFAULT 1
      RETURNING VALUE(rv_index) TYPE i.

    CLASS-METHODS get_token_after_sequence
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected     TYPE ty_token_lexemes
                iv_start_index  TYPE i DEFAULT 1
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS match_token_sequence
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i DEFAULT 1
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS matches_token_at
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index          TYPE i
                iv_expected       TYPE string
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS statement_is_method_call
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS statement_is_db_access
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS has_token_lexeme
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS token_is_literal
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS token_is_identifier
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS token_is_inline_declaration
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_prefix     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS token_paren_delta
      IMPORTING is_token        TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_delta) TYPE i.

    CLASS-METHODS is_comparison_operator
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS has_compiler_reference
      IMPORTING is_token       TYPE if_ci_atc_source_code_provider=>ty_token
                iv_kind        TYPE if_ci_atc_source_code_provider=>ty_reference_kind OPTIONAL
                iv_usage_mode  TYPE if_ci_atc_source_code_provider=>ty_usage_mode     OPTIONAL
                iv_usage_grade TYPE if_ci_atc_source_code_provider=>ty_usage_grade    OPTIONAL
      RETURNING VALUE(rv_has)  TYPE abap_bool.

    CLASS-METHODS get_reference
      IMPORTING is_token            TYPE if_ci_atc_source_code_provider=>ty_token
                iv_kind             TYPE if_ci_atc_source_code_provider=>ty_reference_kind OPTIONAL
                iv_usage_mode       TYPE if_ci_atc_source_code_provider=>ty_usage_mode     OPTIONAL
                iv_usage_grade      TYPE if_ci_atc_source_code_provider=>ty_usage_grade    OPTIONAL
      RETURNING VALUE(rs_reference) TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLASS-METHODS statement_has_reference
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_kind        TYPE if_ci_atc_source_code_provider=>ty_reference_kind OPTIONAL
                iv_usage_mode  TYPE if_ci_atc_source_code_provider=>ty_usage_mode     OPTIONAL
                iv_usage_grade TYPE if_ci_atc_source_code_provider=>ty_usage_grade    OPTIONAL
      RETURNING VALUE(rv_has)  TYPE abap_bool.

    CLASS-METHODS statement_get_reference
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_kind             TYPE if_ci_atc_source_code_provider=>ty_reference_kind OPTIONAL
                iv_usage_mode       TYPE if_ci_atc_source_code_provider=>ty_usage_mode     OPTIONAL
                iv_usage_grade      TYPE if_ci_atc_source_code_provider=>ty_usage_grade    OPTIONAL
      RETURNING VALUE(rs_reference) TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLASS-METHODS statement_get_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_kind         TYPE if_ci_atc_source_code_provider=>ty_reference_kind OPTIONAL
                iv_usage_mode   TYPE if_ci_atc_source_code_provider=>ty_usage_mode     OPTIONAL
                iv_usage_grade  TYPE if_ci_atc_source_code_provider=>ty_usage_grade    OPTIONAL
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS token_is_keyword
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_lexeme     TYPE string OPTIONAL
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_abap_keyword
      IMPORTING iv_name      TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    CLASS-METHODS get_declared_type
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name   TYPE if_ci_atc_source_code_provider=>ty_full_name
      RETURNING VALUE(rv_type) TYPE string.

    CLASS-METHODS statement_get_references
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_kind              TYPE if_ci_atc_source_code_provider=>ty_reference_kind OPTIONAL
      RETURNING VALUE(rt_references) TYPE if_ci_atc_source_code_provider=>ty_compiler_references.

    CLASS-METHODS is_write_usage
      IMPORTING is_reference          TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
                iv_include_definition TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_yes)         TYPE abap_bool.

    CLASS-METHODS is_read_usage
      IMPORTING is_reference  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_full_write_usage
      IMPORTING is_reference  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_partial_write_usage
      IMPORTING is_reference  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS reference_matches
      IMPORTING iv_full_name  TYPE string
                iv_reference  TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_data_definition
      IMPORTING is_reference  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS is_data_usage
      IMPORTING is_reference  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS parse_full_name
      IMPORTING iv_full_name    TYPE clike
      EXPORTING ev_program_name TYPE string
                ev_class_name   TYPE string
                ev_meth_name    TYPE string
                ev_data_name    TYPE string.

    CLASS-METHODS get_reference_name
      IMPORTING iv_full_name   TYPE if_ci_atc_source_code_provider=>ty_full_name
      RETURNING VALUE(rv_name) TYPE string.

    CLASS-METHODS match_system_field
      IMPORTING is_token          TYPE if_ci_atc_source_code_provider=>ty_token
                iv_field_name     TYPE string
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    CLASS-METHODS has_data_read_usage
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name  TYPE string
                iv_from_idx   TYPE i DEFAULT 1
                iv_to_idx     TYPE i DEFAULT 0
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS has_data_write_usage
      IMPORTING it_statements         TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name          TYPE string
                iv_from_idx           TYPE i         DEFAULT 1
                iv_to_idx             TYPE i         DEFAULT 0
                iv_include_definition TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_yes)         TYPE abap_bool.

    CLASS-METHODS token_count
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

    CLASS-METHODS statement_count
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rv_count) TYPE i.

    CLASS-METHODS is_declared_data
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_name       TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    TYPES: BEGIN OF ty_token_override,
             index  TYPE i,
             lexeme TYPE string,
           END OF ty_token_override,
           ty_token_overrides TYPE STANDARD TABLE OF ty_token_override WITH EMPTY KEY.
    TYPES ty_token_deletions TYPE STANDARD TABLE OF i WITH EMPTY KEY.

    CLASS-METHODS flatten_statement
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                it_overrides   TYPE ty_token_overrides OPTIONAL
                it_deletions   TYPE ty_token_deletions OPTIONAL
                iv_suffix      TYPE string             OPTIONAL
      RETURNING VALUE(rv_line) TYPE string.

    CLASS-METHODS build_functional_call
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

    CLASS-METHODS strip_outer_parens
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement OPTIONAL
                it_tokens    TYPE if_ci_atc_source_code_provider=>ty_tokens    OPTIONAL
      CHANGING  cv_from      TYPE i
                cv_to        TYPE i.

    CLASS-METHODS extract_name_from_paren
      IMPORTING iv_lexeme      TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    CLASS-METHODS extract_tokens_text
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from_idx    TYPE i
                iv_to_idx      TYPE i
      RETURNING VALUE(rv_text) TYPE string.

    CLASS-METHODS get_declaration_token
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_token) TYPE if_ci_atc_source_code_provider=>ty_token.

    CLASS-METHODS get_declaration_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

    CLASS-METHODS matches_regex
      IMPORTING iv_text           TYPE string
                iv_pattern        TYPE string
                iv_pcre           TYPE abap_bool DEFAULT abap_true
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    TYPES:
      BEGIN OF ty_method_parameter,
        name      TYPE string,
        raw_name  TYPE string,
        section   TYPE string,
        type_kind TYPE string,
        type_name TYPE string,
        token     TYPE if_ci_atc_source_code_provider=>ty_token,
      END OF ty_method_parameter,
      ty_method_parameters TYPE STANDARD TABLE OF ty_method_parameter WITH EMPTY KEY.

    CLASS-METHODS get_method_parameters
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_parameters) TYPE ty_method_parameters.

    CLASS-METHODS statement_checks_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS statement_references_sys_field
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_field_name TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS find_matching_paren
      IMPORTING is_statement          TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_open_index         TYPE i
      RETURNING VALUE(rv_close_index) TYPE i.

    TYPES:
      BEGIN OF ty_inline_declaration,
        name       TYPE string,
        raw_name   TYPE string,
        usage_mode TYPE if_ci_atc_source_code_provider=>ty_usage_mode,
        token      TYPE if_ci_atc_source_code_provider=>ty_token,
      END OF ty_inline_declaration,
      ty_inline_declarations TYPE STANDARD TABLE OF ty_inline_declaration WITH EMPTY KEY.

    CLASS-METHODS get_inline_declarations
      IMPORTING is_statement           TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_declarations) TYPE ty_inline_declarations.

    CLASS-METHODS statement_is_public_class
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS statement_is_public_interface
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS statement_is_exception_class
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    CLASS-METHODS call_has_other_sections
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    CLASS-METHODS procedure_is_interface
      IMPORTING is_procedure      TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is_intf) TYPE abap_bool.

    CLASS-METHODS parse_assignment
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_target        TYPE string
                ev_expr          TYPE string
                ev_is_assignment TYPE abap_bool.

    CLASS-METHODS statement_get_db_target
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_table) TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS normalize_identifier_name
      IMPORTING iv_raw         TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    CLASS-METHODS is_call_clause_keyword
      IMPORTING iv_word      TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_ast_util IMPLEMENTATION.
  METHOD get_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

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
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_lexeme.
    ls_token = get_token( is_statement = is_statement
                          iv_index     = iv_index ).
    IF ls_token-lexeme IS NOT INITIAL.
      rv_lexeme = ls_token-lexeme.
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
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

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
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_index = 0.
    lv_count = lines( is_statement-tokens ).
    IF iv_start_index <= 0 OR iv_start_index > lv_count.
      RETURN.
    ENDIF.

    lv_exp = iv_lexeme.

    lv_idx = iv_start_index.
    WHILE lv_idx <= lv_count.
      ASSIGN is_statement-tokens[ lv_idx ] TO <ls_tok>.
      IF sy-subrc = 0
         AND ( iv_ignore_references = abap_true OR <ls_tok>-references IS INITIAL ).
        lv_act = <ls_tok>-lexeme.
        IF lv_act = lv_exp.
          rv_index = lv_idx.
          RETURN.
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_token_after.
    DATA lv_idx TYPE i.

    CLEAR rs_token.
    lv_idx = find_token( is_statement   = is_statement
                         iv_lexeme      = iv_lexeme
                         iv_start_index = iv_start_index ).
    IF lv_idx > 0.
      rs_token = get_token( is_statement = is_statement
                            iv_index     = lv_idx + 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD get_token_before.
    DATA lv_idx TYPE i.

    CLEAR rs_token.
    lv_idx = find_token( is_statement   = is_statement
                         iv_lexeme      = iv_lexeme
                         iv_start_index = iv_start_index ).
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
    DATA ls_act_token      TYPE if_ci_atc_source_code_provider=>ty_token.
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

        lv_expected = ls_exp_token.
        lv_actual   = ls_act_token-lexeme.

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
    lv_idx = find_token_sequence( is_statement   = is_statement
                                  it_expected    = it_expected
                                  iv_start_index = iv_start_index ).
    IF lv_idx > 0.
      lv_cnt = lines( it_expected ).
      rs_token = get_token( is_statement = is_statement
                            iv_index     = lv_idx + lv_cnt ).
    ENDIF.
  ENDMETHOD.

  METHOD match_token_sequence.
    DATA lv_index TYPE i.

    rv_matched = abap_false.
    lv_index = find_token_sequence( is_statement   = is_statement
                                    it_expected    = it_expected
                                    iv_start_index = iv_start_index ).

    IF lv_index > 0.
      rv_matched = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD matches_token_at.
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.
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

    lv_actual   = ls_token-lexeme.
    lv_expected = iv_expected.

    IF lv_actual = lv_expected.
      rv_matched = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD statement_is_method_call.
    rv_has = abap_false.

    CASE is_statement-keyword.
      WHEN '+CALL_METHOD' OR 'CALL'.
        rv_has = abap_true.
        RETURN.
    ENDCASE.

    rv_has = statement_has_reference( is_statement = is_statement
                                      iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ).
  ENDMETHOD.

  METHOD statement_is_db_access.
    IF statement_get_db_target( is_statement ) IS NOT INITIAL.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF    statement_has_reference( is_statement  = is_statement
                                   iv_usage_mode = if_ci_atc_source_code_provider=>usage_modes-read_database )  = abap_true
       OR statement_has_reference( is_statement  = is_statement
                                   iv_usage_mode = if_ci_atc_source_code_provider=>usage_modes-write_database ) = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF is_statement-keyword = 'SELECT'.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     (    is_statement-keyword = 'READ' OR is_statement-keyword = 'MODIFY' )
       AND (    match_token_sequence( is_statement = is_statement
                                      it_expected  = VALUE #( ( `READ` ) ( `ENTITIES` ) ) )   = abap_true
             OR match_token_sequence( is_statement = is_statement
                                      it_expected  = VALUE #( ( `READ` ) ( `ENTITY` ) ) )     = abap_true
             OR match_token_sequence( is_statement = is_statement
                                      it_expected  = VALUE #( ( `MODIFY` ) ( `ENTITIES` ) ) ) = abap_true
             OR match_token_sequence( is_statement = is_statement
                                      it_expected  = VALUE #( ( `MODIFY` ) ( `ENTITY` ) ) )   = abap_true ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     is_statement-keyword = 'COMMIT'
       AND (    match_token_sequence( is_statement = is_statement
                                      it_expected  = VALUE #( ( `COMMIT` ) ( `ENTITIES` ) ) ) = abap_true
             OR match_token_sequence( is_statement = is_statement
                                      it_expected  = VALUE #( ( `COMMIT` ) ( `ENTITY` ) ) )   = abap_true ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     is_statement-keyword = 'EXEC'
       AND match_token_sequence( is_statement = is_statement
                                 it_expected  = VALUE #( ( `EXEC` ) ( `SQL` ) ) ) = abap_true.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_assignment.
    rv_yes = xsdbool( is_statement-keyword = 'COMPUTE' ).
  ENDMETHOD.

  METHOD has_token_lexeme.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
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
      IF ls_tok-lexeme = iv_lexeme.
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

  METHOD token_is_inline_declaration.
    DATA lv_len TYPE i.
    DATA lv_lex TYPE string.

    CLEAR rv_yes.
    IF is_token-lexeme IS INITIAL OR iv_prefix IS INITIAL.
      RETURN.
    ENDIF.

    lv_lex = to_upper( is_token-lexeme ).
    IF lv_lex(1) = '@'.
      lv_lex = lv_lex+1.
    ENDIF.

    lv_len = strlen( iv_prefix ).
    IF strlen( lv_lex ) <= lv_len.
      RETURN.
    ENDIF.
    IF lv_lex+lv_len(1) <> '('.
      RETURN.
    ENDIF.
    rv_yes = xsdbool( lv_lex(lv_len) = to_upper( iv_prefix ) ).
  ENDMETHOD.

  METHOD token_paren_delta.
    DATA lv_off   TYPE i.
    DATA lv_len   TYPE i.
    DATA lv_first TYPE string.
    DATA lv_ch    TYPE string.

    rv_delta = 0.
    IF is_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_first = is_token-lexeme(1).
    IF lv_first = `'` OR lv_first = '`' OR lv_first = '|'.
      RETURN.
    ENDIF.

    lv_len = strlen( is_token-lexeme ).
    lv_off = 0.
    WHILE lv_off < lv_len.
      lv_ch = is_token-lexeme+lv_off(1).
      CASE lv_ch.
        WHEN '(' OR '[' OR '{'.
          rv_delta += 1.
        WHEN ')' OR ']' OR '}'.
          rv_delta -= 1.
      ENDCASE.
      lv_off += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_comparison_operator.
    DATA lv_op TYPE string.

    lv_op =  iv_lexeme.
    rv_yes = xsdbool(    lv_op = '='  OR lv_op = '<>' OR lv_op = '<'  OR lv_op = '>'
                      OR lv_op = '<=' OR lv_op = '>=' OR lv_op = 'EQ' OR lv_op = 'NE'
                      OR lv_op = 'LT' OR lv_op = 'GT' OR lv_op = 'LE' OR lv_op = 'GE'
                      OR lv_op = 'CS' OR lv_op = 'CP' OR lv_op = 'NS' OR lv_op = 'NP'
                      OR lv_op = 'CO' OR lv_op = 'CN' OR lv_op = 'CA' OR lv_op = 'NA' ).
  ENDMETHOD.

  METHOD has_compiler_reference.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_has = abap_false.
    LOOP AT is_token-references ASSIGNING <ls_ref>.
      IF iv_kind IS NOT INITIAL AND <ls_ref>-kind <> iv_kind.
        CONTINUE.
      ENDIF.
      IF iv_usage_mode IS NOT INITIAL AND <ls_ref>-usage_mode <> iv_usage_mode.
        CONTINUE.
      ENDIF.
      IF iv_usage_grade IS NOT INITIAL AND <ls_ref>-usage_grade <> iv_usage_grade.
        CONTINUE.
      ENDIF.
      rv_has = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_reference.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rs_reference.
    LOOP AT is_token-references ASSIGNING <ls_ref>.
      IF iv_kind IS NOT INITIAL AND <ls_ref>-kind <> iv_kind.
        CONTINUE.
      ENDIF.
      IF iv_usage_mode IS NOT INITIAL AND <ls_ref>-usage_mode <> iv_usage_mode.
        CONTINUE.
      ENDIF.
      IF iv_usage_grade IS NOT INITIAL AND <ls_ref>-usage_grade <> iv_usage_grade.
        CONTINUE.
      ENDIF.
      rs_reference = <ls_ref>.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_has_reference.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF has_compiler_reference( is_token       = <ls_token>
                                 iv_kind        = iv_kind
                                 iv_usage_mode  = iv_usage_mode
                                 iv_usage_grade = iv_usage_grade ) = abap_true.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_get_reference.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_reference.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      rs_reference = get_reference( is_token       = <ls_token>
                                    iv_kind        = iv_kind
                                    iv_usage_mode  = iv_usage_mode
                                    iv_usage_grade = iv_usage_grade ).
      IF rs_reference IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_get_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_token.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF has_compiler_reference( is_token       = <ls_token>
                                 iv_kind        = iv_kind
                                 iv_usage_mode  = iv_usage_mode
                                 iv_usage_grade = iv_usage_grade ) = abap_true.
        rs_token = <ls_token>.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD token_is_keyword.
    rv_yes = abap_false.
    IF is_token-references IS NOT INITIAL.
      RETURN.
    ENDIF.
    IF iv_lexeme IS INITIAL.
      rv_yes = abap_true.
    ELSEIF to_upper( is_token-lexeme ) = to_upper( iv_lexeme ).
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_abap_keyword.
    DATA lv_clean TYPE string.

    rv_is = abap_false.
    lv_clean = to_upper( condense( iv_name ) ).

    CASE lv_clean.
      WHEN 'CLASS' OR 'METHOD' OR 'TYPE' OR 'DATA' OR 'TABLE' OR 'SELECT' OR 'UPDATE'
        OR 'INSERT' OR 'DELETE' OR 'MODIFY' OR 'CHECK' OR 'CLEAR' OR 'LOOP' OR 'IF'
        OR 'CASE' OR 'WHEN' OR 'DO' OR 'WHILE' OR 'RETURN' OR 'EXIT' OR 'CONTINUE'
        OR 'TRY' OR 'CATCH' OR 'CLEANUP' OR 'RAISE' OR 'PERFORM' OR 'FORM' OR 'CALL'
        OR 'ASSIGN' OR 'CONSTANTS' OR 'STATICS' OR 'INTERFACE' OR 'FUNCTION' OR 'READ'
        OR 'WRITE' OR 'APPEND' OR 'SORT' OR 'SPLIT' OR 'CONCATENATE' OR 'REPLACE'
        OR 'TRANSLATE' OR 'CONDENSE' OR 'COLLECT' OR 'DESCRIBE' OR 'FIND' OR 'COMMIT'
        OR 'ROLLBACK' OR 'KEY' OR 'DEFAULT' OR 'VALUE' OR 'RESULT' OR 'IMPORTING'
        OR 'EXPORTING' OR 'CHANGING' OR 'RETURNING' OR 'RAISING' OR 'EXCEPTIONS'
        OR 'TABLES' OR 'LIKE' OR 'REF'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.

  METHOD get_declared_type.
    DATA lv_name TYPE string.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_stmt>      TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_other_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_type.
    lv_name = get_reference_name( iv_full_name ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'DATA'.
        CONTINUE.
      ENDIF.
      IF has_token_lexeme( is_statement = <ls_stmt>
                           iv_lexeme    = lv_name ) = abap_false.
        CONTINUE.
      ENDIF.
      LOOP AT <ls_stmt>-tokens INTO ls_tok.
        IF NOT line_exists( ls_tok-references[ kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                                               full_name = iv_full_name ] ).
          CONTINUE.
        ENDIF.

        LOOP AT ls_tok-references ASSIGNING <ls_ref>
             WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
          rv_type = <ls_ref>-full_name.
          RETURN.
        ENDLOOP.

        LOOP AT <ls_stmt>-tokens ASSIGNING <ls_other_tok>.
          LOOP AT <ls_other_tok>-references ASSIGNING <ls_ref>
               WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
            rv_type = <ls_ref>-full_name.
            RETURN.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_get_references.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF iv_kind IS NOT INITIAL AND <ls_ref>-kind <> iv_kind.
          CONTINUE.
        ENDIF.
        APPEND <ls_ref> TO rt_references.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_write_usage.
    CASE is_reference-usage_mode.
      WHEN if_ci_atc_source_code_provider=>usage_modes-write
        OR if_ci_atc_source_code_provider=>usage_modes-write_partial
        OR if_ci_atc_source_code_provider=>usage_modes-read_and_write
        OR if_ci_atc_source_code_provider=>usage_modes-write_reference
        OR if_ci_atc_source_code_provider=>usage_modes-read_and_write_reference
        OR if_ci_atc_source_code_provider=>usage_modes-any_access_reference
        OR if_ci_atc_source_code_provider=>usage_modes-write_database.
        rv_yes = abap_true.
      WHEN if_ci_atc_source_code_provider=>usage_modes-definition_with_write
        OR if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
        IF iv_include_definition = abap_true.
          rv_yes = abap_true.
        ENDIF.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_read_usage.
    CASE is_reference-usage_mode.
      WHEN if_ci_atc_source_code_provider=>usage_modes-read
        OR if_ci_atc_source_code_provider=>usage_modes-read_and_write
        OR if_ci_atc_source_code_provider=>usage_modes-read_reference
        OR if_ci_atc_source_code_provider=>usage_modes-read_and_write_reference
        OR if_ci_atc_source_code_provider=>usage_modes-any_access_reference
        OR if_ci_atc_source_code_provider=>usage_modes-read_database.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_full_write_usage.
    CASE is_reference-usage_mode.
      WHEN if_ci_atc_source_code_provider=>usage_modes-write
        OR if_ci_atc_source_code_provider=>usage_modes-read_and_write.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_partial_write_usage.
    rv_yes = xsdbool( is_reference-usage_mode = if_ci_atc_source_code_provider=>usage_modes-write_partial ).
  ENDMETHOD.

  METHOD reference_matches.
    DATA lv_length    TYPE i.
    DATA lv_prefix    TYPE string.
    DATA lv_separator TYPE string.

    rv_yes = abap_false.

    IF iv_full_name IS INITIAL OR iv_reference IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_reference = iv_full_name.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    " A reference to a component carries the name of its structure as prefix
    lv_length = strlen( iv_full_name ).
    IF strlen( iv_reference ) <= lv_length.
      RETURN.
    ENDIF.

    lv_prefix = substring( val = iv_reference
                           len = lv_length ).
    lv_separator = substring( val = iv_reference
                              off = lv_length
                              len = 1 ).
    rv_yes = xsdbool( lv_prefix = iv_full_name AND lv_separator = `\` ).
  ENDMETHOD.

  METHOD is_data_definition.
    rv_yes = xsdbool(
          is_reference-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
      AND (    is_reference-usage_grade = if_ci_atc_source_code_provider=>usage_grades-definition
            OR is_reference-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-definition
            OR is_reference-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
            OR is_reference-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign ) ).
  ENDMETHOD.

  METHOD is_data_usage.
    rv_yes = xsdbool(
          is_reference-kind                  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
      AND is_data_definition( is_reference ) = abap_false ).
  ENDMETHOD.

  METHOD parse_full_name.
    DATA lv_str   TYPE string.
    DATA lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_part  TYPE string.

    CLEAR: ev_program_name,
           ev_class_name,
           ev_meth_name,
           ev_data_name.
    lv_str = iv_full_name.

    IF lv_str CS '=>'.
      SPLIT lv_str AT '=>' INTO ev_class_name ev_meth_name.
      IF ev_meth_name CS '('.
        SPLIT ev_meth_name AT '(' INTO ev_meth_name lv_str.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_str NS '\'.
      RETURN.
    ENDIF.

    SPLIT lv_str AT '\' INTO TABLE lt_parts.
    LOOP AT lt_parts INTO lv_part.
      IF lv_part CP 'PR:*'.
        ev_program_name = lv_part+3.
      ELSEIF lv_part CP 'PROGRAM=*'.
        ev_program_name = lv_part+8.
      ELSEIF lv_part CP 'TY:*'.
        ev_class_name = lv_part+3.
      ELSEIF lv_part CP 'CLASS=*'.
        ev_class_name = lv_part+6.
      ELSEIF lv_part CP 'INTF=*'.
        ev_class_name = lv_part+5.
      ELSEIF lv_part CP 'ME:*'.
        ev_meth_name = lv_part+3.
      ELSEIF lv_part CP 'DA:*' OR lv_part CP 'DA=*'.
        ev_data_name = lv_part+3.
      ELSEIF lv_part CP 'DB:*' OR lv_part CP 'DB=*'.
        ev_data_name = lv_part+3.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD match_system_field.
    DATA lv_target TYPE string.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_matched = abap_false.
    lv_target  = to_upper( iv_field_name ).

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      IF    <ls_ref>-full_name = |\\DA:SY\\DA:{ lv_target }|
         OR <ls_ref>-full_name = |\\DA:SYST\\DA:{ lv_target }|
         OR <ls_ref>-full_name = |\\DA=SY\\DA={ lv_target }|
         OR <ls_ref>-full_name = |\\DA=SYST\\DA={ lv_target }|.
        rv_matched = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_reference_name.
    DATA lv_parsed_name TYPE string.
    DATA lv_off         TYPE i.
    DATA lv_len         TYPE i.

    CLEAR rv_name.
    parse_full_name( EXPORTING iv_full_name = iv_full_name
                     IMPORTING ev_data_name = lv_parsed_name ).
    IF lv_parsed_name IS NOT INITIAL.
      rv_name = lv_parsed_name.
      RETURN.
    ENDIF.

    rv_name = condense( iv_full_name ).
    IF rv_name IS INITIAL.
      RETURN.
    ENDIF.

    lv_off = 0.
    lv_len = strlen( rv_name ) - 3.
    WHILE lv_off <= lv_len.
      IF rv_name+lv_off(3) = 'DA:'.
        lv_off += 3.
        rv_name = rv_name+lv_off.
        RETURN.
      ENDIF.
      lv_off += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD has_data_read_usage.
    DATA lv_idx TYPE i.
    DATA lv_to  TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.
    IF iv_to_idx <= 0.
      lv_to = lines( it_statements ).
    ELSE.
      lv_to = iv_to_idx.
    ENDIF.
    IF iv_from_idx <= 0.
      lv_idx = 1.
    ELSE.
      lv_idx = iv_from_idx.
    ENDIF.

    WHILE lv_idx <= lv_to.
      ASSIGN it_statements[ lv_idx ] TO <ls_stmt>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        LOOP AT <ls_tok>-references ASSIGNING <ls_ref>
             WHERE     kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                   AND ( full_name = iv_full_name OR full_name CP |{ iv_full_name }\\*| ).
          IF is_read_usage( <ls_ref> ) = abap_true.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD has_data_write_usage.
    DATA lv_idx TYPE i.
    DATA lv_to  TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.
    IF iv_to_idx <= 0.
      lv_to = lines( it_statements ).
    ELSE.
      lv_to = iv_to_idx.
    ENDIF.
    IF iv_from_idx <= 0.
      lv_idx = 1.
    ELSE.
      lv_idx = iv_from_idx.
    ENDIF.

    WHILE lv_idx <= lv_to.
      ASSIGN it_statements[ lv_idx ] TO <ls_stmt>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        LOOP AT <ls_tok>-references ASSIGNING <ls_ref>
             WHERE     kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                   AND ( full_name = iv_full_name OR full_name CP |{ iv_full_name }\\*| ).
          IF is_write_usage( is_reference          = <ls_ref>
                             iv_include_definition = iv_include_definition ) = abap_true.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      lv_idx += 1.
    ENDWHILE.
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
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.
    lv_name = normalize_identifier_name( iv_name ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.
    lv_suffix = |DA:{ lv_name }|.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
          IF is_data_definition( <ls_ref> ) = abap_true.
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
    rv_name = extract_name_from_paren( iv_raw ).
  ENDMETHOD.

  METHOD flatten_statement.
    DATA lv_idx      TYPE i.
    DATA lv_lexeme   TYPE string.
    DATA lv_orig_gap TYPE i.
    DATA lv_prev_end TYPE i.
    FIELD-SYMBOLS <ls_token>    TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_override> TYPE ty_token_override.

    CLEAR rv_line.
    lv_prev_end = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_idx = sy-tabix.
      lv_orig_gap = <ls_token>-position-column - lv_prev_end.
      IF lv_orig_gap < 0.
        lv_orig_gap = 0.
      ENDIF.
      lv_prev_end = <ls_token>-position-column + strlen( <ls_token>-lexeme ).

      IF line_exists( it_deletions[ table_line = lv_idx ] ).
        CONTINUE.
      ENDIF.

      lv_lexeme = <ls_token>-lexeme.
      ASSIGN it_overrides[ index = lv_idx ] TO <ls_override>.
      IF sy-subrc = 0.
        lv_lexeme = <ls_override>-lexeme.
      ENDIF.

      IF rv_line IS INITIAL.
        rv_line = repeat( val = ` `
                          occ = lv_orig_gap ).
      ELSEIF lv_orig_gap > 0.
        rv_line = rv_line && repeat( val = ` `
                                     occ = lv_orig_gap ).
      ELSE.
        rv_line = |{ rv_line } |.
      ENDIF.
      rv_line = rv_line && lv_lexeme.
    ENDLOOP.

    rv_line = rv_line && iv_suffix.
  ENDMETHOD.

  METHOD build_functional_call.
    DATA lv_count  TYPE i.
    DATA lv_idx    TYPE i.
    DATA lv_design TYPE string.
    DATA lv_lhs    TYPE string.
    DATA lv_token  TYPE string.
    DATA lv_name   TYPE string.
    DATA lv_value  TYPE string.
    DATA lv_args   TYPE string.
    DATA lv_first  TYPE abap_bool.

    CLEAR rv_line.

    IF find_token_sequence( is_statement = is_statement
                            it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) <> 1.
      RETURN.
    ENDIF.

    lv_design = get_token_lexeme( is_statement = is_statement
                                  iv_index     = 3 ).
    IF lv_design IS INITIAL.
      RETURN.
    ENDIF.

    IF lv_design CS '('.
      rv_line = condense( flatten_statement( is_statement = is_statement
                                             it_deletions = VALUE #( ( 1 ) ( 2 ) )
                                             iv_suffix    = '.' ) ).
      RETURN.
    ENDIF.

    lv_count = token_count( is_statement ).
    lv_first = abap_true.
    lv_idx = 4.
    WHILE lv_idx <= lv_count.
      lv_token = get_token_lexeme( is_statement = is_statement
                                   iv_index     = lv_idx ).
      CASE lv_token.
        WHEN 'EXPORTING'.
          lv_idx += 1.
          WHILE     lv_idx + 2 <= lv_count
                AND is_call_clause_keyword( get_token_lexeme( is_statement = is_statement
                                                              iv_index     = lv_idx ) )    = abap_false
                AND get_token_lexeme( is_statement = is_statement
                                      iv_index     = lv_idx + 1 ) = '='.
            lv_name = get_token_lexeme( is_statement = is_statement
                                        iv_index     = lv_idx ).
            lv_value = get_token_lexeme( is_statement = is_statement
                                         iv_index     = lv_idx + 2 ).
            IF    lv_value IS INITIAL
               OR is_call_clause_keyword( lv_value )  = abap_true.
              RETURN.
            ENDIF.
            IF lv_first = abap_true.
              lv_first = abap_false.
            ELSE.
              lv_args = |{ lv_args } |.
            ENDIF.
            lv_args = |{ lv_args }{ lv_name } = { lv_value }|.
            lv_idx += 3.
          ENDWHILE.
          IF     lv_idx <= lv_count
             AND is_call_clause_keyword( get_token_lexeme( is_statement = is_statement
                                                           iv_index     = lv_idx ) )    = abap_false.
            RETURN.
          ENDIF.
        WHEN 'RECEIVING'.
          IF lv_lhs IS NOT INITIAL.
            RETURN.
          ENDIF.
          lv_name = get_token_lexeme( is_statement = is_statement
                                      iv_index     = lv_idx + 1 ).
          IF    lv_name IS INITIAL
             OR is_call_clause_keyword( lv_name )              = abap_true
             OR get_token_lexeme( is_statement = is_statement
                                  iv_index     = lv_idx + 2 ) <> '='.
            RETURN.
          ENDIF.
          lv_lhs = get_token_lexeme( is_statement = is_statement
                                     iv_index     = lv_idx + 3 ).
          IF lv_lhs IS INITIAL.
            RETURN.
          ENDIF.
          lv_idx += 4.
        WHEN 'IMPORTING' OR 'EXCEPTIONS' OR 'EXCEPTION-TABLE'.
          RETURN.
        WHEN OTHERS.
          RETURN.
      ENDCASE.
    ENDWHILE.

    IF lv_args IS INITIAL.
      lv_args = `( )`.
    ELSE.
      lv_args = |( { lv_args } )|.
    ENDIF.
    IF lv_lhs IS INITIAL.
      rv_line = |{ lv_design }{ lv_args }.|.
    ELSE.
      rv_line = |{ lv_lhs } = { lv_design }{ lv_args }.|.
    ENDIF.
  ENDMETHOD.

  METHOD is_call_clause_keyword.
    rv_is = abap_false.
    CASE iv_word.
      WHEN 'EXPORTING' OR 'IMPORTING' OR 'RECEIVING' OR 'EXCEPTIONS' OR 'EXCEPTION-TABLE'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.

  METHOD strip_outer_parens.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <lt_tokens> TYPE if_ci_atc_source_code_provider=>ty_tokens.
    FIELD-SYMBOLS <ls_open>   TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_close>  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok>    TYPE if_ci_atc_source_code_provider=>ty_token.

    IF it_tokens IS SUPPLIED.
      ASSIGN it_tokens TO <lt_tokens>.
    ELSEIF is_statement IS SUPPLIED.
      ASSIGN is_statement-tokens TO <lt_tokens>.
    ELSE.
      RETURN.
    ENDIF.

    WHILE cv_from < cv_to.
      ASSIGN <lt_tokens>[ cv_from ] TO <ls_open>.
      IF sy-subrc <> 0 OR <ls_open>-lexeme <> '(' OR <ls_open>-references IS NOT INITIAL.
        EXIT.
      ENDIF.

      ASSIGN <lt_tokens>[ cv_to ] TO <ls_close>.
      IF sy-subrc <> 0 OR <ls_close>-lexeme <> ')' OR <ls_close>-references IS NOT INITIAL.
        EXIT.
      ENDIF.

      lv_depth = 0.
      LOOP AT <lt_tokens> FROM cv_from TO cv_to - 1 ASSIGNING <ls_tok>.
        lv_depth += token_paren_delta( <ls_tok> ).
        IF lv_depth = 0.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_depth = 1.
        cv_from += 1.
        cv_to   -= 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD extract_name_from_paren.
    rv_name = translate( val  = iv_lexeme
                         from = '@!'
                         to   = '  ' ).
    IF find( val = rv_name
             sub = '(' ) > 0.
      rv_name = segment( val   = rv_name
                         index = 2
                         sep   = '(' ).
    ENDIF.
    IF find( val = rv_name
             sub = ')' ) > 0.
      rv_name = segment( val   = rv_name
                         index = 1
                         sep   = ')' ).
    ENDIF.
    rv_name = condense( rv_name ).
  ENDMETHOD.

  METHOD extract_tokens_text.
    DATA lv_curr_idx TYPE i.
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lt_parts    TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLEAR rv_text.
    lv_curr_idx = iv_from_idx.

    WHILE lv_curr_idx <= iv_to_idx.
      ls_token = get_token( is_statement = is_statement
                            iv_index     = lv_curr_idx ).
      IF ls_token-lexeme IS NOT INITIAL.
        APPEND ls_token-lexeme TO lt_parts.
      ENDIF.
      lv_curr_idx += 1.
    ENDWHILE.

    rv_text = concat_lines_of( table = lt_parts
                               sep   = ` ` ).
  ENDMETHOD.

  METHOD get_declaration_token.
    CLEAR rs_token.

    IF find_token_sequence( is_statement = is_statement
                            it_expected  = VALUE #( ( `BEGIN` ) ( `OF` ) ) ) > 0.
      rs_token = get_token_after( is_statement = is_statement
                                  iv_lexeme    = 'OF' ).
    ELSEIF find_token_sequence( is_statement = is_statement
                                it_expected  = VALUE #( ( `END` ) ( `OF` ) ) ) > 0.
      RETURN.
    ELSE.
      rs_token = get_token_after( is_statement = is_statement
                                  iv_lexeme    = is_statement-keyword ).
    ENDIF.
  ENDMETHOD.

  METHOD get_declaration_name.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = get_declaration_token( is_statement ).
    rv_name = ls_tok-lexeme.
  ENDMETHOD.

  METHOD matches_regex.
    DATA lv_val TYPE string.
    DATA lv_pat TYPE string.

    IF iv_pattern IS INITIAL.
      rv_matches = abap_true.
      RETURN.
    ENDIF.

    lv_val = iv_text.
    lv_pat = iv_pattern.

    TRY.
        IF iv_pcre = abap_true.
          rv_matches = xsdbool( matches( val  = lv_val
                                         pcre = lv_pat ) ).
        ELSE.
          rv_matches = xsdbool( contains( val   = lv_val
                                          regex = lv_pat ) ).
        ENDIF.
      CATCH cx_root.
        rv_matches = abap_true.
    ENDTRY.
  ENDMETHOD.

  METHOD get_method_parameters.
    DATA lv_section  TYPE string.
    DATA ls_prev_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_type_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_tabix    TYPE i.
    DATA lv_name     TYPE string.

    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rt_parameters.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_tabix = sy-tabix.

      IF <ls_tok>-references IS NOT INITIAL.
        ls_prev_tok = <ls_tok>.
        CONTINUE.
      ENDIF.

      CASE <ls_tok>-lexeme.
        WHEN 'IMPORTING' OR 'EXPORTING' OR 'CHANGING' OR 'RETURNING'.
          lv_section = <ls_tok>-lexeme.

        WHEN 'RAISING' OR 'EXCEPTIONS' OR 'FOR' OR 'REDEFINITION' OR 'ABSTRACT' OR 'FINAL'.
          CLEAR lv_section.

        WHEN 'TYPE' OR 'LIKE'.
          IF lv_section IS NOT INITIAL AND ls_prev_tok-lexeme IS NOT INITIAL.
            lv_name     = extract_name_from_paren( ls_prev_tok-lexeme ).
            ls_type_tok = get_token( is_statement = is_statement
                                     iv_index     = lv_tabix + 1 ).

            APPEND VALUE #( name      = lv_name
                            raw_name  = ls_prev_tok-lexeme
                            section   = lv_section
                            type_kind = <ls_tok>-lexeme
                            type_name = ls_type_tok-lexeme
                            token     = ls_prev_tok ) TO rt_parameters.
          ENDIF.
      ENDCASE.

      ls_prev_tok = <ls_tok>.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_references_sys_field.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF match_system_field( is_token      = <ls_token>
                             iv_field_name = iv_field_name ) = abap_true.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_checks_sy_subrc.
    rv_yes = statement_references_sys_field( is_statement  = is_statement
                                             iv_field_name = 'SUBRC' ).
  ENDMETHOD.

  METHOD find_matching_paren.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_depth TYPE i.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_close_index = 0.
    lv_count = token_count( is_statement ).
    IF iv_open_index <= 0 OR iv_open_index > lv_count.
      RETURN.
    ENDIF.

    lv_depth = 0.
    lv_idx   = iv_open_index.

    WHILE lv_idx <= lv_count.
      ls_tok = get_token( is_statement = is_statement
                          iv_index     = lv_idx ).
      lv_depth += token_paren_delta( ls_tok ).
      IF lv_depth = 0 AND lv_idx > iv_open_index.
        rv_close_index = lv_idx.
        RETURN.
      ENDIF.
      IF lv_depth < 0.
        RETURN.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_inline_declarations.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rt_declarations.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          CONTINUE.
        ENDIF.

        IF    <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
           OR <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
          APPEND VALUE #( name       = extract_name_from_paren( <ls_token>-lexeme )
                          raw_name   = <ls_token>-lexeme
                          usage_mode = <ls_ref>-usage_mode
                          token      = <ls_token> ) TO rt_declarations.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_is_public_class.
    DATA lv_prev TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-references IS INITIAL.
        IF <ls_tok>-lexeme = 'PUBLIC' AND lv_prev <> 'CREATE'.
          rv_yes = abap_true.
          RETURN.
        ENDIF.
        lv_prev = <ls_tok>-lexeme.
      ELSE.
        CLEAR lv_prev.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_is_public_interface.
    rv_yes = xsdbool( find_token( is_statement = is_statement
                                  iv_lexeme    = 'PUBLIC' ) > 0 ).
  ENDMETHOD.

  METHOD statement_is_exception_class.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    IF find_token_sequence( is_statement = is_statement
                            it_expected  = VALUE #( ( `INHERITING` ) ( `FROM` ) ) ) > 0.
      ls_tok = get_token_after( is_statement = is_statement
                                iv_lexeme    = 'FROM' ).
      IF ls_tok-lexeme CP 'CX_*'.
        rv_yes = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD call_has_other_sections.
    rv_has = abap_false.
    IF    has_token_lexeme( is_statement = is_statement
                            iv_lexeme    = 'IMPORTING' )  = abap_true
       OR has_token_lexeme( is_statement = is_statement
                            iv_lexeme    = 'CHANGING' )   = abap_true
       OR has_token_lexeme( is_statement = is_statement
                            iv_lexeme    = 'RECEIVING' )  = abap_true
       OR has_token_lexeme( is_statement = is_statement
                            iv_lexeme    = 'RETURNING' )  = abap_true
       OR has_token_lexeme( is_statement = is_statement
                            iv_lexeme    = 'EXCEPTIONS' ) = abap_true.
      rv_has = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD procedure_is_interface.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-interface.
      rv_is_intf = abap_true.
      RETURN.
    ENDIF.

    ls_first_stmt = get_statement( it_statements = is_procedure-statements
                                   iv_index      = 1 ).
    rv_is_intf = xsdbool( ls_first_stmt-keyword = 'INTERFACE' ).
  ENDMETHOD.

  METHOD parse_assignment.
    DATA lv_tok_count   TYPE i.
    DATA lv_paren_depth TYPE i.
    DATA lv_eq_idx      TYPE i.
    DATA lv_idx         TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR: ev_target,
           ev_expr,
           ev_is_assignment.

    IF is_statement-keyword <> 'COMPUTE'.
      RETURN.
    ENDIF.

    lv_tok_count = lines( is_statement-tokens ).
    IF lv_tok_count < 3.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_idx = sy-tabix.
      lv_paren_depth += token_paren_delta( <ls_token> ).
      IF lv_paren_depth = 0 AND <ls_token>-lexeme = '='.
        lv_eq_idx = lv_idx.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_eq_idx < 2 OR lv_eq_idx >= lv_tok_count.
      RETURN.
    ENDIF.

    ev_target = extract_tokens_text( is_statement = is_statement
                                     iv_from_idx  = 1
                                     iv_to_idx    = lv_eq_idx - 1 ).
    ev_expr   = extract_tokens_text( is_statement = is_statement
                                     iv_from_idx  = lv_eq_idx + 1
                                     iv_to_idx    = lv_tok_count ).
    ev_is_assignment = abap_true.
  ENDMETHOD.

  METHOD statement_get_db_target.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_idx TYPE i.

    CLEAR rv_table.

    CASE is_statement-keyword.
      WHEN 'SELECT'.
        lv_idx = find_token( is_statement = is_statement
                             iv_lexeme    = 'FROM' ).
        IF lv_idx > 0.
          ls_tok = get_token( is_statement = is_statement
                              iv_index     = lv_idx + 1 ).
        ENDIF.

      WHEN 'DELETE'.
        IF match_token_sequence( is_statement = is_statement
                                 it_expected  = VALUE #( ( `DELETE` ) ( `FROM` ) ) ) = abap_true.
          ls_tok = get_token( is_statement = is_statement
                              iv_index     = 3 ).
        ELSE.
          ls_tok = get_token( is_statement = is_statement
                              iv_index     = 2 ).
        ENDIF.

      WHEN 'UPDATE'.
        ls_tok = get_token( is_statement = is_statement
                            iv_index     = 2 ).

      WHEN 'INSERT'.
        IF match_token_sequence( is_statement = is_statement
                                 it_expected  = VALUE #( ( `INSERT` ) ( `INTO` ) ) ) = abap_true.
          IF get_token_lexeme( is_statement = is_statement
                               iv_index     = 3 ) <> 'TABLE'.
            ls_tok = get_token( is_statement = is_statement
                                iv_index     = 3 ).
          ENDIF.
        ELSE.
          ls_tok = get_token( is_statement = is_statement
                              iv_index     = 2 ).
        ENDIF.

      WHEN 'MODIFY'.
        IF     has_token_lexeme( is_statement = is_statement
                                 iv_lexeme    = 'INDEX' )         = abap_false
           AND has_token_lexeme( is_statement = is_statement
                                 iv_lexeme    = 'TRANSPORTING' )  = abap_false
           AND get_token_lexeme( is_statement = is_statement
                                 iv_index     = 2 )              <> 'TABLE'
           AND get_token_lexeme( is_statement = is_statement
                                 iv_index     = 2 )              <> 'ENTITIES'
           AND get_token_lexeme( is_statement = is_statement
                                 iv_index     = 2 )              <> 'ENTITY'.
          ls_tok = get_token( is_statement = is_statement
                              iv_index     = 2 ).
        ENDIF.
    ENDCASE.

    IF ls_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme(1) = '(' OR ls_tok-lexeme(1) = '@'.
      rv_table = ls_tok-lexeme.
      RETURN.
    ENDIF.

    ls_ref = get_reference( ls_tok ).
    IF ls_ref-full_name CP '\DB:*'.
      rv_table = substring( val = ls_ref-full_name
                            off = 4 ).
      RETURN.
    ELSEIF     ls_ref-kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-type
           AND ls_ref-full_name CP '\TY:*'
           AND ls_ref-full_name NP '\TY:*\TY:*'.
      rv_table = substring( val = ls_ref-full_name
                            off = 4 ).
      RETURN.
    ELSEIF ls_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      IF is_statement-keyword = 'MODIFY' OR is_statement-keyword = 'DELETE' OR is_statement-keyword = 'INSERT'.
        RETURN.
      ENDIF.
    ENDIF.

    rv_table = ls_tok-lexeme.
  ENDMETHOD.
ENDCLASS.
