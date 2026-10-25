CLASS zcl_skylint_pref_is_initial DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_is_initial TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INIT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_is_initial TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLINIT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_INIT'.

    METHODS check_lines_pattern
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx  TYPE i.

    METHODS check_literal_pattern
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx  TYPE i.

    METHODS is_initial_literal
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_is_initial IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer IS [NOT] INITIAL over lines( ) or empty literals'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_is_initial
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use IS [NOT] INITIAL instead of lines( ) or empty literal comparison'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_is_initial
                                                short_text = 'Rewrite with IS [NOT] INITIAL' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword <> 'IF'
         AND <ls_statement>-keyword <> 'ELSEIF'
         AND <ls_statement>-keyword <> 'CHECK'
         AND <ls_statement>-keyword <> 'WHILE'.
        CONTINUE.
      ENDIF.

      lv_stmt_idx = sy-tabix.

      check_lines_pattern( is_statement = <ls_statement>
                           iv_stmt_idx  = lv_stmt_idx ).

      check_literal_pattern( is_statement = <ls_statement>
                             iv_stmt_idx  = lv_stmt_idx ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_initial_literal.
    DATA lv_clean TYPE string.

    rv_yes = abap_false.
    IF is_token-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    lv_clean = is_token-lexeme.

    IF is_token-lexeme = `''` OR is_token-lexeme = '``' OR is_token-lexeme = `' '`.
      rv_yes = abap_true.
    ELSEIF lv_clean = 'SPACE'.
      rv_yes = abap_true.
    ELSEIF lv_clean = '0'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD check_lines_pattern.
    DATA lv_lines_idx TYPE i.
    DATA lv_close_idx TYPE i.
    DATA lv_op        TYPE string.
    DATA lv_val       TYPE string.
    DATA lv_is_not    TYPE abap_bool.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.
    DATA ls_next_op   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_val  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-lexeme <> 'LINES('.
        CONTINUE.
      ENDIF.

      lv_lines_idx = sy-tabix.
      lv_close_idx = lv_lines_idx + 2.

      IF lines( is_statement-tokens ) < lv_close_idx + 2.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                 iv_index     = lv_close_idx ) = ')'.
        ls_next_op  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                       iv_index     = lv_close_idx + 1 ).
        ls_next_val = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                       iv_index     = lv_close_idx + 2 ).
        lv_op  = ls_next_op-lexeme.
        lv_val = ls_next_val-lexeme.

        IF    ( ( lv_op = '>'  OR lv_op = 'GT' ) AND lv_val = '0' )
           OR ( ( lv_op = '>=' OR lv_op = 'GE' ) AND lv_val = '1' )
           OR ( ( lv_op = '<>' OR lv_op = 'NE' ) AND lv_val = '0' ).
          lv_is_not = abap_true.
        ELSEIF    ( ( lv_op = '='  OR lv_op = 'EQ' ) AND lv_val = '0' )
               OR ( ( lv_op = '<=' OR lv_op = 'LE' ) AND lv_val = '0' )
               OR ( ( lv_op = '<'  OR lv_op = 'LT' ) AND lv_val = '1' ).
          lv_is_not = abap_false.
        ELSE.
          CONTINUE.
        ENDIF.

        lt_deletions = VALUE #( ( lv_lines_idx )
                                ( lv_close_idx )
                                ( lv_close_idx + 2 ) ).
        IF lv_is_not = abap_true.
          lt_overrides = VALUE #( ( index  = lv_close_idx + 1
                                    lexeme = 'IS NOT INITIAL' ) ).
        ELSE.
          lt_overrides = VALUE #( ( index  = lv_close_idx + 1
                                    lexeme = 'IS INITIAL' ) ).
        ENDIF.

        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                           it_overrides = lt_overrides
                                                           it_deletions = lt_deletions ).
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_is_initial
                                        iv_statement_from = iv_stmt_idx
                                        it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).

        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-prefer_is_initial
                          is_quickfix     = ls_quickfix ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_literal_pattern.
    DATA lv_idx       TYPE i.
    DATA lv_left_idx  TYPE i.
    DATA lv_right_idx TYPE i.
    DATA lv_is_not    TYPE abap_bool.
    DATA lv_var_idx   TYPE i.
    DATA lv_lit_idx   TYPE i.
    DATA lv_var_lex   TYPE string.
    DATA lv_line      TYPE string.
    DATA ls_left      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_right     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_after     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_before    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      IF zcl_skylint_ast_util=>token_is_keyword( <ls_tok> ) = abap_false.
        CONTINUE.
      ENDIF.

      CASE <ls_tok>-lexeme.
        WHEN '=' OR 'EQ'.
          lv_is_not = abap_false.
        WHEN '<>' OR 'NE'.
          lv_is_not = abap_true.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      IF lv_idx <= 1 OR lv_idx >= lines( is_statement-tokens ).
        CONTINUE.
      ENDIF.

      lv_left_idx  = lv_idx - 1.
      lv_right_idx = lv_idx + 1.
      ls_left  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_left_idx ).
      ls_right = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_right_idx ).

      IF is_initial_literal( ls_right ) = abap_true AND is_initial_literal( ls_left ) = abap_false.
        IF lines( is_statement-tokens ) > lv_right_idx.
          ls_after = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                      iv_index     = lv_right_idx + 1 ).
          IF ls_after-lexeme = '+' OR ls_after-lexeme = '-' OR ls_after-lexeme = '*' OR ls_after-lexeme = '/'.
            CONTINUE.
          ENDIF.
        ENDIF.

        IF ls_left-lexeme CA '()[]' OR zcl_skylint_ast_util=>token_is_identifier( ls_left ) = abap_false.
          CONTINUE.
        ENDIF.

        lv_var_idx = lv_left_idx.
        lv_lit_idx = lv_right_idx.
        lv_var_lex = ls_left-lexeme.

      ELSEIF is_initial_literal( ls_left ) = abap_true AND is_initial_literal( ls_right ) = abap_false.
        IF lv_left_idx > 1.
          ls_before = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                       iv_index     = lv_left_idx - 1 ).
          IF ls_before-lexeme = '+' OR ls_before-lexeme = '-' OR ls_before-lexeme = '*' OR ls_before-lexeme = '/'.
            CONTINUE.
          ENDIF.
        ENDIF.

        IF ls_right-lexeme CA '()[]' OR zcl_skylint_ast_util=>token_is_identifier( ls_right ) = abap_false.
          CONTINUE.
        ENDIF.

        lv_var_idx = lv_right_idx.
        lv_lit_idx = lv_left_idx.
        lv_var_lex = ls_right-lexeme.
      ELSE.
        CONTINUE.
      ENDIF.

      IF lv_var_lex CP 'SY-*' OR lv_var_lex CP 'SYST-*'.
        CONTINUE.
      ENDIF.

      CLEAR: lt_overrides,
             lt_deletions.

      IF lv_var_idx < lv_lit_idx.
        lt_deletions = VALUE #( ( lv_lit_idx ) ).
        IF lv_is_not = abap_true.
          lt_overrides = VALUE #( ( index  = lv_idx
                                    lexeme = 'IS NOT INITIAL' ) ).
        ELSE.
          lt_overrides = VALUE #( ( index  = lv_idx
                                    lexeme = 'IS INITIAL' ) ).
        ENDIF.
      ELSE.
        lt_deletions = VALUE #( ( lv_var_idx ) ).
        IF lv_is_not = abap_true.
          lt_overrides = VALUE #( ( index  = lv_lit_idx
                                    lexeme = lv_var_lex )
                                  ( index  = lv_idx
                                    lexeme = 'IS NOT INITIAL' ) ).
        ELSE.
          lt_overrides = VALUE #( ( index  = lv_lit_idx
                                    lexeme = lv_var_lex )
                                  ( index  = lv_idx
                                    lexeme = 'IS INITIAL' ) ).
        ENDIF.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                         it_overrides = lt_overrides
                                                         it_deletions = lt_deletions ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_is_initial
                                      iv_statement_from = iv_stmt_idx
                                      it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).

      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-prefer_is_initial
                        is_quickfix     = ls_quickfix ).
      RETURN.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
