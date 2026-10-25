CLASS zcl_skylint_pref_str_tmpl DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_template TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_STMPL',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_template TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOTEMPLATE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_STR_TMPL'.

    METHODS is_byte_mode
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_byte_mode) TYPE abap_bool.

    METHODS build_template
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_str_tmpl IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer string templates over CONCATENATE'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_template
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Use string template |...| instead of CONCATENATE'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_template
                                                short_text = 'Use |...| template' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'CONCATENATE'.
        CONTINUE.
      ENDIF.
      IF is_byte_mode( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lv_line = build_template( <ls_statement> ).
      IF lv_line IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_template
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_template
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_byte_mode.
    rv_byte_mode = zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `BYTE` ) ( `MODE` ) ) ).
  ENDMETHOD.

  METHOD build_template.
    DATA ls_target TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_target TYPE string.
    DATA ls_sep    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_sep    TYPE string.
    DATA ls_table  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_into   TYPE i.
    DATA lv_idx    TYPE i.
    DATA lt_ops    TYPE string_table.
    DATA lv_tpl    TYPE string.
    FIELD-SYMBOLS <lv_op> TYPE string.

    CLEAR rv_line.
    ls_target = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'INTO' ).
    lv_target = ls_target-lexeme.
    IF lv_target IS INITIAL.
      RETURN.
    ENDIF.

    ls_sep = zcl_skylint_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                             it_expected  = VALUE #( ( `SEPARATED` ) ( `BY` ) ) ).
    lv_sep = ls_sep-lexeme.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `LINES` ) ( `OF` ) ) ) = abap_true.
      ls_table = zcl_skylint_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                                 it_expected  = VALUE #( ( `LINES` ) ( `OF` ) ) ).
      IF lv_sep IS INITIAL.
        rv_line = |{ lv_target } = concat_lines_of( table = { ls_table-lexeme } ).|.
      ELSE.
        rv_line = |{ lv_target } = concat_lines_of( table = { ls_table-lexeme } sep = { lv_sep } ).|.
      ENDIF.
      RETURN.
    ENDIF.

    lv_into = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                iv_lexeme    = 'INTO' ).
    IF lv_into <= 2.
      RETURN.
    ENDIF.

    lv_idx = 2.
    WHILE lv_idx < lv_into.
      APPEND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = lv_idx ) TO lt_ops.
      lv_idx += 1.
    ENDWHILE.

    IF lt_ops IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR lv_tpl.
    LOOP AT lt_ops ASSIGNING <lv_op>.
      IF sy-tabix > 1 AND lv_sep IS NOT INITIAL.
        lv_tpl = |{ lv_tpl }\{ { lv_sep } \}|.
      ENDIF.
      lv_tpl = |{ lv_tpl }\{ { <lv_op> } \}|.
    ENDLOOP.

    rv_line = |{ lv_target } = \|{ lv_tpl }\|.|.
  ENDMETHOD.
ENDCLASS.
