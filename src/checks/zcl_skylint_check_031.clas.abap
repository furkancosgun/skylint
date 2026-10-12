CLASS zcl_skylint_check_031 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unsecure_fae TYPE if_ci_atc_check=>ty_finding_code VALUE 'FAENOCHECK',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_guard TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'FAEGUARD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS extract_fae_table
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_tab) TYPE string.

    METHODS fae_source_name
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

    METHODS has_preceding_check
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_current_idx TYPE i
                iv_tab_name    TYPE string
      RETURNING VALUE(rv_res)  TYPE abap_bool.

    METHODS statement_checks_table
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tab_name   TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_031 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Unsecure FOR ALL ENTRIES (Missing empty itab check)'
            remote_enablement = abap_true
             finding_codes     = VALUE #(
                 ( code     = c_finding_codes-unsecure_fae
                   severity = if_ci_atc_check=>finding_severities-warning
                   text     = 'FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan' ) )
             quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_guard
                                            short_text = 'Add empty-check guard' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx     TYPE i.
    DATA lv_fae_tab TYPE string.
    DATA lv_src_tab TYPE string.
    DATA lv_indent  TYPE string.
    DATA lv_line    TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'SELECT'.
      lv_idx = sy-tabix.
      lv_fae_tab = extract_fae_table( <ls_statement> ).

      IF     lv_fae_tab IS NOT INITIAL
         AND has_preceding_check( it_statements  = is_procedure-statements
                                  iv_current_idx = lv_idx
                                  iv_tab_name    = lv_fae_tab )             = abap_false.
        CLEAR ls_quickfix.
        CLEAR lt_new_code.
        lv_src_tab = fae_source_name( <ls_statement> ).
        IF lv_src_tab IS NOT INITIAL.
          lv_indent = repeat( val = ` `
                              occ = <ls_statement>-position-column ).
          lv_line = zcl_skylint_ast_util=>flatten_statement( <ls_statement> ).
          APPEND |{ lv_indent }IF { lv_src_tab } IS NOT INITIAL.| TO lt_new_code.
          APPEND |{ lv_indent }  { lv_line }.| TO lt_new_code.
          APPEND |{ lv_indent }ENDIF.| TO lt_new_code.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_guard
                                          iv_statement_from = lv_idx
                                          it_new_code       = lt_new_code ).
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-unsecure_fae
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_fae_table.
    DATA lv_name      TYPE string.
    DATA ls_tab_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_tab = ''.
    ls_tab_token = zcl_skylint_ast_util=>get_token_after_sequence(
                       is_statement = is_statement
                       it_expected  = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ) ).
    IF ls_tab_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_name = ls_tab_token-lexeme.
    IF lv_name(1) = '@'.
      lv_name = lv_name+1.
    ENDIF.
    rv_tab = to_upper( lv_name ).
  ENDMETHOD.

  METHOD fae_source_name.
    DATA ls_tab_token TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_name.
    ls_tab_token = zcl_skylint_ast_util=>get_token_after_sequence(
                       is_statement = is_statement
                       it_expected  = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ) ).
    IF ls_tab_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    rv_name = ls_tab_token-lexeme.
    IF rv_name(1) = '@'.
      rv_name = rv_name+1.
    ENDIF.
    IF rv_name IS INITIAL.
      CLEAR rv_name.
    ENDIF.
  ENDMETHOD.

  METHOD has_preceding_check.
    DATA lv_idx  TYPE i.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_res = abap_false.
    lv_idx = iv_current_idx - 1.

    WHILE lv_idx >= 1.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_idx ).
      IF ls_stmt-keyword IS INITIAL.
        lv_idx -= 1.
        CONTINUE.
      ENDIF.
      IF statement_checks_table( is_statement = ls_stmt
                                 iv_tab_name  = iv_tab_name ) = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
      lv_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD statement_checks_table.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_has_tab   TYPE abap_bool.
    DATA lv_has_check TYPE abap_bool.
    DATA lv_clean_tok TYPE string.
    DATA lv_tab_body  TYPE string.

    rv_res = abap_false.
    lv_has_tab = abap_false.
    lv_has_check = abap_false.
    lv_tab_body = |{ iv_tab_name }[]|.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_clean_tok = to_upper( ls_tok-lexeme ).
      IF lv_clean_tok CP '@*'.
        lv_clean_tok = lv_clean_tok+1.
      ENDIF.

      IF lv_clean_tok = iv_tab_name OR lv_clean_tok = lv_tab_body.
        lv_has_tab = abap_true.
      ENDIF.

      IF     ls_tok-references IS INITIAL
         AND (    lv_clean_tok = 'INITIAL'
               OR lv_clean_tok = 'LINES('
               OR lv_clean_tok = 'LINE_EXISTS(' ).
        lv_has_check = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_has_tab = abap_true AND lv_has_check = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
