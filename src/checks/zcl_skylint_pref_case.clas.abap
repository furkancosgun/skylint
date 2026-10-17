CLASS zcl_skylint_pref_case DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        change_if_to_case TYPE if_ci_atc_check=>ty_finding_code VALUE 'USE_CASE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CASE'.

    DATA mv_min_branches TYPE i VALUE 3.

    METHODS get_compared_variable
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_var) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_case IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Change IF to CASE when checking the same variable against multiple values'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-change_if_to_case
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Multiple ELSEIF branches check the same variable; use CASE instead'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MIN_BRANCHES'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_min_branches ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx          TYPE i.
    DATA lv_depth        TYPE i.
    DATA lv_total        TYPE i.
    DATA lv_var          TYPE string.
    DATA lv_branch_var   TYPE string.
    DATA lv_branch_count TYPE i.
    DATA ls_stmt         TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.
      lv_var = get_compared_variable( <ls_statement> ).
      IF lv_var IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_branch_count = 1.
      lv_depth = 1.
      lv_idx = sy-tabix + 1.

      WHILE lv_idx <= lv_total AND lv_depth > 0.
        ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                       iv_index      = lv_idx ).
        CASE ls_stmt-keyword.
          WHEN 'IF'.
            lv_depth += 1.
          WHEN 'ENDIF'.
            lv_depth -= 1.
          WHEN 'ELSEIF'.
            IF lv_depth = 1.
              lv_branch_var = get_compared_variable( ls_stmt ).
              IF lv_branch_var = lv_var.
                lv_branch_count += 1.
              ENDIF.
            ENDIF.
        ENDCASE.
        lv_idx += 1.
      ENDWHILE.

      IF lv_branch_count >= mv_min_branches.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-change_if_to_case ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_compared_variable.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok3 TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_var.
    IF zcl_skylint_ast_util=>token_count( is_statement ) < 4.
      RETURN.
    ENDIF.

    ls_tok2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = 2 ).
    ls_tok3 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = 3 ).

    IF ( ls_tok3-lexeme = '=' OR ls_tok3-lexeme = 'EQ' ) AND ls_tok3-references IS INITIAL.
      rv_var = ls_tok2-lexeme.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
