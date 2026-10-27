CLASS zcl_skylint_no_neg_cond DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        negated_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_NEG_CND',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_NEG_COND'.

    METHODS is_negated_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS strip_outer_parens
      IMPORTING it_tokens TYPE if_ci_atc_source_code_provider=>ty_tokens
                iv_from   TYPE i
                iv_to     TYPE i
      EXPORTING ev_from   TYPE i
                ev_to     TYPE i.

    METHODS is_prefer_is_not
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index      TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS has_plain_else
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_index      TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_neg_cond IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid negated IF conditions with ELSE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-negated_condition
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Invert the condition and swap the branches'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      IF is_negated_condition( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.
      IF has_plain_else( it_statements = is_procedure-statements
                         iv_index      = lv_stmt_idx ) = abap_false.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-negated_condition ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_negated_condition.
    DATA lv_count       TYPE i.
    DATA lv_from        TYPE i.
    DATA lv_to          TYPE i.
    DATA lv_paren_depth TYPE i.
    DATA lv_has_and_or  TYPE abap_bool.
    DATA lv_has_neg_op  TYPE abap_bool.
    DATA ls_prev        TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_count = lines( is_statement-tokens ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_count.

    strip_outer_parens( EXPORTING it_tokens = is_statement-tokens
                                  iv_from   = lv_from
                                  iv_to     = lv_to
                        IMPORTING ev_from   = lv_from
                                  ev_to     = lv_to ).

    ASSIGN is_statement-tokens[ lv_from ] TO <ls_token>.
    IF     sy-subrc = 0
       AND zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                   iv_lexeme = 'NOT' )    = abap_true
       AND is_prefer_is_not( is_statement = is_statement
                             iv_index     = lv_from ) = abap_false.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    lv_paren_depth = 0.
    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_token>.
      IF lv_paren_depth = 0.
        IF    zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                      iv_lexeme = 'AND' )    = abap_true
           OR zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                      iv_lexeme = 'OR' )     = abap_true.
          lv_has_and_or = abap_true.
        ELSEIF    zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                          iv_lexeme = '<>' )     = abap_true
               OR zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                          iv_lexeme = 'NE' )     = abap_true.
          lv_has_neg_op = abap_true.
        ELSEIF zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                       iv_lexeme = 'NOT' ) = abap_true.
          ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = sy-tabix - 1 ).
          IF     zcl_skylint_ast_util=>token_is_keyword( is_token  = ls_prev
                                                         iv_lexeme = 'IS' )  = abap_false
             AND is_prefer_is_not( is_statement = is_statement
                                   iv_index     = sy-tabix )                 = abap_false.
            lv_has_neg_op = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.

      lv_paren_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.

    IF lv_has_neg_op = abap_true AND lv_has_and_or = abap_false.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD strip_outer_parens.
    ev_from = iv_from.
    ev_to   = iv_to.
    zcl_skylint_ast_util=>strip_outer_parens( EXPORTING it_tokens = it_tokens
                                              CHANGING  cv_from   = ev_from
                                                        cv_to     = ev_to ).
  ENDMETHOD.

  METHOD is_prefer_is_not.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    LOOP AT is_statement-tokens FROM iv_index + 1 ASSIGNING <ls_token>.
      IF zcl_skylint_ast_util=>token_is_keyword( <ls_token> ) = abap_false.
        CONTINUE.
      ENDIF.

      CASE <ls_token>-lexeme.
        WHEN 'AND' OR 'OR'.
          RETURN.
        WHEN 'IS'.
          ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = sy-tabix + 1 ).
          IF zcl_skylint_ast_util=>token_is_keyword( ls_next ) = abap_true.
            CASE ls_next-lexeme.
              WHEN 'INITIAL' OR 'BOUND' OR 'ASSIGNED' OR 'SUPPLIED' OR 'REQUESTED' OR 'INSTANCE'.
                rv_yes = abap_true.
                RETURN.
            ENDCASE.
          ENDIF.
          RETURN.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_plain_else.
    DATA lv_depth      TYPE i.
    DATA lv_has_else   TYPE abap_bool.
    DATA lv_has_elseif TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_yes = abap_false.

    LOOP AT it_statements FROM iv_index + 1 ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF'.
          lv_depth += 1.
        WHEN 'ENDIF'.
          IF lv_depth = 0.
            EXIT.
          ENDIF.
          lv_depth -= 1.
        WHEN 'ELSEIF'.
          IF lv_depth = 0.
            lv_has_elseif = abap_true.
          ENDIF.
        WHEN 'ELSE'.
          IF lv_depth = 0.
            lv_has_else = abap_true.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF lv_has_else = abap_true AND lv_has_elseif = abap_false.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
