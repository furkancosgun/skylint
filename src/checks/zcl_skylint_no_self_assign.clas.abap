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
    DATA lv_eq_idx      TYPE i.
    DATA ls_tok_left    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_right   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_after   TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref_w> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_ref_r> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_res = abap_false.

    lv_eq_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                  iv_lexeme    = '=' ).
    IF lv_eq_idx <= 1 OR lv_eq_idx >= lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    " Ensure = is top-level assignment operator (empty references)
    ls_tok_left = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_eq_idx ).
    IF ls_tok_left-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    ls_tok_left = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_eq_idx - 1 ).
    ls_tok_right = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_eq_idx + 1 ).

    " Ensure RHS is a single token assignment (no operators or extra arguments following RHS)
    IF lines( is_statement-tokens ) > lv_eq_idx + 1.
      ls_tok_after = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                      iv_index     = lv_eq_idx + 2 ).
      IF ls_tok_after-lexeme IS NOT INITIAL AND NOT ( ls_tok_after-lexeme CP '##*' OR ls_tok_after-lexeme = '.' ).
        RETURN.
      ENDIF.
    ENDIF.

    " 1. Compiler reference check: same symbol on LHS and RHS
    LOOP AT ls_tok_left-references ASSIGNING <ls_ref_w>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      LOOP AT ls_tok_right-references ASSIGNING <ls_ref_r>
           WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
             AND full_name = <ls_ref_w>-full_name
             AND full_name IS NOT INITIAL.
        rv_res = abap_true.
        RETURN.
      ENDLOOP.
    ENDLOOP.

    " 2. Fallback to identical lexeme when not literals
    IF     ls_tok_left-lexeme = ls_tok_right-lexeme
       AND zcl_skylint_ast_util=>token_is_literal( ls_tok_left ) = abap_false.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
