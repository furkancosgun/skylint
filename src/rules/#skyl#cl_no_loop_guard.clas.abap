CLASS /skyl/cl_no_loop_guard DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unnecessary_loop_guard TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_LOOP_GD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_LOOP_GUARD'.

    METHODS check_if_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx  TYPE i
                it_stmts     TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS eval_condition
      IMPORTING is_statement          TYPE if_ci_atc_source_code_provider=>ty_statement
                is_loop_tok           TYPE if_ci_atc_source_code_provider=>ty_token
                is_loop_ref           TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_is_positive) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_loop_guard IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Redundant IF condition before LOOP AT'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unnecessary_loop_guard
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Unnecessary IF guard before LOOP AT; an empty table iterates 0 times'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_stmt_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword = 'IF'.
        check_if_statement( is_statement = <ls_statement>
                            iv_stmt_idx  = lv_stmt_idx
                            it_stmts     = is_procedure-statements ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_if_statement.
    DATA lv_next_idx   TYPE i.
    DATA ls_at_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_loop_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_curr_idx   TYPE i.
    DATA lv_loop_depth TYPE i.
    DATA lv_after_loop TYPE i.

    FIELD-SYMBOLS <ls_next_stmt>  TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_inner>      TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_after_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_next_idx = iv_stmt_idx + 1.
    IF lv_next_idx > lines( it_stmts ).
      RETURN.
    ENDIF.

    ASSIGN it_stmts[ lv_next_idx ] TO <ls_next_stmt>.
    IF <ls_next_stmt>-keyword <> 'LOOP'.
      RETURN.
    ENDIF.

    ls_at_tok = /skyl/cl_ast_util=>get_token_after( is_statement = <ls_next_stmt>
                                                    iv_lexeme    = 'AT' ).
    IF ls_at_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    ls_loop_ref = /skyl/cl_ast_util=>get_reference(
                      is_token = ls_at_tok
                      iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).

    IF eval_condition( is_statement = is_statement
                       is_loop_tok  = ls_at_tok
                       is_loop_ref  = ls_loop_ref ) = abap_false.
      RETURN.
    ENDIF.

    lv_loop_depth = 1.
    lv_curr_idx   = lv_next_idx + 1.

    WHILE lv_curr_idx <= lines( it_stmts ) AND lv_loop_depth > 0.
      ASSIGN it_stmts[ lv_curr_idx ] TO <ls_inner>.
      CASE <ls_inner>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth += 1.
        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          lv_loop_depth -= 1.
          IF lv_loop_depth = 0.
            EXIT.
          ENDIF.
      ENDCASE.
      lv_curr_idx += 1.
    ENDWHILE.

    IF lv_loop_depth <> 0.
      RETURN.
    ENDIF.

    lv_after_loop = lv_curr_idx + 1.
    IF lv_after_loop > lines( it_stmts ).
      RETURN.
    ENDIF.

    ASSIGN it_stmts[ lv_after_loop ] TO <ls_after_stmt>.
    IF <ls_after_stmt>-keyword <> 'ENDIF'.
      RETURN.
    ENDIF.

    report_statement( is_statement    = is_statement
                      iv_finding_code = c_finding_codes-unnecessary_loop_guard ).
  ENDMETHOD.

  METHOD eval_condition.
    DATA lv_tab_found TYPE abap_bool.
    DATA lv_has_not   TYPE abap_bool.
    DATA ls_tok_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is_positive = abap_false.

    IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                            iv_lexeme    = 'OR' ) = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      ls_tok_ref = /skyl/cl_ast_util=>get_reference(
                       is_token = <ls_tok>
                       iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).

      IF is_loop_ref-full_name IS NOT INITIAL AND ls_tok_ref-full_name IS NOT INITIAL.
        IF ls_tok_ref-full_name = is_loop_ref-full_name.
          lv_tab_found = abap_true.
          EXIT.
        ENDIF.
      ELSEIF <ls_tok>-lexeme = is_loop_tok-lexeme.
        lv_tab_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_tab_found = abap_false.
      RETURN.
    ENDIF.

    lv_has_not = /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                                      iv_lexeme    = 'NOT' ).

    IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                            iv_lexeme    = 'INITIAL' ) = abap_true.
      IF lv_has_not = abap_true.
        rv_is_positive = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    IF /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                            iv_lexeme    = '0' ) = abap_true.
      LOOP AT is_statement-tokens TRANSPORTING NO FIELDS WHERE lexeme = '=' OR lexeme = '<='.
        lv_has_not = abap_true.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF     (    /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'LINES(' )       = abap_true
             OR /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'LINE_EXISTS(' ) = abap_true )
       AND lv_has_not = abap_false.
      rv_is_positive = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
