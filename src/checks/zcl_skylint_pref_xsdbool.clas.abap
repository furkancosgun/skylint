CLASS zcl_skylint_pref_xsdbool DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_xsdbool TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_XSDBL',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_xsdbool TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOXSDBOOL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_XSDBOOL'.

    METHODS is_boolean_assignment
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_target    TYPE string
                ev_is_bool   TYPE abap_bool.

    METHODS build_xsdbool_line
      IMPORTING is_if_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_then         TYPE if_ci_atc_source_code_provider=>ty_statement
                is_else         TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_target       TYPE string
      RETURNING VALUE(rv_line)  TYPE string.

    METHODS is_boolean_value
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_boolean_operand
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_xsdbool IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer xsdbool( ) expression over manual IF-ELSE assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_xsdbool
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Prefer xsdbool( ) over manual IF-ELSE assignment'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_xsdbool
                                                short_text = 'Use xsdbool( )' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max            TYPE i.
    DATA lv_idx            TYPE i.
    DATA ls_stmt_then      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_else      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_else_body TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_endif     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_target_1       TYPE string.
    DATA lv_target_2       TYPE string.
    DATA lv_is_bool_1      TYPE abap_bool.
    DATA lv_is_bool_2      TYPE abap_bool.
    DATA lv_line           TYPE string.
    DATA ls_quickfix       TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt_if> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_max = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt_if>.
      lv_idx = sy-tabix.
      IF <ls_stmt_if>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      IF lv_idx + 4 > lv_max.
        CONTINUE.
      ENDIF.

      ls_stmt_then = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_idx + 1 ).
      ls_stmt_else = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_idx + 2 ).
      ls_stmt_else_body = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                               iv_index      = lv_idx + 3 ).
      ls_stmt_endif = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = lv_idx + 4 ).
      IF    ls_stmt_then-keyword      IS INITIAL OR ls_stmt_else-keyword  IS INITIAL
         OR ls_stmt_else_body-keyword IS INITIAL OR ls_stmt_endif-keyword IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_stmt_else-keyword <> 'ELSE' OR ls_stmt_endif-keyword <> 'ENDIF'.
        CONTINUE.
      ENDIF.

      is_boolean_assignment( EXPORTING is_statement = ls_stmt_then
                             IMPORTING ev_target    = lv_target_1
                                       ev_is_bool   = lv_is_bool_1 ).

      is_boolean_assignment( EXPORTING is_statement = ls_stmt_else_body
                             IMPORTING ev_target    = lv_target_2
                                       ev_is_bool   = lv_is_bool_2 ).

      IF lv_is_bool_1 = abap_true AND lv_is_bool_2 = abap_true AND lv_target_1 = lv_target_2.
        CLEAR ls_quickfix.
        lv_line = build_xsdbool_line( is_if_statement = <ls_stmt_if>
                                      is_then         = ls_stmt_then
                                      is_else         = ls_stmt_else_body
                                      iv_target       = lv_target_1 ).
        IF lv_line IS NOT INITIAL.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_xsdbool
                                          iv_statement_from = lv_idx
                                          iv_statement_to   = lv_idx + 4
                                          it_new_code       = VALUE #( ( lv_line ) ) ).
        ENDIF.
        report_statement( is_statement    = <ls_stmt_if>
                          iv_finding_code = c_finding_codes-prefer_xsdbool
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_assignment.
    DATA ls_tok_target TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_eq     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_val    TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_is_bool = abap_false.
    CLEAR ev_target.

    IF zcl_skylint_ast_util=>token_count( is_statement ) <> 3.
      RETURN.
    ENDIF.

    ls_tok_target = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = 1 ).
    ls_tok_eq = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = 2 ).
    ls_tok_val = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = 3 ).
    IF    ls_tok_target-lexeme IS INITIAL OR ls_tok_eq-lexeme IS INITIAL
       OR ls_tok_val-lexeme    IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok_eq-lexeme <> '='.
      RETURN.
    ENDIF.

    IF is_boolean_operand( is_token  = ls_tok_val
                           iv_lexeme = ls_tok_val-lexeme ) = abap_true.
      ev_target  = ls_tok_target-lexeme.
      ev_is_bool = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_boolean_value.
    CASE iv_lexeme.
      WHEN 'ABAP_TRUE' OR 'ABAP_FALSE' OR '''X''' OR ''' ''' OR '''''' OR 'SPACE'.
        rv_res = abap_true.
      WHEN OTHERS.
        rv_res = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_boolean_operand.
    rv_res = abap_false.
    IF     is_token-references IS NOT INITIAL
       AND iv_lexeme           <> 'ABAP_TRUE'
       AND iv_lexeme           <> 'ABAP_FALSE'.
      RETURN.
    ENDIF.
    rv_res = is_boolean_value( iv_lexeme ).
  ENDMETHOD.

  METHOD build_xsdbool_line.
    DATA lv_count       TYPE i.
    DATA lv_idx         TYPE i.
    DATA lv_lex         TYPE string.
    DATA lv_cond        TYPE string.
    DATA lv_then_val    TYPE string.
    DATA lv_else_val    TYPE string.
    DATA lv_indent      TYPE string.
    DATA lv_is_inverted TYPE abap_bool.

    CLEAR rv_line.

    lv_then_val = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_then
                                                          iv_index     = 3 ).
    lv_else_val = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_else
                                                          iv_index     = 3 ).
    lv_is_inverted = abap_false.
    IF     ( lv_then_val = 'ABAP_TRUE'  OR lv_then_val = '''X''' )
       AND ( lv_else_val = 'ABAP_FALSE' OR lv_else_val = '''''' ).
      lv_is_inverted = abap_false.
    ELSEIF     ( lv_then_val = 'ABAP_FALSE' OR lv_then_val = '''''' )
           AND ( lv_else_val = 'ABAP_TRUE'  OR lv_else_val = '''X''' ).
      lv_is_inverted = abap_true.
    ELSE.
      RETURN.
    ENDIF.

    lv_count = zcl_skylint_ast_util=>token_count( is_if_statement ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    lv_cond = ''.
    lv_idx = 2.
    WHILE lv_idx <= lv_count.
      lv_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_if_statement
                                                       iv_index     = lv_idx ).
      IF lv_lex IS INITIAL.
        RETURN.
      ENDIF.
      IF lv_cond IS INITIAL.
        lv_cond = lv_lex.
      ELSE.
        lv_cond = |{ lv_cond } { lv_lex }|.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    lv_indent = repeat( val = ` `
                        occ = is_if_statement-position-column ).
    IF lv_is_inverted = abap_true.
      rv_line = |{ lv_indent }{ iv_target } = xsdbool( NOT ( { lv_cond } ) ).|.
    ELSE.
      rv_line = |{ lv_indent }{ iv_target } = xsdbool( { lv_cond } ).|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
