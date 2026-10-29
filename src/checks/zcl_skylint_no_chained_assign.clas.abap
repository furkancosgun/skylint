CLASS zcl_skylint_no_chained_assign DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        assignment_chaining TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CHN_ASG',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        split_assign TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'SPLITASG',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CHAINED_ASSIGN'.

    METHODS has_assignment_chain
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_chain) TYPE abap_bool.

    METHODS split_chain
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_lines) TYPE zcl_skylint_check_base=>ty_code_lines.

ENDCLASS.


CLASS zcl_skylint_no_chained_assign IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Chained Assignments'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-assignment_chaining
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid chained assignments; write separate assignment statements'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-split_assign
                                                short_text = 'Split into separate assignments' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx      TYPE i.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      IF <ls_statement>-keyword <> 'COMPUTE' OR has_assignment_chain( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lt_new_code = split_chain( <ls_statement> ).
      IF lt_new_code IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-split_assign
                                        iv_statement_from = lv_idx
                                        it_new_code       = lt_new_code ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-assignment_chaining
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD has_assignment_chain.
    DATA lv_depth TYPE i.
    DATA lv_count TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_depth = 0.
    lv_count = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_depth = 0 AND <ls_token>-lexeme = '='.
        lv_count += 1.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.

    rv_chain = xsdbool( lv_count > 1 ).
  ENDMETHOD.

  METHOD split_chain.
    DATA lv_depth    TYPE i.
    DATA lv_segment  TYPE string.
    DATA lt_segments TYPE string_table.
    DATA lv_idx      TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_depth = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_depth = 0 AND <ls_token>-lexeme = '='.
        APPEND condense( lv_segment ) TO lt_segments.
        CLEAR lv_segment.
      ELSE.
        lv_segment = COND #( WHEN lv_segment IS INITIAL
                             THEN <ls_token>-lexeme
                             ELSE |{ lv_segment } { <ls_token>-lexeme }| ).
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.

    APPEND condense( lv_segment ) TO lt_segments.

    IF lines( lt_segments ) < 3 OR line_exists( lt_segments[ table_line = '' ] ).
      CLEAR rt_lines.
      RETURN.
    ENDIF.

    lv_idx = lines( lt_segments ) - 1.
    WHILE lv_idx >= 1.
      APPEND |{ lt_segments[ lv_idx ] } = { lt_segments[ lv_idx + 1 ] }.| TO rt_lines.
      lv_idx -= 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
