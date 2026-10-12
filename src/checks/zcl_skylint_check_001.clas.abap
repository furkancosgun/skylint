CLASS zcl_skylint_check_001 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        describe_lines TYPE if_ci_atc_check=>ty_finding_code VALUE 'DESCRIBELN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_lines TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOLINES',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_001 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-describe_lines
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Use lines( ) function instead of DESCRIBE TABLE ... LINES' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_lines
                                                                short_text = 'Use lines( ) function' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_table TYPE abap_bool.
    DATA lv_has_lines TYPE abap_bool.
    DATA lv_has_other TYPE abap_bool.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_tok_idx   TYPE i.
    DATA lv_table_idx TYPE i.
    DATA lv_lines_idx TYPE i.
    DATA lv_table     TYPE string.
    DATA lv_target    TYPE string.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'DESCRIBE'.
      lv_stmt_idx = sy-tabix.
      lv_has_table = abap_false.
      lv_has_lines = abap_false.
      lv_has_other = abap_false.
      lv_table_idx = 0.
      lv_lines_idx = 0.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_tok_idx = sy-tabix.
        IF <ls_token>-references IS NOT INITIAL.
          CONTINUE.
        ENDIF.
        CASE <ls_token>-lexeme.
          WHEN 'TABLE'.
            lv_has_table = abap_true.
            lv_table_idx = lv_tok_idx.
          WHEN 'LINES'.
            lv_has_lines = abap_true.
            lv_lines_idx = lv_tok_idx.
          WHEN 'KIND' OR 'OCCURS'.
            lv_has_other = abap_true.
        ENDCASE.
      ENDLOOP.

      IF lv_has_table = abap_true AND lv_has_lines = abap_true AND lv_has_other = abap_false.
        CLEAR ls_quickfix.
        lv_table = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                           iv_index     = lv_table_idx + 1 ).
        lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                            iv_index     = lv_lines_idx + 1 ).
        IF lv_table IS NOT INITIAL AND lv_target IS NOT INITIAL.
          lv_line = |{ lv_target } = lines( { lv_table } ).|.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_lines
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line ) ) ).
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-describe_lines
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
