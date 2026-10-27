CLASS zcl_skylint_no_dup_cond DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUP_CND',
        duplicate_operand   TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUP_OPR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DUP_COND'.

    METHODS check_duplicate_elseif
      IMPORTING iv_idx       TYPE i
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS check_duplicate_when
      IMPORTING iv_idx       TYPE i
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS check_duplicate_operands
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS get_condition_string
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_cond) TYPE string.

    METHODS strip_outer_parens
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  cv_from      TYPE i
                cv_to        TYPE i.

    METHODS normalize_operand_str
      IMPORTING iv_operand        TYPE string
      RETURNING VALUE(rv_operand) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_dup_cond IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid duplicate branch conditions in IF and CASE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-identical_condition
                                       text = 'Identical condition in branch; duplicate branch is unreachable' )
                                     ( code = c_finding_codes-duplicate_operand
                                       text = 'Identical operand in condition; remove the duplicate comparison' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'ELSEIF'.
          check_duplicate_elseif( iv_idx       = lv_idx
                                  is_statement = <ls_statement>
                                  is_procedure = is_procedure ).
          check_duplicate_operands( <ls_statement> ).

        WHEN 'WHEN'.
          check_duplicate_when( iv_idx       = lv_idx
                                is_statement = <ls_statement>
                                is_procedure = is_procedure ).

        WHEN 'IF' OR 'WHILE' OR 'CHECK'.
          check_duplicate_operands( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_duplicate_elseif.
    DATA lv_cond      TYPE string.
    DATA lv_prev_cond TYPE string.
    DATA lv_back_idx  TYPE i.
    DATA lv_depth     TYPE i.
    DATA ls_back_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_cond = get_condition_string( is_statement ).
    lv_depth = 0.
    lv_back_idx = iv_idx - 1.

    WHILE lv_back_idx >= 1.
      ls_back_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_back_idx ).
      IF ls_back_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_back_stmt-keyword.
        WHEN 'ENDIF'.
          lv_depth += 1.

        WHEN 'IF'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( ls_back_stmt ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
            ENDIF.
            EXIT.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'ELSEIF'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( ls_back_stmt ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.

      lv_back_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD check_duplicate_when.
    DATA lv_cond      TYPE string.
    DATA lv_prev_cond TYPE string.
    DATA lv_back_idx  TYPE i.
    DATA lv_depth     TYPE i.
    DATA ls_back_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_cond = get_condition_string( is_statement ).
    lv_depth = 0.
    lv_back_idx = iv_idx - 1.

    WHILE lv_back_idx >= 1.
      ls_back_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_back_idx ).
      IF ls_back_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_back_stmt-keyword.
        WHEN 'ENDCASE'.
          lv_depth += 1.

        WHEN 'CASE'.
          IF lv_depth = 0.
            EXIT.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'WHEN'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( ls_back_stmt ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.

      lv_back_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD check_duplicate_operands.
    DATA lv_tok_cnt  TYPE i.
    DATA lv_from     TYPE i.
    DATA lv_to       TYPE i.
    DATA lv_depth    TYPE i.
    DATA lv_between  TYPE abap_bool.
    DATA lv_operator TYPE string.
    DATA lv_token_op TYPE string.
    DATA lv_lexeme   TYPE string.
    DATA lv_operand  TYPE string.
    DATA lt_operands TYPE string_table.
    DATA lt_seen     TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_tok_cnt = lines( is_statement-tokens ).
    IF lv_tok_cnt < 2.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_tok_cnt.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    lv_depth = 0.
    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.
      lv_token_op = ''.

      IF <ls_token>-references IS INITIAL AND lv_depth = 0.
        CASE lv_lexeme.
          WHEN 'BETWEEN'.
            lv_between = abap_true.
          WHEN 'AND'.
            IF lv_between = abap_true.
              lv_between = abap_false.
            ELSE.
              lv_token_op = lv_lexeme.
            ENDIF.
          WHEN 'OR' OR 'EQUIV'.
            lv_token_op = lv_lexeme.
        ENDCASE.
      ENDIF.

      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).

      IF lv_token_op IS NOT INITIAL.
        IF lv_operator IS INITIAL.
          lv_operator = lv_token_op.
        ELSEIF lv_operator <> lv_token_op.
          RETURN.
        ENDIF.
        IF lv_operand IS NOT INITIAL.
          APPEND normalize_operand_str( lv_operand ) TO lt_operands.
        ENDIF.
        CLEAR lv_operand.
      ELSEIF lv_operand IS INITIAL.
        lv_operand = lv_lexeme.
      ELSE.
        lv_operand = |{ lv_operand } { lv_lexeme }|.
      ENDIF.
    ENDLOOP.

    IF lv_operand IS NOT INITIAL.
      APPEND normalize_operand_str( lv_operand ) TO lt_operands.
    ENDIF.

    IF lines( lt_operands ) < 2.
      RETURN.
    ENDIF.

    LOOP AT lt_operands INTO lv_operand.
      IF line_exists( lt_seen[ table_line = lv_operand ] ).
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-duplicate_operand ).
        RETURN.
      ENDIF.
      INSERT lv_operand INTO TABLE lt_seen.
    ENDLOOP.
  ENDMETHOD.

  METHOD strip_outer_parens.
    zcl_skylint_ast_util=>strip_outer_parens( EXPORTING is_statement = is_statement
                                              CHANGING  cv_from      = cv_from
                                                        cv_to        = cv_to ).
  ENDMETHOD.

  METHOD normalize_operand_str.
    DATA lv_len   TYPE i.
    DATA lv_start TYPE string.
    DATA lv_end   TYPE string.

    rv_operand = iv_operand.
    WHILE strlen( rv_operand ) >= 4.
      lv_len = strlen( rv_operand ).
      lv_start = substring( val = rv_operand
                            off = 0
                            len = 2 ).
      IF lv_start <> '( '.
        EXIT.
      ENDIF.
      lv_end = substring( val = rv_operand
                          off = lv_len - 2
                          len = 2 ).
      IF lv_end <> ' )'.
        EXIT.
      ENDIF.
      rv_operand = substring( val = rv_operand
                              off = 2
                              len = lv_len - 4 ).
    ENDWHILE.
  ENDMETHOD.

  METHOD get_condition_string.
    DATA lv_tok_cnt TYPE i.
    DATA lv_from    TYPE i.
    DATA lv_to      TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_cond = ''.
    lv_tok_cnt = lines( is_statement-tokens ).
    IF lv_tok_cnt < 2.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_tok_cnt.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    IF lv_from > lv_to.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_token>.
      IF <ls_token>-lexeme IS NOT INITIAL.
        IF rv_cond IS INITIAL.
          rv_cond = <ls_token>-lexeme.
        ELSE.
          rv_cond = |{ rv_cond } { <ls_token>-lexeme }|.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
