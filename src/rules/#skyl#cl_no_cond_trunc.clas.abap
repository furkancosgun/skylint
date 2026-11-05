CLASS /skyl/cl_no_cond_trunc DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        cond_truncation TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CND_TRN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_COND_TRUNC'.

    METHODS check_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS /skyl/cl_no_cond_trunc IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Unsafe COND or SWITCH inferred type truncates values'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-cond_truncation
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'COND/SWITCH #( ) infers short C type and truncates longer branches'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      check_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD check_statement.
    DATA lv_tok_idx     TYPE i.
    DATA ls_next        TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_depth       TYPE i.
    DATA lv_scan_idx    TYPE i.
    DATA ls_scan_tok    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_res_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lt_results     TYPE STANDARD TABLE OF if_ci_atc_source_code_provider=>ty_token WITH EMPTY KEY.
    DATA ls_first       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_first_len   TYPE i.
    DATA lv_trunc_found TYPE abap_bool.

    FIELD-SYMBOLS <ls_tok>    TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_branch> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_tok_idx = sy-tabix.

      IF <ls_tok>-references IS NOT INITIAL OR ( <ls_tok>-lexeme <> 'COND' AND <ls_tok>-lexeme <> 'SWITCH' ).
        CONTINUE.
      ENDIF.

      ls_next = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_tok_idx + 1 ).
      IF ls_next-lexeme <> '#('.
        CONTINUE.
      ENDIF.

      CLEAR lt_results.
      lv_depth    = 1.
      lv_scan_idx = lv_tok_idx + 2.

      WHILE lv_scan_idx <= lines( is_statement-tokens ) AND lv_depth > 0.
        ls_scan_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_scan_idx ).

        lv_depth += /skyl/cl_ast_util=>token_paren_delta( ls_scan_tok ).

        IF lv_depth = 1 AND ls_scan_tok-references IS INITIAL AND ( ls_scan_tok-lexeme = 'THEN' OR ls_scan_tok-lexeme = 'ELSE' ).
          ls_res_tok = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = lv_scan_idx + 1 ).
          IF ls_res_tok-lexeme IS NOT INITIAL.
            APPEND ls_res_tok TO lt_results.
          ENDIF.
        ENDIF.

        lv_scan_idx += 1.
      ENDWHILE.

      IF lines( lt_results ) < 2.
        CONTINUE.
      ENDIF.

      READ TABLE lt_results INDEX 1 INTO ls_first.
      IF sy-subrc <> 0 OR ls_first-lexeme NP '''*'''.
        CONTINUE.
      ENDIF.

      lv_first_len   = strlen( ls_first-lexeme ).
      lv_trunc_found = abap_false.

      LOOP AT lt_results ASSIGNING <ls_branch> FROM 2.
        IF <ls_branch>-lexeme CP '''*''' AND strlen( <ls_branch>-lexeme ) > lv_first_len.
          lv_trunc_found = abap_true.
          EXIT.
        ELSEIF <ls_branch>-lexeme CP '|*|' OR <ls_branch>-lexeme CP '`*`'.
          lv_trunc_found = abap_true.
          EXIT.
        ELSEIF     <ls_branch>-lexeme NP '''*'''
               AND <ls_branch>-lexeme <> 'SPACE'
               AND <ls_branch>-lexeme <> 'ABAP_FALSE'
               AND <ls_branch>-lexeme <> 'ABAP_TRUE'.
          lv_trunc_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_trunc_found = abap_true.
        report_token( is_token        = <ls_tok>
                      is_statement    = is_statement
                      iv_finding_code = c_finding_codes-cond_truncation ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
