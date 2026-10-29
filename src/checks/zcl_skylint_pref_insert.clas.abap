CLASS zcl_skylint_pref_insert DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_insert TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INSRT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_insert TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOINSERT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_INSERT'.

    METHODS find_top_level_to
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_index) TYPE i.

ENDCLASS.


CLASS zcl_skylint_pref_insert IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer INSERT ... INTO TABLE over APPEND for table safety'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_insert
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Prefer INSERT ... INTO TABLE over APPEND'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_insert
                                                short_text = 'Use INSERT INTO TABLE' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_to_idx    TYPE i.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'APPEND'.
        CONTINUE.
      ENDIF.
      CLEAR: ls_quickfix,
             lt_overrides.

      lv_to_idx = find_top_level_to( <ls_statement> ).
      IF lv_to_idx > 1 AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                                   iv_lexeme    = 'SORTED' ) = abap_false.
        lt_overrides = VALUE #( ( index  = 1
                                  lexeme = 'INSERT' )
                                ( index  = lv_to_idx
                                  lexeme = 'INTO TABLE' ) ).
        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                           it_overrides = lt_overrides ).
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_insert
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_insert
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD find_top_level_to.
    DATA lv_depth TYPE i.
    DATA lv_idx   TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_index = 0.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      IF lv_idx = 1.
        CONTINUE.
      ENDIF.

      IF lv_depth = 0 AND zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_tok>
                                                                  iv_lexeme = 'TO' ) = abap_true.
        rv_index = lv_idx.
        RETURN.
      ENDIF.

      IF zcl_skylint_ast_util=>token_is_literal( <ls_tok> ) = abap_true.
        CONTINUE.
      ENDIF.

      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_tok> ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
