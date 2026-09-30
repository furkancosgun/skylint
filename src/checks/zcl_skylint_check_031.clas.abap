CLASS zcl_skylint_check_031 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unsecure_fae TYPE if_ci_atc_check=>ty_finding_code VALUE 'FAENOCHECK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'FAE_NO_CHECK'.

    METHODS extract_fae_table
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_tab) TYPE string.

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
        VALUE #( description       = 'Unsecure FOR ALL ENTRIES (Missing empty itab check)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unsecure_fae
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx     TYPE i.
    DATA lv_fae_tab TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'SELECT'.
      lv_idx = sy-tabix.
      lv_fae_tab = extract_fae_table( <ls_statement> ).

      IF     lv_fae_tab IS NOT INITIAL
         AND has_preceding_check( it_statements  = is_procedure-statements
                                  iv_current_idx = lv_idx
                                  iv_tab_name    = lv_fae_tab )             = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-unsecure_fae ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_fae_table.
    DATA lv_pos TYPE i.
    DATA lv_name TYPE string.
    DATA lt_expected TYPE ty_token_lexemes.
    DATA ls_tab_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found TYPE abap_bool.

    rv_tab = ''.
    lt_expected = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ).
    lv_pos = find_token_sequence( is_statement = is_statement
                                                it_expected  = lt_expected ).
    IF lv_pos = 0.
      RETURN.
    ENDIF.
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = lv_pos + 4
                    IMPORTING es_token     = ls_tab_token
                              ev_found     = lv_found ).
    IF lv_found = abap_false.
      RETURN.
    ENDIF.
    lv_name = ls_tab_token-lexeme.
    IF lv_name(1) = '@'.
      lv_name = lv_name+1.
    ENDIF.
    rv_tab = to_upper( lv_name ).
  ENDMETHOD.

  METHOD has_preceding_check.
    DATA lv_idx TYPE i.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_found TYPE abap_bool.

    rv_res = abap_false.
    lv_idx = iv_current_idx - 1.

    WHILE lv_idx >= 1.
      get_statement_safe( EXPORTING it_statements = it_statements
                                    iv_index      = lv_idx
                          IMPORTING es_statement  = ls_stmt
                                    ev_found      = lv_found ).
      IF lv_found = abap_false.
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

    rv_res = abap_false.
    lv_has_tab = abap_false.
    lv_has_check = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_clean_tok = to_upper( ls_tok-lexeme ).
      "TODO bu kosul neden var?
      IF lv_clean_tok(1) = '@'.
        lv_clean_tok = lv_clean_tok+1.
      ENDIF.

      "TODO cp yanlis bir yaklasim cp olmayacak veya lv_cleantok + [] headerline ifadesi olabilir
      IF lv_clean_tok = iv_tab_name OR lv_clean_tok CP |*{ iv_tab_name }*|.
        lv_has_tab = abap_true.
      ENDIF.

      "TODO lines ve line_exists compiler seviyesinde nasil geliyor bakmak lazim lines( olabilir
      IF lv_clean_tok = 'INITIAL' OR lv_clean_tok = 'LINES' OR lv_clean_tok = 'LINE_EXISTS'.
        lv_has_check = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_has_tab = abap_true AND lv_has_check = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
