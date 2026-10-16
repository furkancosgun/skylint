CLASS zcl_skylint_no_receiving DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_receiving TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITRECEIV',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_receiving TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMITRECV',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RECEIVING'.
    METHODS has_receiving
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_exceptions
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS build_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_receiving IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit RECEIVING in method calls'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-omit_receiving
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Omit RECEIVING keyword; use functional call or omit parameter'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_receiving
                                                                short_text = 'Hoist RECEIVING to LHS' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) = abap_true.
        CONTINUE.
      ENDIF.

      IF has_exceptions( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      IF has_receiving( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_quickfix = build_quickfix( is_statement = <ls_statement>
                                    iv_stmt_idx  = lv_stmt_idx ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-omit_receiving
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD has_receiving.
    rv_has = zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'RECEIVING' ).
  ENDMETHOD.

  METHOD has_exceptions.
    rv_has = zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'EXCEPTIONS' ).
  ENDMETHOD.

  METHOD build_quickfix.
    DATA lv_recv_idx  TYPE i.
    DATA lv_target    TYPE string.
    DATA lv_code      TYPE string.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.

    lv_recv_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'RECEIVING' ).
    IF lv_recv_idx = 0 OR lv_recv_idx + 3 > lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = lv_recv_idx + 3 ).
    IF lv_target IS INITIAL.
      RETURN.
    ENDIF.

    lt_deletions = VALUE #( ( lv_recv_idx )
                            ( lv_recv_idx + 1 )
                            ( lv_recv_idx + 2 )
                            ( lv_recv_idx + 3 ) ).

    lv_code = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_deletions = lt_deletions ).

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_receiving
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( |{ lv_target } = { lv_code }.| ) ) ).
  ENDMETHOD.
ENDCLASS.
