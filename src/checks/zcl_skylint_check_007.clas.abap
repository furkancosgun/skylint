CLASS zcl_skylint_check_007 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        assignment_chaining TYPE if_ci_atc_check=>ty_finding_code VALUE 'ASSIGNCHN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        split_assign TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'SPLITASG',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS has_assignment_chain
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_chain) TYPE abap_bool.

    METHODS split_chain
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_lines) TYPE zcl_skylint_check_base=>ty_code_lines.

ENDCLASS.


CLASS zcl_skylint_check_007 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid assignment chaining (a = b = c)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-assignment_chaining
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Avoid chained assignments; write separate assignment statements' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-split_assign
                                                                short_text = 'Split into separate assignments' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lt_new_code TYPE zcl_skylint_check_base=>ty_code_lines.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMPUTE'.
      lv_stmt_idx = sy-tabix.
      IF has_assignment_chain( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lt_new_code = split_chain( <ls_statement> ).
      IF lt_new_code IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-split_assign
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = lt_new_code ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-assignment_chaining
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD has_assignment_chain.
    DATA lv_depth        TYPE i.
    DATA lv_equals_count TYPE i.
    DATA lv_lexeme       TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_chain = abap_false.

    lv_depth = 0.
    lv_equals_count = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.

      IF    lv_lexeme CP '*(' OR lv_lexeme CP '*[' OR lv_lexeme CP '*{'
         OR lv_lexeme  = '('  OR lv_lexeme  = '['  OR lv_lexeme  = '{'.
        lv_depth += 1.
      ENDIF.

      IF lv_depth = 0 AND lv_lexeme = '='.
        lv_equals_count += 1.
      ENDIF.

      IF     (    lv_lexeme CP '*)' OR lv_lexeme CP '*]' OR lv_lexeme CP '*}'
               OR lv_lexeme  = ')'  OR lv_lexeme  = ']'  OR lv_lexeme  = '}' )
         AND lv_depth > 0.
        lv_depth -= 1.
      ENDIF.
    ENDLOOP.

    IF lv_equals_count > 1.
      rv_chain = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD split_chain.
    DATA lv_depth    TYPE i.
    DATA lv_lexeme   TYPE string.
    DATA lv_segment  TYPE string.
    DATA lt_segments TYPE string_table.
    DATA lv_idx      TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rt_lines.
    lv_depth = 0.
    lv_segment = ''.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.

      IF    lv_lexeme CP '*(' OR lv_lexeme CP '*[' OR lv_lexeme CP '*{'
         OR lv_lexeme  = '('  OR lv_lexeme  = '['  OR lv_lexeme  = '{'.
        lv_depth += 1.
      ENDIF.

      IF lv_depth = 0 AND lv_lexeme = '='.
        APPEND condense( lv_segment ) TO lt_segments.
        CLEAR lv_segment.
      ELSE.
        lv_segment = COND #( WHEN lv_segment IS INITIAL
                             THEN lv_lexeme
                             ELSE |{ lv_segment } { lv_lexeme }| ).
      ENDIF.

      IF     (    lv_lexeme CP '*)' OR lv_lexeme CP '*]' OR lv_lexeme CP '*}'
               OR lv_lexeme  = ')'  OR lv_lexeme  = ']'  OR lv_lexeme  = '}' )
         AND lv_depth > 0.
        lv_depth -= 1.
      ENDIF.
    ENDLOOP.
    APPEND condense( lv_segment ) TO lt_segments.

    IF lines( lt_segments ) < 3.
      CLEAR rt_lines.
      RETURN.
    ENDIF.

    LOOP AT lt_segments TRANSPORTING NO FIELDS WHERE table_line IS INITIAL.
      CLEAR rt_lines.
      RETURN.
    ENDLOOP.

    lv_idx = lines( lt_segments ) - 1.
    WHILE lv_idx >= 1.
      APPEND |{ lt_segments[ lv_idx ] } = { lt_segments[ lv_idx + 1 ] }.| TO rt_lines.
      lv_idx -= 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
