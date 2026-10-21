CLASS zcl_skylint_downport_compat DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        downport_incompatible TYPE if_ci_atc_check=>ty_finding_code VALUE 'DOWNPORT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DOWNPORT_COMPAT'.

    DATA mv_check_constructors TYPE abap_bool VALUE abap_false.
    DATA mv_check_table_expr   TYPE abap_bool VALUE abap_false.
    DATA mv_check_inline_decl  TYPE abap_bool VALUE abap_false.
    DATA mv_check_string_templ TYPE abap_bool VALUE abap_false.
    DATA mv_check_chaining     TYPE abap_bool VALUE abap_false.
    DATA mv_check_empty_key    TYPE abap_bool VALUE abap_false.
    DATA mv_check_calc_assign  TYPE abap_bool VALUE abap_false.
    DATA mv_check_line_funcs   TYPE abap_bool VALUE abap_false.
    DATA mv_check_strict_sql   TYPE abap_bool VALUE abap_false.
    DATA mv_check_raise_msg    TYPE abap_bool VALUE abap_false.

    METHODS inspect_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS has_constructor_expr
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_table_expression
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_inline_declaration
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_string_template
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_method_chaining
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_empty_key
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_calc_assign
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_line_funcs
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_strict_sql
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_raise_message
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_downport_compat IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Detect 7.40+ syntax incompatible with downport targets'
            remote_enablement = abap_true
            finding_codes     = VALUE #( ( code           = c_finding_codes-downport_incompatible
                                           severity       = if_ci_atc_check=>finding_severities-warning
                                           text           = 'Modern ABAP construct is incompatible with downport target release'
                                           pseudo_comment = c_pseudo_comment ) )
            attributes        = VALUE #(
                kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                ( name  = 'CHECK_CONSTRUCTORS'
                  value = REF #( mv_check_constructors ) )
                ( name  = 'CHECK_TABLE_EXPR'
                  value = REF #( mv_check_table_expr ) )
                ( name  = 'CHECK_INLINE_DECL'
                  value = REF #( mv_check_inline_decl ) )
                ( name  = 'CHECK_STRING_TEMPL'
                  value = REF #( mv_check_string_templ ) )
                ( name  = 'CHECK_CHAINING'
                  value = REF #( mv_check_chaining ) )
                ( name  = 'CHECK_EMPTY_KEY'
                  value = REF #( mv_check_empty_key ) )
                ( name  = 'CHECK_CALC_ASSIGN'
                  value = REF #( mv_check_calc_assign ) )
                ( name  = 'CHECK_LINE_FUNCS'
                  value = REF #( mv_check_line_funcs ) )
                ( name  = 'CHECK_STRICT_SQL'
                  value = REF #( mv_check_strict_sql ) )
                ( name  = 'CHECK_RAISE_MESSAGE'
                  value = REF #( mv_check_raise_msg ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    " If all checks are disabled (default), return immediately
    IF     mv_check_constructors = abap_false
       AND mv_check_table_expr   = abap_false
       AND mv_check_inline_decl  = abap_false
       AND mv_check_string_templ = abap_false
       AND mv_check_chaining     = abap_false
       AND mv_check_empty_key    = abap_false
       AND mv_check_calc_assign  = abap_false
       AND mv_check_line_funcs   = abap_false
       AND mv_check_strict_sql   = abap_false
       AND mv_check_raise_msg    = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      inspect_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_statement.
    IF mv_check_constructors = abap_true AND has_constructor_expr( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_table_expr = abap_true AND has_table_expression( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_inline_decl = abap_true AND has_inline_declaration( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_string_templ = abap_true AND has_string_template( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_chaining = abap_true AND has_method_chaining( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_empty_key = abap_true AND has_empty_key( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_calc_assign = abap_true AND has_calc_assign( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_line_funcs = abap_true AND has_line_funcs( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_strict_sql = abap_true AND has_strict_sql( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
      RETURN.
    ENDIF.

    IF mv_check_raise_msg = abap_true AND has_raise_message( is_statement ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-downport_incompatible ).
    ENDIF.
  ENDMETHOD.

  METHOD has_constructor_expr.
    DATA lv_lex  TYPE string.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      " Keyword check: must have empty references so user variables with the same name are ignored
      IF <ls_token>-references IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      lv_lex = <ls_token>-lexeme.
      IF    lv_lex = 'NEW'
         OR lv_lex = 'VALUE'
         OR lv_lex = 'COND'
         OR lv_lex = 'SWITCH'
         OR lv_lex = 'REDUCE'
         OR lv_lex = 'FILTER'
         OR lv_lex = 'CORRESPONDING'
         OR lv_lex = 'EXACT'
         OR lv_lex = 'CONV'
         OR lv_lex = 'REF'
         OR lv_lex = 'CAST'.
        ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = sy-tabix + 1 ).
        IF ls_next-lexeme CP '*(' OR ls_next-lexeme = '#' OR ls_next-lexeme = '#('.
          rv_has = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_table_expression.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme = '[' AND <ls_token>-references IS INITIAL.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_inline_declaration.
    DATA lv_lex TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lex = <ls_token>-lexeme.
      IF    lv_lex CP 'DATA(*'
         OR lv_lex CP 'FINAL(*'
         OR lv_lex CP 'FIELD-SYMBOL(*'
         OR lv_lex CP '@DATA(*'.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_string_template.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF contains( val = <ls_token>-lexeme
                   sub = '|' ).
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_method_chaining.
    DATA lv_arrow_count TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    lv_arrow_count = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme = '->' OR <ls_token>-lexeme = '=>'.
        lv_arrow_count += 1.
        IF lv_arrow_count >= 2.
          rv_has = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_empty_key.
    rv_has = xsdbool( zcl_skylint_ast_util=>find_token_sequence(
                           is_statement = is_statement
                           it_expected  = VALUE #( ( `WITH` ) ( `EMPTY` ) ( `KEY` ) ) ) > 0 ).
  ENDMETHOD.

  METHOD has_calc_assign.
    DATA lv_lex TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lex = <ls_token>-lexeme.
      IF    lv_lex = '+='
         OR lv_lex = '-='
         OR lv_lex = '*='
         OR lv_lex = '/='
         OR lv_lex = '&&='.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_line_funcs.
    DATA lv_lex TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lex = <ls_token>-lexeme.
      IF    lv_lex = 'LINE_EXISTS('
         OR lv_lex = 'LINE_INDEX('.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_strict_sql.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    IF zcl_skylint_ast_util=>statement_is_db_access( is_statement ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme CP '@*'.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_raise_message.
    DATA lv_msg_idx TYPE i.

    rv_has = abap_false.
    IF is_statement-keyword <> 'RAISE'.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = `EXCEPTION` ) = abap_false.
      RETURN.
    ENDIF.

    lv_msg_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'MESSAGE' ).
    IF lv_msg_idx > 2.
      rv_has = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
