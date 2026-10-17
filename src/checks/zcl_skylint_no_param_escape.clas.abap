CLASS zcl_skylint_no_param_escape DEFINITION
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

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PARAM_ESCAPE'.

    METHODS build_unescape_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

    METHODS find_escaped_token_index
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_idx) TYPE i.
ENDCLASS.


CLASS zcl_skylint_no_param_escape IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect unnecessary exclamation mark parameter escape (!iv_param)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-param_escape
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Escape params with ! only on keyword clash'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-unescape
                                                short_text = 'Remove ! escape' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      ls_quickfix = build_unescape_quickfix( is_statement = <ls_stmt>
                                             iv_stmt_idx  = sy-tabix ).
      IF ls_quickfix IS NOT INITIAL.
        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-param_escape
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_unescape_quickfix.
    DATA lv_tok_idx   TYPE i.
    DATA lv_lexeme    TYPE string.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.

    CLEAR rs_quickfix.
    lv_tok_idx = find_escaped_token_index( is_statement ).
    IF lv_tok_idx = 0.
      RETURN.
    ENDIF.

    lv_lexeme = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = lv_tok_idx ).
    lt_overrides = VALUE #( ( index  = lv_tok_idx
                              lexeme = lv_lexeme+1 ) ).

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = lt_overrides
                                                       it_deletions = lt_deletions ).

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-unescape
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
  ENDMETHOD.

  METHOD find_escaped_token_index.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_idx = 0.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-lexeme CP '!*'.
        rv_idx = sy-tabix.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
