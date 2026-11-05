CLASS /skyl/cl_no_inline_packed DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        inline_packed_calc TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_INL_PCK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INLINE_PACKED'.

    METHODS check_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS /skyl/cl_no_inline_packed IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Inline declaration with packed arithmetic loses decimals'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-inline_packed_calc
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'DATA(...) with packed arithmetic defaults to P(8,0) and loses decimals'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'COMPUTE'.
        check_statement( <ls_statement> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_statement.
    DATA ls_target   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_eq_idx   TYPE i.
    DATA ls_after_eq TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_tok_idx  TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_target = /skyl/cl_ast_util=>get_first_token( is_statement ).
    IF ls_target-lexeme NP 'DATA(*)' AND ls_target-lexeme NP 'FINAL(*)'.
      RETURN.
    ENDIF.

    lv_eq_idx = /skyl/cl_ast_util=>find_token( is_statement = is_statement
                                               iv_lexeme    = '=' ).
    IF lv_eq_idx = 0.
      RETURN.
    ENDIF.

    ls_after_eq = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_eq_idx + 1 ).

    IF    ls_after_eq-lexeme = 'CONV'
       OR ls_after_eq-lexeme = 'EXACT'
       OR ls_after_eq-lexeme = 'CAST'
       OR ls_after_eq-lexeme = 'COND'
       OR ls_after_eq-lexeme = 'SWITCH'.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_tok_idx = sy-tabix.
      IF lv_tok_idx <= lv_eq_idx.
        CONTINUE.
      ENDIF.

      IF    <ls_tok>-lexeme = '*'
         OR <ls_tok>-lexeme = '/'
         OR <ls_tok>-lexeme = '+'
         OR <ls_tok>-lexeme = '-'.
        report_token( is_token        = ls_target
                      is_statement    = is_statement
                      iv_finding_code = c_finding_codes-inline_packed_calc ).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
