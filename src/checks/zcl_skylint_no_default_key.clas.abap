CLASS zcl_skylint_no_default_key DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        default_key TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEFAULTKEY',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_empty_key TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USEEMPTY',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEFAULT_KEY'.
ENDCLASS.


CLASS zcl_skylint_no_default_key IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-default_key
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid WITH DEFAULT KEY; specify EMPTY KEY or explicit key'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_empty_key
                                                                short_text = 'Replace with EMPTY KEY' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_idx       TYPE i.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CASE <ls_statement>-keyword.
        WHEN 'TYPES' OR 'DATA' OR 'STATICS' OR 'CLASS-DATA' OR 'FIELD-SYMBOL'.
          lv_idx = zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                              it_expected  = VALUE #( ( `DEFAULT` ) ( `KEY` ) ) ).
          IF lv_idx > 0.
            CLEAR: lt_overrides,
                   ls_quickfix.
            lt_overrides = VALUE #( ( index  = lv_idx
                                      lexeme = 'EMPTY' ) ).
            lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                               it_overrides = lt_overrides ).
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_empty_key
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).

            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-default_key
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
