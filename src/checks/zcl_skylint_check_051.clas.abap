CLASS zcl_skylint_check_051 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_insert TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INSRT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_insert TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOINSERT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_051 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer INSERT ... INTO TABLE over APPEND for table safety'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code     = c_finding_codes-prefer_insert
                                                severity = if_ci_atc_check=>finding_severities-warning
                                                text     = 'Prefer INSERT ... INTO TABLE over APPEND' ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_insert
                                                short_text = 'Use INSERT INTO TABLE' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_count    TYPE i.
    DATA lv_wa       TYPE string.
    DATA lv_itab     TYPE string.
    DATA lv_src      TYPE string.
    DATA lv_dst      TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'APPEND'.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.
      lv_count = zcl_skylint_ast_util=>token_count( <ls_statement> ).
      IF     lv_count = 4
         AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 3
                                                     iv_expected  = `TO` )         = abap_true.
        lv_wa = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                        iv_index     = 2 ).
        lv_itab = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                          iv_index     = 4 ).
        lv_line = |INSERT { lv_wa } INTO TABLE { lv_itab }.|.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_insert
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ELSEIF     lv_count = 6
             AND zcl_skylint_ast_util=>match_token_sequence( is_statement   = <ls_statement>
                                                             it_expected    = VALUE #( ( `LINES` ) ( `OF` ) )
                                                             iv_start_index = 2 ) = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 5
                                                         iv_expected  = `TO` ) = abap_true.
        lv_src = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = 4 ).
        lv_dst = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = 6 ).
        lv_line = |INSERT LINES OF { lv_src } INTO TABLE { lv_dst }.|.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_insert
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ELSEIF     lv_count = 5
             AND zcl_skylint_ast_util=>match_token_sequence( is_statement   = <ls_statement>
                                                             it_expected    = VALUE #( ( `INITIAL` ) ( `LINE` ) ( `TO` ) )
                                                             iv_start_index = 2 ) = abap_true.
        lv_dst = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = 5 ).
        lv_line = |INSERT INITIAL LINE INTO TABLE { lv_dst }.|.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_insert
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_insert
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
