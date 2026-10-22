CLASS zcl_skylint_pref_expand_macro DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        expand_macro TYPE if_ci_atc_check=>ty_finding_code VALUE 'EXPMACRO',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        expand_macro TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'EXPMACRO',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EXPAND_MACROS'.

    TYPES:
      BEGIN OF ty_macro_stmt,
        tokens TYPE if_ci_atc_source_code_provider=>ty_tokens,
      END OF ty_macro_stmt,
      ty_macro_stmts TYPE STANDARD TABLE OF ty_macro_stmt WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_macro,
        name       TYPE string,
        statements TYPE ty_macro_stmts,
      END OF ty_macro,
      ty_macros TYPE STANDARD TABLE OF ty_macro WITH EMPTY KEY.

    METHODS build_macro_expansion
      IMPORTING is_call         TYPE if_ci_atc_source_code_provider=>ty_statement
                is_macro        TYPE ty_macro
      RETURNING VALUE(rt_lines) TYPE zcl_skylint_check_base=>ty_code_lines.

    METHODS get_macro_arg_lexeme
      IMPORTING is_call        TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tok_text    TYPE string
      RETURNING VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_expand_macro IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Expand Macro Calls'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-expand_macro
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Macro call should be expanded into explicit statements'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-expand_macro
                                                short_text = 'Expand macro into explicit statements' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_macros     TYPE ty_macros.
    DATA ls_macro      TYPE ty_macro.
    DATA ls_macro_stmt TYPE ty_macro_stmt.
    DATA lv_in_macro   TYPE abap_bool.
    DATA lv_stmt_idx   TYPE i.
    DATA lt_expansion  TYPE zcl_skylint_check_base=>ty_code_lines.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lv_macro_name TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_macro>     TYPE ty_macro.

    lv_in_macro = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF <ls_statement>-keyword = 'DEFINE'.
        lv_in_macro = abap_true.
        CLEAR ls_macro.
        ls_macro-name = to_upper( zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                                          iv_index     = 2 ) ).
        CONTINUE.
      ENDIF.

      IF lv_in_macro = abap_true.
        IF <ls_statement>-keyword = 'END-OF-DEFINITION'.
          lv_in_macro = abap_false.
          IF ls_macro-name IS NOT INITIAL.
            APPEND ls_macro TO lt_macros.
          ENDIF.
        ELSE.
          CLEAR ls_macro_stmt.
          ls_macro_stmt-tokens = <ls_statement>-tokens.
          APPEND ls_macro_stmt TO ls_macro-statements.
        ENDIF.
        CONTINUE.
      ENDIF.

      lv_macro_name = to_upper( zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                                        iv_index     = 1 ) ).
      IF lv_macro_name IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_macros ASSIGNING <ls_macro> WITH KEY name = lv_macro_name.
      IF sy-subrc = 0.
        lt_expansion = build_macro_expansion( is_call  = <ls_statement>
                                              is_macro = <ls_macro> ).
        IF lt_expansion IS NOT INITIAL.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-expand_macro
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = lt_expansion ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-expand_macro
                            is_quickfix     = ls_quickfix ).
        ELSE.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-expand_macro ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_macro_expansion.
    DATA lv_indent     TYPE string.
    DATA lv_stmt_text  TYPE string.
    DATA lv_tok_text   TYPE string.
    FIELD-SYMBOLS <ls_stmt>  TYPE ty_macro_stmt.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_call-position-column > 0.
      lv_indent = repeat( val = ` `
                          occ = is_call-position-column ).
    ENDIF.

    LOOP AT is_macro-statements ASSIGNING <ls_stmt>.
      CLEAR lv_stmt_text.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_token>.
        lv_tok_text = get_macro_arg_lexeme( is_call     = is_call
                                            iv_tok_text = <ls_token>-lexeme ).

        IF lv_stmt_text IS INITIAL.
          lv_stmt_text = lv_tok_text.
        ELSE.
          lv_stmt_text = |{ lv_stmt_text } { lv_tok_text }|.
        ENDIF.
      ENDLOOP.

      IF lv_stmt_text IS NOT INITIAL.
        APPEND |{ lv_indent }{ lv_stmt_text }.| TO rt_lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_macro_arg_lexeme.
    DATA lv_prefix  TYPE string.
    DATA lv_arg_idx TYPE i.
    DATA ls_arg     TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_text = iv_tok_text.
    IF strlen( iv_tok_text ) < 2.
      RETURN.
    ENDIF.

    lv_prefix = substring( val = iv_tok_text
                           off = 0
                           len = 1 ).
    IF lv_prefix <> '&'.
      RETURN.
    ENDIF.

    TRY.
        lv_arg_idx = substring( val = iv_tok_text
                                off = 1
                                len = 1 ).
        IF lv_arg_idx > 0.
          ls_arg = zcl_skylint_ast_util=>get_token( is_statement = is_call
                                                    iv_index     = lv_arg_idx + 1 ).
          IF ls_arg-lexeme IS NOT INITIAL.
            rv_text = ls_arg-lexeme.
          ENDIF.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
