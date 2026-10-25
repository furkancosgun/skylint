CLASS zcl_skylint_no_dup_cond DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_condition TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUP_CND',
        duplicate_operand   TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUP_OPR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DUP_COND'.

    METHODS check_duplicate_elseif
      IMPORTING iv_idx       TYPE i
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS check_duplicate_when
      IMPORTING iv_idx       TYPE i
                is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS check_duplicate_operands
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS get_condition_string
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_cond) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_dup_cond IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid duplicate branch conditions in IF and CASE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-identical_condition
                                       text = 'Identical condition in branch; duplicate branch is unreachable' )
                                     ( code = c_finding_codes-duplicate_operand
                                       text = 'Identical operand in condition; remove the duplicate comparison' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'ELSEIF'.
          check_duplicate_elseif( iv_idx       = lv_idx
                                  is_statement = <ls_statement>
                                  is_procedure = is_procedure ).
          check_duplicate_operands( <ls_statement> ).

        WHEN 'WHEN'.
          check_duplicate_when( iv_idx       = lv_idx
                                is_statement = <ls_statement>
                                is_procedure = is_procedure ).

        WHEN 'IF' OR 'WHILE' OR 'CHECK'.
          check_duplicate_operands( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_duplicate_elseif.
    DATA lv_cond      TYPE string.
    DATA lv_prev_cond TYPE string.
    DATA lv_back_idx  TYPE i.
    DATA lv_depth     TYPE i.
    DATA ls_back_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_cond = get_condition_string( is_statement ).
    lv_depth = 0.
    lv_back_idx = iv_idx - 1.

    WHILE lv_back_idx >= 1.
      ls_back_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_back_idx ).
      IF ls_back_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_back_stmt-keyword.
        WHEN 'ENDIF'.
          lv_depth += 1.

        WHEN 'IF'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( ls_back_stmt ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
            ENDIF.
            EXIT.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'ELSEIF'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( ls_back_stmt ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.

      lv_back_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD check_duplicate_when.
    DATA lv_cond      TYPE string.
    DATA lv_prev_cond TYPE string.
    DATA lv_back_idx  TYPE i.
    DATA lv_depth     TYPE i.
    DATA ls_back_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_cond = get_condition_string( is_statement ).
    lv_depth = 0.
    lv_back_idx = iv_idx - 1.

    WHILE lv_back_idx >= 1.
      ls_back_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_back_idx ).
      IF ls_back_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_back_stmt-keyword.
        WHEN 'ENDCASE'.
          lv_depth += 1.

        WHEN 'CASE'.
          IF lv_depth = 0.
            EXIT.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'WHEN'.
          IF lv_depth = 0.
            lv_prev_cond = get_condition_string( ls_back_stmt ).
            IF lv_prev_cond = lv_cond.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-identical_condition ).
              EXIT.
            ENDIF.
          ENDIF.
      ENDCASE.

      lv_back_idx -= 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD check_duplicate_operands.
    DATA lv_tok_cnt  TYPE i.
    DATA lv_idx      TYPE i.
    DATA lv_depth    TYPE i.
    DATA lv_between  TYPE abap_bool.
    DATA lv_operator TYPE string.
    DATA lv_token_op TYPE string.
    DATA lv_lexeme   TYPE string.
    DATA lv_operand  TYPE string.
    DATA lv_other    TYPE string.
    DATA lt_operands TYPE string_table.
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_i        TYPE i.
    DATA lv_j        TYPE i.
    DATA lv_count    TYPE i.

    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_tok_cnt < 2.
      RETURN.
    ENDIF.

    lv_idx = 2.
    WHILE lv_idx <= lv_tok_cnt.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      lv_lexeme = ls_token-lexeme.

      IF ls_token-references IS INITIAL AND lv_lexeme = '('.
        lv_depth += 1.
      ELSEIF ls_token-references IS INITIAL AND lv_lexeme = ')'.
        lv_depth -= 1.
      ENDIF.

      lv_token_op = ''.
      IF     ls_token-references IS INITIAL
         AND lv_depth             = 0
         AND lv_lexeme            = 'BETWEEN'.
        lv_between = abap_true.
      ELSEIF     ls_token-references IS INITIAL
             AND lv_depth             = 0
             AND lv_lexeme            = 'AND'
             AND lv_between           = abap_true.
        lv_between = abap_false.
      ELSEIF     ls_token-references IS INITIAL
             AND lv_depth             = 0
             AND ( lv_lexeme = 'AND' OR lv_lexeme = 'OR' OR lv_lexeme = 'EQUIV' ).
        lv_token_op = lv_lexeme.
      ENDIF.

      IF lv_token_op IS NOT INITIAL.
        IF lv_operator IS INITIAL.
          lv_operator = lv_token_op.
        ELSEIF lv_operator <> lv_token_op.
          RETURN.
        ENDIF.
        IF lv_operand IS NOT INITIAL.
          APPEND lv_operand TO lt_operands.
        ENDIF.
        CLEAR lv_operand.
      ELSEIF lv_operand IS INITIAL.
        lv_operand = ls_token-lexeme.
      ELSE.
        lv_operand = |{ lv_operand } { ls_token-lexeme }|.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.

    IF lv_operand IS NOT INITIAL.
      APPEND lv_operand TO lt_operands.
    ENDIF.

    lv_count = lines( lt_operands ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    lv_i = 1.
    WHILE lv_i < lv_count.
      READ TABLE lt_operands INTO lv_operand INDEX lv_i.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      lv_j = lv_i + 1.
      WHILE lv_j <= lv_count.
        READ TABLE lt_operands INTO lv_other INDEX lv_j.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
        IF lv_operand = lv_other.
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-duplicate_operand ).
          RETURN.
        ENDIF.
        lv_j += 1.
      ENDWHILE.
      lv_i += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_condition_string.
    DATA lv_tok_cnt TYPE i.
    DATA lv_tok_idx TYPE i.
    DATA ls_token   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_cond = ''.
    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_tok_cnt < 2.
      RETURN.
    ENDIF.

    DO lv_tok_cnt - 1 TIMES.
      lv_tok_idx = sy-index + 1.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_tok_idx ).
      IF ls_token-lexeme IS NOT INITIAL.
        IF rv_cond IS INITIAL.
          rv_cond = ls_token-lexeme.
        ELSE.
          rv_cond = |{ rv_cond } { ls_token-lexeme }|.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
