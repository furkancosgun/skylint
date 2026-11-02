CLASS zcl_skylint_no_dup_subexpr DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dup_subexpr TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DUP_SUB',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DUP_SUBEXPR'.

    METHODS check_condition_duplicates
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_no_dup_subexpr IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid duplicate subexpressions in conditions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-dup_subexpr
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Duplicate subexpression detected in boolean condition'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE'.
          check_condition_duplicates( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_condition_duplicates.
    DATA lv_depth       TYPE i.
    DATA lv_from        TYPE i.
    DATA lv_sub_from    TYPE i.
    DATA lv_sub_to      TYPE i.
    DATA lv_text        TYPE string.
    DATA lt_subexprs    TYPE string_table.
    DATA lt_seen        TYPE string_table.
    DATA lv_tok_count   TYPE i.
    DATA lv_idx         TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_tok_count = lines( is_statement-tokens ).
    IF lv_tok_count < 3.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_sub_from = 2.

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM 2.
      lv_idx = sy-tabix.

      IF     lv_depth = 0
         AND <ls_token>-references IS INITIAL
         AND ( <ls_token>-lexeme = 'AND' OR <ls_token>-lexeme = 'OR' ).

        lv_sub_to = lv_idx - 1.
        IF lv_sub_to >= lv_sub_from.
          zcl_skylint_ast_util=>strip_outer_parens( EXPORTING is_statement = is_statement
                                                    CHANGING  cv_from      = lv_sub_from
                                                              cv_to        = lv_sub_to ).
          lv_text = to_upper( zcl_skylint_ast_util=>extract_tokens_text( is_statement = is_statement
                                                                         iv_from_idx  = lv_sub_from
                                                                         iv_to_idx    = lv_sub_to ) ).
          IF lv_text IS NOT INITIAL.
            APPEND lv_text TO lt_subexprs.
          ENDIF.
        ENDIF.

        lv_sub_from = lv_idx + 1.
      ENDIF.

      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.

    " Add trailing subexpression
    lv_sub_to = lv_tok_count.
    IF lv_sub_to >= lv_sub_from.
      zcl_skylint_ast_util=>strip_outer_parens( EXPORTING is_statement = is_statement
                                                CHANGING  cv_from      = lv_sub_from
                                                          cv_to        = lv_sub_to ).
      lv_text = to_upper( zcl_skylint_ast_util=>extract_tokens_text( is_statement = is_statement
                                                                     iv_from_idx  = lv_sub_from
                                                                     iv_to_idx    = lv_sub_to ) ).
      IF lv_text IS NOT INITIAL.
        APPEND lv_text TO lt_subexprs.
      ENDIF.
    ENDIF.

    IF lines( lt_subexprs ) < 2.
      RETURN.
    ENDIF.

    CLEAR lt_seen.
    LOOP AT lt_subexprs INTO lv_text.
      IF line_exists( lt_seen[ table_line = lv_text ] ).
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-dup_subexpr ).
        RETURN.
      ENDIF.
      APPEND lv_text TO lt_seen.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
