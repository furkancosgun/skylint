CLASS zcl_skylint_max_cognitive DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        cognitive_complexity TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_COGNIT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_COGNITIVE'.

    DATA mv_max_cognitive TYPE i VALUE 15.

    METHODS calculate_score
      IMPORTING is_procedure    TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_score) TYPE i.

    METHODS has_logical_operator
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_max_cognitive IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Limit cognitive complexity per procedure'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-cognitive_complexity
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Procedure cognitive complexity exceeds threshold'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'MAX_COGNITIVE'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_max_cognitive ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_score      TYPE i.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_score = calculate_score( is_procedure ).

    IF lv_score <= mv_max_cognitive.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-cognitive_complexity ).
    ENDIF.
  ENDMETHOD.

  METHOD calculate_score.
    DATA lv_depth TYPE i.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_score = 0.
    lv_depth = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'CASE'.
          rv_score += 1 + lv_depth.
          lv_depth += 1.
        WHEN 'ELSEIF' OR 'ELSE' OR 'WHEN' OR 'CATCH'.
          rv_score += 1 + lv_depth.
        WHEN 'ENDIF' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDCASE'.
          IF lv_depth > 0.
            lv_depth -= 1.
          ENDIF.
      ENDCASE.

      IF has_logical_operator( <ls_statement> ) = abap_true.
        rv_score += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_logical_operator.
    DATA lv_depth   TYPE i.
    DATA lv_between TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_depth = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_depth = 0 AND <ls_token>-references IS INITIAL.
        CASE <ls_token>-lexeme.
          WHEN 'BETWEEN'.
            lv_between = abap_true.
          WHEN 'AND'.
            IF lv_between = abap_true.
              lv_between = abap_false.
            ELSE.
              rv_yes = abap_true.
              RETURN.
            ENDIF.
          WHEN 'OR'.
            rv_yes = abap_true.
            RETURN.
        ENDCASE.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
