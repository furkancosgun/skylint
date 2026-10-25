CLASS zcl_skylint_no_useless_concat DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        useless_concat TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_USL_CAT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        fold_literals TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'FOLDLIT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_USELESS_CONCAT'.

    TYPES:
      BEGIN OF ty_operand,
        start_index TYPE i,
        end_index   TYPE i,
        is_literal  TYPE abap_bool,
        is_foldable TYPE abap_bool,
        is_string   TYPE abap_bool,
        content     TYPE string,
      END OF ty_operand,
      ty_operands TYPE STANDARD TABLE OF ty_operand WITH EMPTY KEY.

    METHODS parse_operand
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index          TYPE i
      RETURNING VALUE(rs_operand) TYPE ty_operand.

    METHODS is_concat_operator
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS build_fold_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_statement_idx   TYPE i
                it_operands        TYPE ty_operands
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_useless_concat IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid concatenating string literals'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-useless_concat
                                       severity       = if_ci_atc_check=>finding_severities-note
                                       text           = 'Fold literal string concatenation into one literal'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-fold_literals
                                                                short_text = 'Fold literals' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx          TYPE i.
    DATA lv_stmt_idx     TYPE i.
    DATA lv_tok_cnt      TYPE i.
    DATA ls_first_op     TYPE ty_operand.
    DATA ls_next_op      TYPE ty_operand.
    DATA ls_oper_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lt_operands     TYPE ty_operands.
    DATA lt_operators    TYPE STANDARD TABLE OF if_ci_atc_source_code_provider=>ty_token WITH EMPTY KEY.
    DATA lv_all_literals TYPE abap_bool.
    DATA lv_all_foldable TYPE abap_bool.
    DATA ls_quickfix     TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_operand>   TYPE ty_operand.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lv_tok_cnt  = lines( <ls_statement>-tokens ).
      lv_idx      = 1.

      WHILE lv_idx <= lv_tok_cnt.
        ls_first_op = parse_operand( is_statement = <ls_statement>
                                     iv_index     = lv_idx ).

        IF ls_first_op-end_index >= lv_tok_cnt.
          EXIT.
        ENDIF.

        ls_oper_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                       iv_index     = ls_first_op-end_index + 1 ).
        IF is_concat_operator( ls_oper_tok ) = abap_false.
          lv_idx = ls_first_op-end_index + 1.
          CONTINUE.
        ENDIF.

        " Continuous && chain found: collect all operands and operators
        CLEAR: lt_operands,
               lt_operators.
        APPEND ls_first_op TO lt_operands.

        lv_idx = ls_first_op-end_index + 1.
        WHILE lv_idx <= lv_tok_cnt.
          ls_oper_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                         iv_index     = lv_idx ).
          IF is_concat_operator( ls_oper_tok ) = abap_false.
            EXIT.
          ENDIF.

          APPEND ls_oper_tok TO lt_operators.

          ls_next_op = parse_operand( is_statement = <ls_statement>
                                      iv_index     = lv_idx + 1 ).
          APPEND ls_next_op TO lt_operands.
          lv_idx = ls_next_op-end_index + 1.
        ENDWHILE.

        " Validate whether ALL operands in the chain are static literals
        IF lines( lt_operands ) >= 2.
          lv_all_literals = abap_true.
          lv_all_foldable = abap_true.

          LOOP AT lt_operands ASSIGNING <ls_operand>.
            IF <ls_operand>-is_literal = abap_false.
              lv_all_literals = abap_false.
              EXIT.
            ENDIF.
            IF <ls_operand>-is_foldable = abap_false.
              lv_all_foldable = abap_false.
            ENDIF.
          ENDLOOP.

          IF lv_all_literals = abap_true.
            CLEAR ls_quickfix.
            IF lv_all_foldable = abap_true.
              ls_quickfix = build_fold_quickfix( is_statement     = <ls_statement>
                                                 iv_statement_idx = lv_stmt_idx
                                                 it_operands      = lt_operands ).
            ENDIF.

            report_token( is_token        = lt_operators[ 1 ]
                          is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-useless_concat
                          is_quickfix     = ls_quickfix ).
          ENDIF.
        ENDIF.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_operand.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_curr    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_len     TYPE i.
    DATA lv_first   TYPE c LENGTH 1.
    DATA lv_last    TYPE c LENGTH 1.
    DATA lv_scan    TYPE i.
    DATA lv_total   TYPE i.
    DATA lv_has_exp TYPE abap_bool.

    CLEAR rs_operand.
    rs_operand-start_index = iv_index.
    rs_operand-end_index   = iv_index.

    lv_total = lines( is_statement-tokens ).
    IF iv_index < 1 OR iv_index > lv_total.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = iv_index ).
    lv_len = strlen( ls_tok-lexeme ).
    IF lv_len = 0.
      RETURN.
    ENDIF.

    lv_first = substring( val = ls_tok-lexeme
                          off = 0
                          len = 1 ).
    lv_last  = substring( val = ls_tok-lexeme
                          off = lv_len - 1
                          len = 1 ).

    " Case 1: Standard character literal '...'
    IF lv_first = `'` AND lv_last = `'` AND lv_len >= 2.
      rs_operand-is_literal  = abap_true.
      rs_operand-is_foldable = abap_true.
      rs_operand-is_string   = abap_false.
      IF lv_len > 2.
        rs_operand-content = substring( val = ls_tok-lexeme
                                        off = 1
                                        len = lv_len - 2 ).
      ENDIF.
      RETURN.
    ENDIF.

    " Case 2: String literal `...`
    IF lv_first = '`' AND lv_last = '`' AND lv_len >= 2.
      rs_operand-is_literal  = abap_true.
      rs_operand-is_foldable = abap_true.
      rs_operand-is_string   = abap_true.
      IF lv_len > 2.
        rs_operand-content = substring( val = ls_tok-lexeme
                                        off = 1
                                        len = lv_len - 2 ).
      ENDIF.
      RETURN.
    ENDIF.

    " Case 3: Single-token string template |...|
    IF lv_first = '|' AND lv_last = '|' AND lv_len >= 2.
      IF ls_tok-lexeme NS '{' AND ls_tok-lexeme NS '}'.
        rs_operand-is_literal  = abap_true.
        rs_operand-is_foldable = abap_false.
      ENDIF.
      RETURN.
    ENDIF.

    " Case 4: Multi-token string template | ... | (SAP parser tokenization)
    IF lv_first = '|'.
      lv_has_exp = abap_false.
      lv_scan    = iv_index + 1.

      WHILE lv_scan <= lv_total.
        ls_curr = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_scan ).
        IF ls_curr-lexeme = '|'.
          rs_operand-end_index = lv_scan.
          IF lv_has_exp = abap_false.
            rs_operand-is_literal  = abap_true.
            rs_operand-is_foldable = abap_false.
          ENDIF.
          RETURN.
        ENDIF.

        IF ls_curr-lexeme CS '{' OR ls_curr-lexeme CS '}'.
          lv_has_exp = abap_true.
        ENDIF.
        lv_scan += 1.
      ENDWHILE.
    ENDIF.
  ENDMETHOD.

  METHOD is_concat_operator.
    rv_yes = zcl_skylint_ast_util=>token_is_keyword( is_token  = is_token
                                                     iv_lexeme = '&&' ).
  ENDMETHOD.

  METHOD build_fold_quickfix.
    DATA lv_content   TYPE string.
    DATA lv_delimiter TYPE string.
    DATA lv_literal   TYPE string.
    DATA lv_line      TYPE string.
    DATA lv_all_char  TYPE abap_bool VALUE abap_true.
    DATA lv_first_idx TYPE i.
    DATA lv_last_idx  TYPE i.
    DATA lv_pos       TYPE i.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.
    FIELD-SYMBOLS <ls_op> TYPE ty_operand.

    IF lines( it_operands ) < 2.
      RETURN.
    ENDIF.

    LOOP AT it_operands ASSIGNING <ls_op>.
      IF <ls_op>-is_string = abap_true.
        lv_all_char = abap_false.
      ENDIF.
      lv_content = |{ lv_content }{ <ls_op>-content }|.
    ENDLOOP.

    IF lv_all_char = abap_true AND strlen( lv_content ) <= 250.
      lv_delimiter = `'`.
    ELSE.
      lv_delimiter = '`'.
    ENDIF.
    lv_literal = |{ lv_delimiter }{ lv_content }{ lv_delimiter }|.

    lv_first_idx = it_operands[ 1 ]-start_index.
    lv_last_idx  = it_operands[ lines( it_operands ) ]-end_index.

    lt_overrides = VALUE #( ( index  = lv_first_idx
                              lexeme = lv_literal ) ).

    lv_pos = lv_first_idx + 1.
    WHILE lv_pos <= lv_last_idx.
      APPEND lv_pos TO lt_deletions.
      lv_pos += 1.
    ENDWHILE.

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = lt_overrides
                                                       it_deletions = lt_deletions ).
    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-fold_literals
                                    iv_statement_from = iv_statement_idx
                                    it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
  ENDMETHOD.
ENDCLASS.
