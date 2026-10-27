CLASS zcl_skylint_pref_between DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        range_check TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_BETWN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_BETWEEN'.

    DATA mv_strict_range TYPE abap_bool VALUE abap_false.

    METHODS inspect_condition
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

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
                                 attributes        = VALUE #(
                                     ( name  = 'STRICT_RANGE'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_strict_range ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'WHILE' OR 'CHECK'.
          inspect_condition( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_condition.
    DATA lv_count   TYPE i.
    DATA lv_from    TYPE i.
    DATA lv_to      TYPE i.
    DATA lv_depth   TYPE i.
    DATA lv_and_idx TYPE i.
    DATA lv_op1     TYPE string.
    DATA lv_op2     TYPE string.
    DATA lv_op1_idx TYPE i.
    DATA lv_op2_idx TYPE i.
    DATA lv_left1   TYPE string.
    DATA lv_right1  TYPE string.
    DATA lv_left2   TYPE string.
    DATA lv_right2  TYPE string.
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
      IF lv_depth = 0 AND <ls_tok>-references IS INITIAL.
        IF <ls_tok>-lexeme = 'BETWEEN' OR <ls_tok>-lexeme = 'OR'.
          RETURN.
        ENDIF.
        IF <ls_tok>-lexeme = 'AND'.
          IF lv_and_idx > 0.
            RETURN.
          ENDIF.
          lv_and_idx = sy-tabix.
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
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-range_check ).
    ENDIF.
  ENDMETHOD.

  METHOD extract_clause_operands.
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
      IF     lv_depth = 0
         AND <ls_tok>-references                  IS INITIAL
         AND is_range_operator( <ls_tok>-lexeme )  = abap_true.
        ev_op = <ls_tok>-lexeme.
        ev_op_idx = sy-tabix.
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
    zcl_skylint_ast_util=>strip_outer_parens( EXPORTING is_statement = is_statement
                                              CHANGING  cv_from      = cv_from
                                                        cv_to        = cv_to ).
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
ENDCLASS.
