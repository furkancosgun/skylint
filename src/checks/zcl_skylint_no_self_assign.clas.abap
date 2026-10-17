CLASS zcl_skylint_no_self_assign DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_move TYPE if_ci_atc_check=>ty_finding_code VALUE 'IDENTMOVE',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        delete_self TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DELIDENT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SELF_ASSIGN'.

    METHODS is_identical_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_self_assign IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Detect Identical Self Assignments'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-identical_move
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Identical assignment has no effect; remove redundant statement'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-delete_self
                                                                short_text = 'Delete self-assignment' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMPUTE'.
      lv_stmt_idx = sy-tabix.
      IF is_identical_assignment( <ls_statement> ) = abap_true.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-delete_self
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ) ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-identical_move
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA ls_tok_left  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_right TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref_write> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_res = abap_false.

    IF zcl_skylint_ast_util=>token_count( is_statement ) <> 3.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = '=' ) = abap_false.
      RETURN.
    ENDIF.

    ls_tok_left = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = 1 ).
    ls_tok_right = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = 3 ).

    IF ls_tok_left-lexeme = ls_tok_right-lexeme.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    LOOP AT ls_tok_left-references ASSIGNING <ls_ref_write>
         WHERE     kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
               AND usage_mode = if_ci_atc_source_code_provider=>usage_modes-write.
      IF     <ls_ref_write>-full_name IS NOT INITIAL
         AND line_exists( ls_tok_right-references[
                              kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                              usage_mode = if_ci_atc_source_code_provider=>usage_modes-read
                              full_name  = <ls_ref_write>-full_name ] ).
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
