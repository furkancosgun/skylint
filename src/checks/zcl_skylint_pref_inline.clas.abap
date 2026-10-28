CLASS zcl_skylint_pref_inline DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_inline TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INLIN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        inline_decl TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'INL_DECL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_INLINE'.

    METHODS statement_has_var
      IMPORTING iv_from_idx   TYPE i DEFAULT 1
                is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_full_name  TYPE string
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS build_into_quickfix
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_var               TYPE string
                iv_decl_idx          TYPE i
                iv_stmt_idx          TYPE i
      RETURNING VALUE(rt_quickfixes) TYPE zcl_skylint_check_base=>ty_quickfixes.

    METHODS first_use_is_pure_write
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_var           TYPE string
                iv_full_name     TYPE string
                iv_decl_idx      TYPE i
                iv_stmt_idx      TYPE i
      EXPORTING ev_is_pure_write TYPE abap_bool
                et_quickfixes    TYPE zcl_skylint_check_base=>ty_quickfixes.

ENDCLASS.


CLASS zcl_skylint_pref_inline IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer Inline Declarations'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_inline
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer inline declaration over separate DATA and assignment'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-inline_decl
                                                                short_text = 'Declare inline' ) ) ) ).
  ENDMETHOD.

  METHOD statement_has_var.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM iv_from_idx.
      LOOP AT <ls_token>-references TRANSPORTING NO FIELDS
           WHERE     kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                 AND full_name = iv_full_name.
        rv_has = abap_true.
        RETURN.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_into_quickfix.
    DATA lv_into_idx   TYPE i.
    DATA lv_target_idx TYPE i.
    DATA lv_line       TYPE string.
    DATA ls_qf_del     TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_qf_rep     TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_target_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rt_quickfixes.

    lv_into_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'INTO' ).
    IF lv_into_idx <= 0 OR lv_into_idx >= lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    lv_target_idx = lv_into_idx + 1.
    ls_target_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = lv_target_idx ).
    IF ls_target_tok-lexeme <> iv_var.
      RETURN.
    ENDIF.

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = VALUE #( ( index  = lv_target_idx
                                                                                 lexeme = |DATA({ iv_var })| ) )
                                                       iv_suffix    = `.` ).

    ls_qf_del = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-inline_decl
                                  iv_statement_from = iv_decl_idx
                                  it_new_code       = VALUE #( ) ).
    ls_qf_rep = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-inline_decl
                                  iv_statement_from = iv_stmt_idx
                                  it_new_code       = VALUE #( ( lv_line ) ) ).
    rt_quickfixes = VALUE #( ( ls_qf_del ) ( ls_qf_rep ) ).
  ENDMETHOD.

  METHOD first_use_is_pure_write.
    DATA lv_target   TYPE string.
    DATA lv_is_asgn  TYPE abap_bool.
    DATA lv_eq_idx   TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_qf_del   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_qf_rep   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_into_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_src_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_is_pure_write = abap_false.
    CLEAR et_quickfixes.

    CASE is_statement-keyword.
      WHEN 'COMPUTE'.
        IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                             iv_lexeme    = '?=' ) > 0.
          RETURN.
        ENDIF.

        zcl_skylint_ast_util=>parse_assignment( EXPORTING is_statement     = is_statement
                                                IMPORTING ev_target        = lv_target
                                                          ev_is_assignment = lv_is_asgn ).
        IF lv_is_asgn = abap_false OR lv_target <> iv_var.
          RETURN.
        ENDIF.

        IF line_exists( is_statement-tokens[ lexeme = '$(' ] ).
          RETURN.
        ENDIF.

        lv_eq_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = '=' ).
        IF lv_eq_idx <= 0.
          RETURN.
        ENDIF.

        IF statement_has_var( iv_from_idx  = lv_eq_idx + 1
                              is_statement = is_statement
                              iv_full_name = iv_full_name ).
          RETURN.
        ENDIF.

        ev_is_pure_write = abap_true.
        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                           it_overrides = VALUE #( ( index  = 1
                                                                                     lexeme = |DATA({ iv_var })| ) )
                                                           iv_suffix    = `.` ).
        ls_qf_del = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-inline_decl
                                      iv_statement_from = iv_decl_idx
                                      it_new_code       = VALUE #( ) ).
        ls_qf_rep = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-inline_decl
                                      iv_statement_from = iv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line ) ) ).
        et_quickfixes = VALUE #( ( ls_qf_del ) ( ls_qf_rep ) ).

      WHEN 'READ'.
        ls_src_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'TABLE' ).
        IF ls_src_tok-lexeme = iv_var.
          RETURN.
        ENDIF.
        ls_into_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                             iv_lexeme    = 'INTO' ).
        IF ls_into_tok-lexeme = iv_var.
          ev_is_pure_write = abap_true.
          et_quickfixes = build_into_quickfix( is_statement = is_statement
                                               iv_var       = iv_var
                                               iv_decl_idx  = iv_decl_idx
                                               iv_stmt_idx  = iv_stmt_idx ).
        ENDIF.
      WHEN 'LOOP'.
        ls_src_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'AT' ).
        IF ls_src_tok-lexeme = iv_var.
          RETURN.
        ENDIF.
        ls_into_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                             iv_lexeme    = 'INTO' ).
        IF ls_into_tok-lexeme = iv_var.
          ev_is_pure_write = abap_true.
          et_quickfixes = build_into_quickfix( is_statement = is_statement
                                               iv_var       = iv_var
                                               iv_decl_idx  = iv_decl_idx
                                               iv_stmt_idx  = iv_stmt_idx ).
        ENDIF.
      WHEN 'CATCH'.
        ls_into_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                             iv_lexeme    = 'INTO' ).
        IF ls_into_tok-lexeme = iv_var.
          ev_is_pure_write = abap_true.
          et_quickfixes = build_into_quickfix( is_statement = is_statement
                                               iv_var       = iv_var
                                               iv_decl_idx  = iv_decl_idx
                                               iv_stmt_idx  = iv_stmt_idx ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD check.
    DATA lv_tabix         TYPE i.
    DATA lv_stmt_idx      TYPE i.
    DATA lv_var           TYPE string.
    DATA lv_depth         TYPE i.
    DATA lv_has_var       TYPE abap_bool.
    DATA lv_is_pure_write TYPE abap_bool.
    DATA ls_ref           TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lt_quickfixes    TYPE zcl_skylint_check_base=>ty_quickfixes.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_stmt>      TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_tabix = sy-tabix.
      IF <ls_statement>-keyword <> 'DATA'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `BEGIN` ) ( `OF` ) ) ).
        CONTINUE.
      ENDIF.

      lv_var = zcl_skylint_ast_util=>get_declaration_name( <ls_statement> ).
      IF lv_var IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = zcl_skylint_ast_util=>get_declaration_token( <ls_statement> )
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF ls_ref-full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_depth = 0.
      lv_stmt_idx = lv_tabix + 1.

      WHILE lv_stmt_idx <= lines( is_procedure-statements ).
        ASSIGN is_procedure-statements[ lv_stmt_idx ] TO <ls_stmt>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        CASE <ls_stmt>-keyword.
          WHEN 'ENDIF'
            OR 'ENDWHILE'
            OR 'ENDDO'
            OR 'ENDLOOP'
            OR 'ENDCASE'
            OR 'ENDTRY'.
            IF lv_depth > 0.
              lv_depth -= 1.
            ENDIF.
            lv_stmt_idx += 1.
            CONTINUE.
        ENDCASE.

        lv_has_var = statement_has_var( is_statement = <ls_stmt>
                                        iv_full_name = ls_ref-full_name ).

        IF lv_has_var = abap_false.
          CASE <ls_stmt>-keyword.
            WHEN 'IF'
              OR 'WHILE'
              OR 'DO'
              OR 'LOOP'
              OR 'CASE'
              OR 'TRY'
              OR 'PROVIDE'.
              lv_depth += 1.
          ENDCASE.
          lv_stmt_idx += 1.
          CONTINUE.
        ENDIF.

        IF lv_depth = 0.
          CLEAR lt_quickfixes.
          first_use_is_pure_write( EXPORTING is_statement     = <ls_stmt>
                                             iv_var           = lv_var
                                             iv_full_name     = ls_ref-full_name
                                             iv_decl_idx      = lv_tabix
                                             iv_stmt_idx      = lv_stmt_idx
                                   IMPORTING ev_is_pure_write = lv_is_pure_write
                                             et_quickfixes    = lt_quickfixes ).

          IF lv_is_pure_write = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-prefer_inline
                              it_quickfixes   = lt_quickfixes ).
          ENDIF.
        ENDIF.
        EXIT.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.