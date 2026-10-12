CLASS zcl_skylint_check_079 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        param_escape TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAM_ESCP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        unescape TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'UNESCAPE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_079 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect unnecessary exclamation mark parameter escape (!iv_param)'
                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-param_escape
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Escape params with ! only on keyword clash' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-unescape
                                                                short_text = 'Remove ! escape' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_tok_idx  TYPE i.
    DATA lv_lexeme   TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_check_base=>ty_token_overrides.
    DATA lt_deletions TYPE zcl_skylint_check_base=>ty_token_deletions.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      lv_stmt_idx = sy-tabix.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        lv_tok_idx = sy-tabix.
        IF <ls_tok>-lexeme CP '!*'.
          CLEAR ls_quickfix.
          CLEAR lt_overrides.
          CLEAR lt_deletions.
          lv_lexeme = <ls_tok>-lexeme.
          IF lv_lexeme = '!'.
            lt_deletions = VALUE #( ( lv_tok_idx ) ).
          ELSE.
            lt_overrides = VALUE #( ( index  = lv_tok_idx
                                      lexeme = lv_lexeme+1 ) ).
          ENDIF.
          lv_line = flatten_statement( is_statement = <ls_stmt>
                                       it_overrides = lt_overrides
                                       it_deletions = lt_deletions ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-unescape
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line && '.' ) ) ).
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-param_escape
                            is_quickfix     = ls_quickfix ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
