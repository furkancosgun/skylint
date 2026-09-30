CLASS zcl_skylint_check_095 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        needless_clear TYPE if_ci_atc_check=>ty_finding_code VALUE 'NEEDLES_CL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NEEDLESS_CLEAR'.

    METHODS is_same_data_decl
      IMPORTING is_prev TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_var_name TYPE string
      RETURNING VALUE(rv_same) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_check_095 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural silinsin
    super->constructor(
        VALUE #( description       = 'Detect needless CLEAR on newly declared variable or before exit'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-needless_clear
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Variables are initialized automatically; avoid CLEAR after DATA or before exit'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lv_var_name TYPE string.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_prev TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_stmt_found TYPE abap_bool.
    DATA lv_prev_found TYPE abap_bool.
    DATA lv_next_found TYPE abap_bool.
    DATA lv_tok_found TYPE abap_bool.
    DATA lv_is_after_data TYPE abap_bool.

    lv_count = lines( is_procedure-statements ).
    lv_idx = 1.

    WHILE lv_idx <= lv_count.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_idx
                          IMPORTING es_statement  = ls_stmt
                                    ev_found      = lv_stmt_found ).
      IF lv_stmt_found = abap_false.
        lv_idx += 1.
        CONTINUE.
      ENDIF.
      CASE ls_stmt-keyword.
        WHEN 'CLEAR'.
          get_token_safe( EXPORTING is_statement = ls_stmt
                                    iv_index     = 2
                          IMPORTING es_token     = ls_tok
                                    ev_found     = lv_tok_found ).
          IF lv_tok_found = abap_false.
            lv_idx += 1.
            CONTINUE.
          ENDIF.
          lv_var_name = to_upper( ls_tok-lexeme ).

          " Case 1: Immediately after DATA declaration
          lv_is_after_data = abap_false.
          IF lv_idx > 1.
            get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                          iv_index      = lv_idx - 1
                                IMPORTING es_statement  = ls_prev
                                          ev_found      = lv_prev_found ).
            IF lv_prev_found = abap_true.
              lv_is_after_data = is_same_data_decl( is_prev     = ls_prev
                                                    iv_var_name = lv_var_name ).
            ENDIF.
          ENDIF.
          IF lv_is_after_data = abap_true.
            report_statement( is_statement    = ls_stmt
                              iv_finding_code = c_finding_codes-needless_clear ).
            lv_idx += 1.
            CONTINUE.
          ENDIF.

          " Case 2: Immediately before ENDMETHOD
          IF lv_idx < lv_count.
            get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                          iv_index      = lv_idx + 1
                                IMPORTING es_statement  = ls_next
                                          ev_found      = lv_next_found ).
            IF lv_next_found = abap_true AND ls_next-keyword = 'ENDMETHOD'.
              report_statement( is_statement    = ls_stmt
                                iv_finding_code = c_finding_codes-needless_clear ).
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          lv_idx += 1.
          CONTINUE.
      ENDCASE.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_same_data_decl.
    rv_same = abap_false.
    IF is_prev-keyword <> 'DATA'.
      RETURN.
    ENDIF.
    IF matches_token_at( is_statement = is_prev
                         iv_index     = 2
                         iv_expected  = iv_var_name ) = abap_true.
      rv_same = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
