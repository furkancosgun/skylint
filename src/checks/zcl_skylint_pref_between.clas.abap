CLASS zcl_skylint_pref_between DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        range_check TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_BETWN',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_between TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USE_BTWN',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_BETWEEN'.

    DATA mv_strict_range TYPE abap_bool VALUE abap_false.

    METHODS inspect_condition
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx  TYPE i.

    METHODS extract_range_text
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from        TYPE i
                iv_to          TYPE i
      RETURNING VALUE(rv_text) TYPE string.

    METHODS build_between_fix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                iv_from            TYPE i
                iv_to              TYPE i
                iv_and_idx         TYPE i
                iv_op1_idx         TYPE i
                iv_op2_idx         TYPE i
                iv_op1             TYPE string
                iv_op2             TYPE string
                iv_left1           TYPE string
                iv_right1          TYPE string
                iv_left2           TYPE string
                iv_right2          TYPE string
      RETURNING VALUE(rs_quickfix) TYPE ty_quickfix.

    METHODS extract_clause_operands
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from      TYPE i
                iv_to        TYPE i
      EXPORTING ev_op        TYPE string
                ev_op_idx    TYPE i
                ev_left      TYPE string
                ev_right     TYPE string.

    METHODS build_operand_symbol
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from          TYPE i
                iv_to            TYPE i
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS strip_outer_parens
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  cv_from      TYPE i
                cv_to        TYPE i.

    METHODS is_range_operator
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_valid_range
      IMPORTING iv_op1        TYPE string
                iv_op2        TYPE string
                iv_left1      TYPE string
                iv_right1     TYPE string
                iv_left2      TYPE string
                iv_right2     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_between IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer BETWEEN for inclusive range checks'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-range_check
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Combine the duplicated range comparison with BETWEEN'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_between
                                                                short_text = 'Use BETWEEN operator' ) )
                                 attributes        = VALUE #(
                                     ( name  = 'STRICT_RANGE'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_strict_range ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          inspect_condition( is_statement = <ls_statement>
                             iv_stmt_idx  = lv_stmt_idx ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_condition.
    DATA lv_count    TYPE i.
    DATA lv_from     TYPE i.
    DATA lv_to       TYPE i.
    DATA lv_depth    TYPE i.
    DATA lv_and_idx  TYPE i.
    DATA lv_op1      TYPE string.
    DATA lv_op2      TYPE string.
    DATA lv_op1_idx  TYPE i.
    DATA lv_op2_idx  TYPE i.
    DATA lv_left1    TYPE string.
    DATA lv_right1   TYPE string.
    DATA lv_left2    TYPE string.
    DATA lv_right2   TYPE string.
    DATA ls_quickfix TYPE ty_quickfix.
    DATA lv_idx      TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 8.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_count.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    IF lv_to < lv_from + 6.
      RETURN.
    ENDIF.

    lv_depth = 0.
    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      IF lv_depth = 0 AND <ls_tok>-references IS INITIAL.
        IF <ls_tok>-lexeme = 'BETWEEN' OR <ls_tok>-lexeme = 'OR'.
          RETURN.
        ENDIF.
        IF <ls_tok>-lexeme = 'AND'.
          IF lv_and_idx > 0.
            RETURN.
          ENDIF.
          lv_and_idx = lv_idx.
        ENDIF.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_tok> ).
    ENDLOOP.

    IF lv_and_idx <= lv_from + 2 OR lv_and_idx >= lv_to - 2.
      RETURN.
    ENDIF.

    extract_clause_operands( EXPORTING is_statement = is_statement
                                       iv_from      = lv_from
                                       iv_to        = lv_and_idx - 1
                             IMPORTING ev_op        = lv_op1
                                       ev_op_idx    = lv_op1_idx
                                       ev_left      = lv_left1
                                       ev_right     = lv_right1 ).

    extract_clause_operands( EXPORTING is_statement = is_statement
                                       iv_from      = lv_and_idx + 1
                                       iv_to        = lv_to
                             IMPORTING ev_op        = lv_op2
                                       ev_op_idx    = lv_op2_idx
                                       ev_left      = lv_left2
                                       ev_right     = lv_right2 ).

    IF lv_op1_idx = 0 OR lv_op2_idx = 0.
      RETURN.
    ENDIF.

    IF is_valid_range( iv_op1    = lv_op1
                       iv_op2    = lv_op2
                       iv_left1  = lv_left1
                       iv_right1 = lv_right1
                       iv_left2  = lv_left2
                       iv_right2 = lv_right2 ) = abap_true.
      ls_quickfix = build_between_fix( is_statement = is_statement
                                       iv_stmt_idx  = iv_stmt_idx
                                       iv_from      = lv_from
                                       iv_to        = lv_to
                                       iv_and_idx   = lv_and_idx
                                       iv_op1_idx   = lv_op1_idx
                                       iv_op2_idx   = lv_op2_idx
                                       iv_op1       = lv_op1
                                       iv_op2       = lv_op2
                                       iv_left1     = lv_left1
                                       iv_right1    = lv_right1
                                       iv_left2     = lv_left2
                                       iv_right2    = lv_right2 ).
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-range_check
                        is_quickfix     = ls_quickfix ).
    ENDIF.
  ENDMETHOD.

  METHOD extract_clause_operands.
    DATA lv_idx   TYPE i.
    DATA lv_from  TYPE i.
    DATA lv_to    TYPE i.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_from = iv_from.
    lv_to   = iv_to.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    IF lv_to < lv_from + 2.
      RETURN.
    ENDIF.

    lv_depth = 0.
    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_tok>.
      lv_idx = sy-tabix.
      IF     lv_depth = 0
         AND <ls_tok>-references                  IS INITIAL
         AND is_range_operator( <ls_tok>-lexeme )  = abap_true.
        ev_op = <ls_tok>-lexeme.
        ev_op_idx = lv_idx.
        EXIT.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_tok> ).
    ENDLOOP.

    IF ev_op_idx <= lv_from OR ev_op_idx >= lv_to.
      RETURN.
    ENDIF.

    ev_left  = build_operand_symbol( is_statement = is_statement
                                     iv_from      = lv_from
                                     iv_to        = ev_op_idx - 1 ).
    ev_right = build_operand_symbol( is_statement = is_statement
                                     iv_from      = ev_op_idx + 1
                                     iv_to        = lv_to ).
  ENDMETHOD.

  METHOD build_operand_symbol.
    DATA lv_from TYPE i.
    DATA lv_to   TYPE i.
    DATA ls_ref  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_from = iv_from.
    lv_to   = iv_to.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_tok>.
      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = <ls_tok>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF ls_ref-full_name IS NOT INITIAL.
        rv_symbol = |{ rv_symbol } { ls_ref-full_name }|.
      ELSE.
        rv_symbol = |{ rv_symbol } { <ls_tok>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD strip_outer_parens.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_open>  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_close> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok>   TYPE if_ci_atc_source_code_provider=>ty_token.

    WHILE cv_from < cv_to.
      ASSIGN is_statement-tokens[ cv_from ] TO <ls_open>.
      IF sy-subrc <> 0 OR <ls_open>-lexeme <> '(' OR <ls_open>-references IS NOT INITIAL.
        EXIT.
      ENDIF.

      ASSIGN is_statement-tokens[ cv_to ] TO <ls_close>.
      IF sy-subrc <> 0 OR <ls_close>-lexeme <> ')' OR <ls_close>-references IS NOT INITIAL.
        EXIT.
      ENDIF.

      lv_depth = 0.
      LOOP AT is_statement-tokens FROM cv_from TO cv_to - 1 ASSIGNING <ls_tok>.
        lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_tok> ).
        IF lv_depth = 0.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_depth = 1.
        cv_from += 1.
        cv_to   -= 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_range_operator.
    rv_yes = xsdbool(    iv_lexeme = '<='
                      OR iv_lexeme = '>='
                      OR iv_lexeme = '<'
                      OR iv_lexeme = '>' ).
  ENDMETHOD.

  METHOD is_valid_range.
    IF     iv_left1  = iv_left2
       AND iv_left1 IS NOT INITIAL
       AND (    (     iv_op1          = '>='      AND iv_op2 = '<=' )
             OR (     iv_op1          = '<='      AND iv_op2 = '>=' )
             OR (     mv_strict_range = abap_true
                  AND (    ( iv_op1 = '>' AND iv_op2 = '<' )
                        OR ( iv_op1 = '<' AND iv_op2 = '>' ) ) ) ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     iv_right1  = iv_right2
       AND iv_right1 IS NOT INITIAL
       AND (    (     iv_op1          = '<='      AND iv_op2 = '>=' )
             OR (     iv_op1          = '>='      AND iv_op2 = '<=' )
             OR (     mv_strict_range = abap_true
                  AND (    ( iv_op1 = '<' AND iv_op2 = '>' )
                        OR ( iv_op1 = '>' AND iv_op2 = '<' ) ) ) ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     iv_right1  = iv_left2
       AND iv_right1 IS NOT INITIAL
       AND (    (     iv_op1          = '<='      AND iv_op2 = '<=' )
             OR (     iv_op1          = '>='      AND iv_op2 = '>=' )
             OR (     mv_strict_range = abap_true
                  AND (    ( iv_op1 = '<' AND iv_op2 = '<' )
                        OR ( iv_op1 = '>' AND iv_op2 = '>' ) ) ) ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     iv_left1  = iv_right2
       AND iv_left1 IS NOT INITIAL
       AND (    (     iv_op1          = '<='      AND iv_op2 = '<=' )
             OR (     iv_op1          = '>='      AND iv_op2 = '>=' )
             OR (     mv_strict_range = abap_true
                  AND (    ( iv_op1 = '<' AND iv_op2 = '<' )
                        OR ( iv_op1 = '>' AND iv_op2 = '>' ) ) ) ).
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD extract_range_text.
    DATA lv_from TYPE i.
    DATA lv_to   TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_from = iv_from.
    lv_to   = iv_to.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_tok>.
      IF rv_text IS INITIAL.
        rv_text = <ls_tok>-lexeme.
      ELSE.
        rv_text = |{ rv_text } { <ls_tok>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_between_fix.
    DATA lv_c1_from TYPE i.
    DATA lv_c1_to   TYPE i.
    DATA lv_c2_from TYPE i.
    DATA lv_c2_to   TYPE i.
    DATA lv_l1_text TYPE string.
    DATA lv_r1_text TYPE string.
    DATA lv_l2_text TYPE string.
    DATA lv_r2_text TYPE string.
    DATA lv_target  TYPE string.
    DATA lv_low     TYPE string.
    DATA lv_high    TYPE string.
    DATA lv_indent  TYPE string.
    DATA lv_line    TYPE string.

    CLEAR rs_quickfix.

    IF iv_op1 <> '<=' AND iv_op1 <> '>='.
      RETURN.
    ENDIF.
    IF iv_op2 <> '<=' AND iv_op2 <> '>='.
      RETURN.
    ENDIF.

    lv_c1_from = iv_from.
    lv_c1_to   = iv_and_idx - 1.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_c1_from
                                  cv_to        = lv_c1_to ).

    lv_c2_from = iv_and_idx + 1.
    lv_c2_to   = iv_to.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_c2_from
                                  cv_to        = lv_c2_to ).

    lv_l1_text = extract_range_text( is_statement = is_statement
                                     iv_from      = lv_c1_from
                                     iv_to        = iv_op1_idx - 1 ).
    lv_r1_text = extract_range_text( is_statement = is_statement
                                     iv_from      = iv_op1_idx + 1
                                     iv_to        = lv_c1_to ).
    lv_l2_text = extract_range_text( is_statement = is_statement
                                     iv_from      = lv_c2_from
                                     iv_to        = iv_op2_idx - 1 ).
    lv_r2_text = extract_range_text( is_statement = is_statement
                                     iv_from      = iv_op2_idx + 1
                                     iv_to        = lv_c2_to ).

    IF iv_left1 = iv_left2.
      lv_target = lv_l1_text.
      IF iv_op1 = '>='.
        lv_low  = lv_r1_text.
        lv_high = lv_r2_text.
      ELSE.
        lv_low  = lv_r2_text.
        lv_high = lv_r1_text.
      ENDIF.
    ELSEIF iv_right1 = iv_right2.
      lv_target = lv_r1_text.
      IF iv_op1 = '<='.
        lv_low  = lv_l1_text.
        lv_high = lv_l2_text.
      ELSE.
        lv_low  = lv_l2_text.
        lv_high = lv_l1_text.
      ENDIF.
    ELSEIF iv_right1 = iv_left2.
      lv_target = lv_r1_text.
      IF iv_op1 = '<='.
        lv_low  = lv_l1_text.
        lv_high = lv_r2_text.
      ELSE.
        lv_low  = lv_r2_text.
        lv_high = lv_l1_text.
      ENDIF.
    ELSEIF iv_left1 = iv_right2.
      lv_target = lv_l1_text.
      IF iv_op1 = '>='.
        lv_low  = lv_r1_text.
        lv_high = lv_l2_text.
      ELSE.
        lv_low  = lv_l2_text.
        lv_high = lv_r1_text.
      ENDIF.
    ENDIF.

    IF lv_target IS INITIAL OR lv_low IS INITIAL OR lv_high IS INITIAL.
      RETURN.
    ENDIF.

    IF is_statement-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = is_statement-position-column - 1 ).
    ENDIF.

    lv_line = |{ lv_indent }{ is_statement-keyword } { lv_target } BETWEEN { lv_low } AND { lv_high }.|.

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_between
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( lv_line ) ) ).
  ENDMETHOD.
ENDCLASS.
