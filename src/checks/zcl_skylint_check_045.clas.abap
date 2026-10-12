CLASS zcl_skylint_check_045 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_auth_check TYPE if_ci_atc_check=>ty_finding_code VALUE 'AUTH_CHECK',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_auth_check TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADDAUTH',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_call_transaction
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS has_inline_auth_check
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_045 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Call Transaction Authority Check'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-missing_auth_check
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'CALL TRANSACTION must be protected with AUTHORITY-CHECK' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_auth_check
                                                                short_text = 'Add WITH AUTHORITY-CHECK' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA lv_flat     TYPE string.
    DATA lv_tcode    TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CALL'.
      lv_stmt_idx = sy-tabix.
      IF    is_call_transaction( <ls_statement> )   = abap_false
         OR has_inline_auth_check( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lv_flat = zcl_skylint_ast_util=>flatten_statement( <ls_statement> ).
      lv_tcode = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = 3 ).
      IF lv_tcode IS NOT INITIAL.
        REPLACE FIRST OCCURRENCE OF lv_tcode IN lv_flat WITH |{ lv_tcode } WITH AUTHORITY-CHECK|.
        IF sy-subrc = 0.
          lv_line = |{ lv_flat }.|.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_auth_check
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line ) ) ).
        ENDIF.
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-missing_auth_check
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_call_transaction.
    rv_res = xsdbool( zcl_skylint_ast_util=>find_token_sequence(
                          is_statement = is_statement
                          it_expected  = VALUE #( ( `CALL` ) ( `TRANSACTION` ) ) ) > 0 ).
  ENDMETHOD.

  METHOD has_inline_auth_check.
    rv_res = xsdbool( zcl_skylint_ast_util=>find_token_sequence(
                          is_statement = is_statement
                          it_expected  = VALUE #( ( `WITH` ) ( `AUTHORITY-CHECK` ) ) ) > 0 ).
  ENDMETHOD.
ENDCLASS.
