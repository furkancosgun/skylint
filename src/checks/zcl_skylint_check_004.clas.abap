CLASS zcl_skylint_check_004 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_is_not TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFERISNT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_is_not TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ISNOT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.

    METHODS has_not_is_pattern
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_not_index TYPE i
                ev_is_index  TYPE i
                ev_matched   TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_004 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer IS NOT over NOT ... IS'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_is_not
                                                                severity = if_ci_atc_check=>finding_severities-warning
                                                                text           = 'Use IS NOT instead of NOT ... IS'
                                                                ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_is_not
                                                                short_text = 'Rewrite as IS NOT' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_not_idx  TYPE i.
    DATA lv_is_idx   TYPE i.
    DATA lv_matched  TYPE abap_bool.
    DATA lv_x_lex    TYPE string.
    DATA lv_y_lex    TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> LIKE LINE OF is_procedure-statements.
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'IF' OR keyword = 'ELSEIF' OR keyword = 'CHECK'
            OR keyword = 'WHILE'.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.

      has_not_is_pattern( EXPORTING is_statement = <ls_statement>
                           IMPORTING ev_not_index = lv_not_idx
                                     ev_is_index  = lv_is_idx
                                     ev_matched   = lv_matched ).

      IF lv_matched = abap_true.
        IF lv_is_idx = lv_not_idx + 2.
          lv_x_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = lv_not_idx + 1 ).
          lv_y_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = lv_is_idx + 1 ).
          lt_overrides = VALUE #( ( index  = lv_not_idx
                                    lexeme = lv_x_lex )
                                  ( index  = lv_not_idx + 1
                                    lexeme = 'IS' )
                                  ( index  = lv_is_idx
                                    lexeme = 'NOT' )
                                  ( index  = lv_is_idx + 1
                                    lexeme = lv_y_lex ) ).
          lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                       it_overrides = lt_overrides ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_is_not
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line && '.' ) ) ).
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_is_not
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_not_is_pattern.
    DATA lv_in_not      TYPE abap_bool.
    DATA lv_lexeme      TYPE string.
    DATA lv_next_lexeme TYPE string.
    DATA lv_idx         TYPE i.
    DATA ls_next        TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_matched = abap_false.
    lv_in_not = abap_false.
    CLEAR: ev_not_index,
           ev_is_index.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_idx = sy-tabix.
      IF <ls_token>-references IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      lv_lexeme = to_upper( <ls_token>-lexeme ).

      IF lv_lexeme = 'NOT'.
        lv_in_not = abap_true.
        ev_not_index = lv_idx.
      ELSEIF lv_lexeme = 'AND' OR lv_lexeme = 'OR' OR lv_lexeme = ')' OR lv_lexeme = '('.
        lv_in_not = abap_false.
      ELSEIF lv_in_not = abap_true AND lv_lexeme = 'IS'.
        ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_idx + 1 ).
        lv_next_lexeme = to_upper( ls_next-lexeme ).
        IF ls_next-references IS INITIAL.
          CASE lv_next_lexeme.
            WHEN 'INITIAL' OR 'BOUND' OR 'ASSIGNED' OR 'SUPPLIED' OR 'REQUESTED' OR 'INSTANCE'.
              ev_matched = abap_true.
              ev_is_index = lv_idx.
              RETURN.
          ENDCASE.
        ENDIF.
        lv_in_not = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
