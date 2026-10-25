CLASS zcl_skylint_pref_merge_ifs DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nested_if TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_MRGIF',
        else_if   TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_ELSIF',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_elseif TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USE_ELSEIF',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_MERGE_IFS'.

    TYPES: BEGIN OF ty_if_block,
             end_idx    TYPE i,
             else_idx   TYPE i,
             has_else   TYPE abap_bool,
             has_elseif TYPE abap_bool,
           END OF ty_if_block.

    METHODS analyze_if
      IMPORTING iv_idx          TYPE i
                is_procedure    TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rs_block) TYPE ty_if_block.

    METHODS is_direct_merge
      IMPORTING iv_idx       TYPE i
                is_outer     TYPE ty_if_block
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_elseif_candidate
      IMPORTING is_outer     TYPE ty_if_block
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS build_elseif_fix
      IMPORTING is_outer           TYPE ty_if_block
                is_procedure       TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rt_quickfix) TYPE zcl_skylint_check_base=>ty_quickfixes.

ENDCLASS.


CLASS zcl_skylint_pref_merge_ifs IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Merge consecutive nested IF blocks using boolean AND'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-nested_if
                                       text = 'Nested IF block can be merged with outer IF using AND' )
                                     ( code = c_finding_codes-else_if
                                       text = 'Nested IF in ELSE block can be changed to ELSEIF' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_elseif
                                                                short_text = 'Change ELSE to ELSEIF' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx   TYPE i.
    DATA ls_outer TYPE ty_if_block.
    DATA ls_else  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lt_qf    TYPE zcl_skylint_check_base=>ty_quickfixes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.
      ls_outer = analyze_if( iv_idx       = lv_idx
                             is_procedure = is_procedure ).
      IF ls_outer-end_idx = 0.
        CONTINUE.
      ENDIF.

      IF is_direct_merge( iv_idx       = lv_idx
                          is_outer     = ls_outer
                          is_procedure = is_procedure ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-nested_if ).
        CONTINUE.
      ENDIF.

      IF is_elseif_candidate( is_outer     = ls_outer
                              is_procedure = is_procedure ) = abap_false.
        CONTINUE.
      ENDIF.

      lt_qf = build_elseif_fix( is_outer     = ls_outer
                                is_procedure = is_procedure ).
      ls_else = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                     iv_index      = ls_outer-else_idx ).
      report_statement( is_statement    = ls_else
                        iv_finding_code = c_finding_codes-else_if
                        it_quickfixes   = lt_qf ).
    ENDLOOP.
  ENDMETHOD.

  METHOD analyze_if.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA lv_depth TYPE i.
    DATA ls_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rs_block.
    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).
    lv_idx = iv_idx.

    WHILE lv_idx <= lv_total.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                     iv_index      = lv_idx ).
      IF ls_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_stmt-keyword.
        WHEN 'IF'.
          lv_depth += 1.

        WHEN 'ENDIF'.
          lv_depth -= 1.
          IF lv_depth <= 0.
            rs_block-end_idx = lv_idx.
            RETURN.
          ENDIF.

        WHEN 'ELSE'.
          IF lv_depth = 1.
            rs_block-else_idx = lv_idx.
            rs_block-has_else = abap_true.
          ENDIF.

        WHEN 'ELSEIF'.
          IF lv_depth = 1.
            rs_block-has_elseif = abap_true.
          ENDIF.
      ENDCASE.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_direct_merge.
    DATA ls_next  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_inner TYPE ty_if_block.

    rv_is = abap_false.
    ls_next = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                   iv_index      = iv_idx + 1 ).
    IF ls_next-keyword <> 'IF'.
      RETURN.
    ENDIF.

    ls_inner = analyze_if( iv_idx       = iv_idx + 1
                           is_procedure = is_procedure ).
    IF ls_inner-end_idx <> is_outer-end_idx - 1.
      RETURN.
    ENDIF.

    IF ls_inner-has_else = abap_true OR ls_inner-has_elseif = abap_true.
      RETURN.
    ENDIF.

    rv_is = abap_true.
  ENDMETHOD.

  METHOD is_elseif_candidate.
    DATA ls_next  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_inner TYPE ty_if_block.

    rv_is = abap_false.
    IF is_outer-else_idx = 0.
      RETURN.
    ENDIF.

    ls_next = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                   iv_index      = is_outer-else_idx + 1 ).
    IF ls_next-keyword <> 'IF'.
      RETURN.
    ENDIF.

    ls_inner = analyze_if( iv_idx       = is_outer-else_idx + 1
                           is_procedure = is_procedure ).
    IF ls_inner-end_idx <> is_outer-end_idx - 1.
      RETURN.
    ENDIF.

    IF ls_inner-has_else = abap_true OR ls_inner-has_elseif = abap_true.
      RETURN.
    ENDIF.

    rv_is = abap_true.
  ENDMETHOD.

  METHOD build_elseif_fix.
    DATA ls_else   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_inner  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_indent TYPE string.
    DATA lv_cond   TYPE string.
    DATA lv_line   TYPE string.
    DATA lt_empty  TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_else = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                   iv_index      = is_outer-else_idx ).
    ls_inner = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                    iv_index      = is_outer-else_idx + 1 ).

    LOOP AT ls_inner-tokens ASSIGNING <ls_token> FROM 2.
      IF lv_cond IS INITIAL.
        lv_cond = <ls_token>-lexeme.
      ELSE.
        lv_cond = |{ lv_cond } { <ls_token>-lexeme }|.
      ENDIF.
    ENDLOOP.

    IF lv_cond IS INITIAL.
      RETURN.
    ENDIF.

    lv_indent = repeat( val = ` `
                        occ = ls_else-position-column ).
    lv_line = |{ lv_indent }ELSEIF { lv_cond }.|.
    APPEND quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_elseif
                             iv_statement_from = is_outer-else_idx
                             iv_statement_to   = is_outer-else_idx + 1
                             it_new_code       = VALUE #( ( lv_line ) ) ) TO rt_quickfix.
    APPEND quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_elseif
                             iv_statement_from = is_outer-end_idx - 1
                             it_new_code       = lt_empty ) TO rt_quickfix.
  ENDMETHOD.
ENDCLASS.
