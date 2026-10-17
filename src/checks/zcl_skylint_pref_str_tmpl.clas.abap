CLASS zcl_skylint_pref_str_tmpl DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_template TYPE if_ci_atc_check=>ty_finding_code VALUE 'CONCATSTR',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_template TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOTEMPLATE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'STR_TMPL'.

    DATA mv_allow_in_byte_mode TYPE abap_bool VALUE abap_false.

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
                 attributes        = VALUE #( ( name  = 'ALLOW_IN_BYTE_MODE'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_allow_in_byte_mode ) ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_template
                                                short_text = 'Use |...| template' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CONCATENATE'.
      lv_stmt_idx = sy-tabix.
      IF mv_allow_in_byte_mode = abap_true AND is_byte_mode( <ls_statement> ) = abap_true.
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
    DATA lv_count   TYPE i.
    DATA lv_idx     TYPE i.
    DATA lv_into    TYPE i.
    DATA lv_target  TYPE string.
    DATA lv_sep     TYPE string.
    DATA lv_has_sep TYPE abap_bool.
    DATA lv_tpl     TYPE string.
    DATA lv_first   TYPE abap_bool.
    DATA lt_ops     TYPE string_table.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <lv_op>  TYPE string.

    CLEAR rv_line.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 4.
      RETURN.
    ENDIF.

    lv_into = 0.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      IF lv_idx > 1 AND <ls_tok>-lexeme = 'INTO'.
        lv_into = lv_idx.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_into = 0 OR lv_into + 1 > lv_count.
      RETURN.
    ENDIF.

    lt_ops = VALUE #( ).
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      IF lv_idx > 1 AND lv_idx < lv_into.
        IF <ls_tok>-lexeme IS INITIAL.
          RETURN.
        ENDIF.
        APPEND <ls_tok>-lexeme TO lt_ops.
      ENDIF.
    ENDLOOP.
    IF lt_ops IS INITIAL.
      RETURN.
    ENDIF.

    lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = lv_into + 1 ).
    IF lv_target IS INITIAL.
      RETURN.
    ENDIF.

    lv_has_sep = abap_false.
    IF lv_into + 1 < lv_count.
      IF    lv_count <> lv_into + 4
         OR zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                    iv_index     = lv_into + 2 ) <> 'SEPARATED'
         OR zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                    iv_index     = lv_into + 3 ) <> 'BY'.
        RETURN.
      ENDIF.
      lv_sep = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                       iv_index     = lv_into + 4 ).
      IF lv_sep IS INITIAL.
        RETURN.
      ENDIF.
      lv_has_sep = abap_true.
    ENDIF.

    IF     lines( lt_ops ) = 3
       AND lt_ops[ 1 ]     = 'LINES'
       AND lt_ops[ 2 ]     = 'OF'.
      IF lv_has_sep = abap_false.
        RETURN.
      ENDIF.
      rv_line = |{ lv_target } = concat_lines_of( table = { lt_ops[ 3 ] } sep = { lv_sep } ).|.
      RETURN.
    ENDIF.

    IF lines( lt_ops ) >= 1 AND lt_ops[ 1 ] = 'LINES'.
      RETURN.
    ENDIF.

    lv_tpl = ``.
    lv_first = abap_true.
    LOOP AT lt_ops ASSIGNING <lv_op>.
      IF lv_first = abap_true.
        lv_first = abap_false.
      ELSEIF lv_has_sep = abap_true.
        lv_tpl = |{ lv_tpl }\{ { lv_sep } \}|.
      ENDIF.
      lv_tpl = |{ lv_tpl }\{ { <lv_op> } \}|.
    ENDLOOP.
    rv_line = |{ lv_target } = \|{ lv_tpl }\|.|.
  ENDMETHOD.
ENDCLASS.
