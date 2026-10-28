CLASS zcl_skylint_pref_full_typed DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        fully_typed TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_TYPED',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_type TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADD_TYPE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_FULL_TYPED'.

    METHODS is_untyped_constant
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS infer_constant_type
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_type) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_full_typed IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Enforce fully typed constant declarations'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-fully_typed
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Constant declaration should explicitly specify TYPE'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_type
                                                                short_text = 'Add explicit TYPE specification' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_type     TYPE string.
    DATA lv_val_idx  TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lv_tabix    TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_tabix = sy-tabix.
      IF <ls_statement>-keyword <> 'CONSTANTS'.
        CONTINUE.
      ENDIF.
      IF is_untyped_constant( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lv_type = infer_constant_type( <ls_statement> ).
      IF lv_type IS NOT INITIAL.
        lv_val_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = 'VALUE' ).
        IF lv_val_idx > 0.
          lv_line = zcl_skylint_ast_util=>flatten_statement(
                        is_statement = <ls_statement>
                        it_overrides = VALUE #( ( index  = lv_val_idx
                                                  lexeme = |TYPE { lv_type } VALUE| ) )
                        iv_suffix    = `.` ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_type
                                          iv_statement_from = lv_tabix
                                          it_new_code       = VALUE #( ( lv_line ) ) ).
        ENDIF.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-fully_typed
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD infer_constant_type.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_len  TYPE i.
    DATA lv_idx  TYPE i.
    DATA lv_last TYPE i.

    rv_type = ''.
    lv_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                               iv_lexeme    = 'VALUE' ).
    IF lv_idx <= 0 OR lv_idx >= zcl_skylint_ast_util=>token_count( is_statement ).
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_idx + 1 ).
    lv_len = strlen( ls_tok-lexeme ).
    IF lv_len >= 2.
      lv_last = lv_len - 1.
      IF    ( ls_tok-lexeme(1) = `'` AND ls_tok-lexeme+lv_last(1) = `'` )
         OR ( ls_tok-lexeme(1) = '`' AND ls_tok-lexeme+lv_last(1) = '`' ).
        rv_type = 'string'.
        RETURN.
      ENDIF.
    ENDIF.

    IF matches( val   = ls_tok-lexeme
                regex = '^-?[0-9]+$' ).
      rv_type = 'i'.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme = 'ABAP_TRUE' OR ls_tok-lexeme = 'ABAP_FALSE'.
      rv_type = 'abap_bool'.
    ENDIF.
  ENDMETHOD.

  METHOD is_untyped_constant.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_has_type TYPE abap_bool.
    DATA lv_is_struc TYPE abap_bool.
    DATA lv_idx      TYPE i.
    DATA lv_val_idx  TYPE i.

    rv_res = abap_false.
    lv_has_type = abap_false.
    lv_is_struc = abap_false.

    lv_val_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'VALUE' ).

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_idx = sy-tabix.
      IF lv_idx <= 2.
        CONTINUE.
      ENDIF.
      IF lv_val_idx > 0 AND lv_idx >= lv_val_idx.
        EXIT.
      ENDIF.
      CASE ls_tok-lexeme.
        WHEN 'BEGIN' OR 'END'.
          lv_is_struc = abap_true.
        WHEN 'TYPE' OR 'LIKE'.
          lv_has_type = abap_true.
      ENDCASE.
    ENDLOOP.

    IF lv_is_struc = abap_false.
      LOOP AT is_statement-tokens INTO ls_tok WHERE references IS INITIAL.
        IF ls_tok-lexeme = 'BEGIN' OR ls_tok-lexeme = 'END'.
          lv_is_struc = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_is_struc = abap_false AND lv_has_type = abap_false.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
