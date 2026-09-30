CLASS zcl_skylint_check_063 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_cond TYPE if_ci_atc_check=>ty_finding_code VALUE 'COND_SWTCH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_COND'.

ENDCLASS.


CLASS zcl_skylint_check_063 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural silinsin
    super->constructor(
        VALUE #( description       = 'Prefer COND / SWITCH expressions over multi-branch variable assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_cond
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer COND or SWITCH expression over IF/CASE assignment branches'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    DATA lv_total TYPE i.
    DATA ls_curr TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next1 TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next2 TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next3 TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next4 TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_found_curr TYPE abap_bool.
    DATA lv_found1 TYPE abap_bool.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_found3 TYPE abap_bool.
    DATA lv_found4 TYPE abap_bool.
    DATA ls_tok_if TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_else TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found_tok_if TYPE abap_bool.
    DATA lv_found_tok_else TYPE abap_bool.
    DATA lv_var_if TYPE string.
    DATA lv_var_else TYPE string.

    lv_total = lines( is_procedure-statements ).
    lv_idx = 1.
    WHILE lv_idx <= lv_total.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                     iv_index      = lv_idx
                          IMPORTING es_statement  = ls_curr
                                    ev_found      = lv_found_curr ).
      IF lv_found_curr = abap_false OR ls_curr-keyword <> 'IF' OR lv_idx + 4 > lv_total.
        lv_idx += 1.
        CONTINUE.
      ENDIF.

      " Check pattern: IF (idx+1: COMPUTE lv_var = ) (idx+2: ELSE) (idx+3: COMPUTE lv_var = ) (idx+4: ENDIF)
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                     iv_index      = lv_idx + 1
                          IMPORTING es_statement  = ls_next1
                                    ev_found      = lv_found1 ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                     iv_index      = lv_idx + 2
                          IMPORTING es_statement  = ls_next2
                                    ev_found      = lv_found2 ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                     iv_index      = lv_idx + 3
                          IMPORTING es_statement  = ls_next3
                                    ev_found      = lv_found3 ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                     iv_index      = lv_idx + 4
                          IMPORTING es_statement  = ls_next4
                                    ev_found      = lv_found4 ).
      IF lv_found1 = abap_false OR lv_found2 = abap_false
         OR lv_found3 = abap_false OR lv_found4 = abap_false.
        lv_idx += 1.
        CONTINUE.
      ENDIF.

      IF ls_next1-keyword = 'COMPUTE' AND ls_next2-keyword = 'ELSE'
         AND ls_next3-keyword = 'COMPUTE' AND ls_next4-keyword = 'ENDIF'
         AND lines( ls_next1-tokens ) >= 2 AND lines( ls_next3-tokens ) >= 2.
        get_token_safe( EXPORTING is_statement = ls_next1
                                   iv_index     = 1
                         IMPORTING es_token     = ls_tok_if
                                   ev_found     = lv_found_tok_if ).
        get_token_safe( EXPORTING is_statement = ls_next3
                                   iv_index     = 1
                         IMPORTING es_token     = ls_tok_else
                                   ev_found     = lv_found_tok_else ).
      ENDIF.
      IF ls_next1-keyword = 'COMPUTE' AND ls_next2-keyword = 'ELSE'
         AND ls_next3-keyword = 'COMPUTE' AND ls_next4-keyword = 'ENDIF'
         AND lines( ls_next1-tokens ) >= 2 AND lines( ls_next3-tokens ) >= 2
         AND lv_found_tok_if = abap_true AND lv_found_tok_else = abap_true.
        lv_var_if = to_upper( ls_tok_if-lexeme ).
        lv_var_else = to_upper( ls_tok_else-lexeme ).
        IF lv_var_if = lv_var_else.
          report_statement( is_statement    = ls_curr
                            iv_finding_code = c_finding_codes-prefer_cond ).
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
