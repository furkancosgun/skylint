CLASS zcl_skylint_no_client_spec DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        client_spec TYPE if_ci_atc_check=>ty_finding_code VALUE 'CLIENT_SPE',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        drop_client TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DROPCLNT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CLIENT_SPEC'.
ENDCLASS.


CLASS zcl_skylint_no_client_spec IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid USING CLIENT or CLIENT SPECIFIED in ABAP SQL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-client_spec
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid explicit client specification in ABAP SQL'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-drop_client
                                                                short_text = 'Remove client specification' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_seq_idx   TYPE i.
    DATA lv_count     TYPE i.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE    keyword = 'SELECT' OR keyword = 'UPDATE' OR keyword = 'MODIFY'
               OR keyword = 'DELETE' OR keyword = 'INSERT'.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.
      CLEAR lt_deletions.
      lv_count = zcl_skylint_ast_util=>token_count( <ls_statement> ).
      lv_seq_idx = zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                              it_expected  = VALUE #( ( `USING` )
                                                                                      ( `CLIENT` ) ) ).
      IF lv_seq_idx > 0 AND lv_count >= lv_seq_idx + 2.
        lt_deletions = VALUE #( ( lv_seq_idx )
                                ( lv_seq_idx + 1 )
                                ( lv_seq_idx + 2 ) ).
      ELSE.
        lv_seq_idx = zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                                it_expected  = VALUE #( ( `CLIENT` )
                                                                                        ( `SPECIFIED` ) ) ).
        IF lv_seq_idx > 0 AND lv_count >= lv_seq_idx + 1.
          lt_deletions = VALUE #( ( lv_seq_idx )
                                  ( lv_seq_idx + 1 ) ).
        ENDIF.
      ENDIF.
      IF lt_deletions IS NOT INITIAL.
        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                           it_deletions = lt_deletions ).
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-drop_client
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
      ENDIF.
      IF    zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                       it_expected  = VALUE #( ( `USING` ) ( `CLIENT` ) ) ) > 0
         OR zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                       it_expected  = VALUE #( ( `CLIENT` )
                                                                               ( `SPECIFIED` ) ) )          > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-client_spec
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
