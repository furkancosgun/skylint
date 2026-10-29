CLASS zcl_skylint_no_empty_block DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_control_block TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_EMPTY_B',
        try_without_catch   TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_TRY_WO',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_empty_block TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'RMBLOCK',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EMPTY_BLOCK'.

    DATA mv_check_if           TYPE abap_bool VALUE abap_true.
    DATA mv_check_loop         TYPE abap_bool VALUE abap_true.
    DATA mv_check_case         TYPE abap_bool VALUE abap_true.
    DATA mv_check_try          TYPE abap_bool VALUE abap_true.
    DATA mv_check_catch        TYPE abap_bool VALUE abap_true.
    DATA mv_check_try_no_catch TYPE abap_bool VALUE abap_true.
    DATA mv_check_do           TYPE abap_bool VALUE abap_true.
    DATA mv_check_while        TYPE abap_bool VALUE abap_true.

    METHODS is_empty_control_block
      IMPORTING iv_current_kw TYPE string
                iv_next_kw    TYPE string
      RETURNING VALUE(rv_is)  TYPE abap_bool.

    METHODS try_has_catch
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_start_idx  TYPE i
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_empty_block IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid empty control blocks (IF, CASE, LOOP, TRY, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-empty_control_block
                                       text = 'Empty control block detected; remove redundant control statement' )
                                     ( code = c_finding_codes-try_without_catch
                                       text = 'TRY block without CATCH is superfluous' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_empty_block
                                                                short_text = 'Remove empty control block' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_IF'
                                                                value = REF #( mv_check_if ) )
                                                              ( name  = 'CHECK_LOOP'
                                                                value = REF #( mv_check_loop ) )
                                                              ( name  = 'CHECK_CASE'
                                                                value = REF #( mv_check_case ) )
                                                              ( name  = 'CHECK_TRY'
                                                                value = REF #( mv_check_try ) )
                                                              ( name  = 'CHECK_CATCH'
                                                                value = REF #( mv_check_catch ) )
                                                              ( name  = 'CHECK_TRY_NO_CATCH'
                                                                value = REF #( mv_check_try_no_catch ) )
                                                              ( name  = 'CHECK_DO'
                                                                value = REF #( mv_check_do ) )
                                                              ( name  = 'CHECK_WHILE'
                                                                value = REF #( mv_check_while ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'ELSE'.
          IF mv_check_if = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'LOOP'.
          IF mv_check_loop = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'CASE' OR 'WHEN'.
          IF mv_check_case = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'TRY'.
          IF mv_check_try = abap_false.
            CONTINUE.
          ENDIF.
          IF     mv_check_try_no_catch = abap_true
             AND try_has_catch( it_statements = is_procedure-statements
                                iv_start_idx  = lv_stmt_idx )           = abap_false.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-try_without_catch ).
            CONTINUE.
          ENDIF.
        WHEN 'CATCH'.
          IF mv_check_catch = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'DO'.
          IF mv_check_do = abap_false.
            CONTINUE.
          ENDIF.
        WHEN 'WHILE'.
          IF mv_check_while = abap_false.
            CONTINUE.
          ENDIF.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = lv_stmt_idx ).
      IF     ls_next_stmt-keyword IS NOT INITIAL
         AND is_empty_control_block( iv_current_kw = <ls_statement>-keyword
                                     iv_next_kw    = ls_next_stmt-keyword )  = abap_true.
        CLEAR ls_quickfix.
        IF <ls_statement>-keyword = 'ELSE' AND ls_next_stmt-keyword = 'ENDIF'.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_empty_block
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ) ).
        ELSEIF    ( <ls_statement>-keyword = 'IF'    AND ls_next_stmt-keyword = 'ENDIF' )
               OR ( <ls_statement>-keyword = 'LOOP'  AND ls_next_stmt-keyword = 'ENDLOOP' )
               OR ( <ls_statement>-keyword = 'DO'    AND ls_next_stmt-keyword = 'ENDDO' )
               OR ( <ls_statement>-keyword = 'WHILE' AND ls_next_stmt-keyword = 'ENDWHILE' )
               OR ( <ls_statement>-keyword = 'CASE'  AND ls_next_stmt-keyword = 'ENDCASE' ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_empty_block
                                          iv_statement_from = lv_stmt_idx
                                          iv_statement_to   = lv_stmt_idx + 1
                                          it_new_code       = VALUE #( ) ).
        ENDIF.

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-empty_control_block
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD try_has_catch.
    DATA lv_depth TYPE i.
    DATA lv_idx   TYPE i.
    DATA ls_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_total TYPE i.

    rv_has = abap_false.
    lv_depth = 1.
    lv_idx = iv_start_idx + 1.
    lv_total = lines( it_statements ).

    WHILE lv_idx <= lv_total AND lv_depth > 0.
      ls_stmt = it_statements[ lv_idx ].
      CASE ls_stmt-keyword.
        WHEN 'TRY'.
          lv_depth += 1.
        WHEN 'ENDTRY'.
          lv_depth -= 1.
        WHEN 'CATCH'.
          IF lv_depth = 1.
            rv_has = abap_true.
            RETURN.
          ENDIF.
      ENDCASE.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_empty_control_block.
    rv_is = abap_false.

    CASE iv_current_kw.
      WHEN 'IF' OR 'ELSEIF'.
        IF iv_next_kw = 'ENDIF' OR iv_next_kw = 'ELSEIF' OR iv_next_kw = 'ELSE'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'ELSE'.
        IF iv_next_kw = 'ENDIF'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'LOOP'.
        IF iv_next_kw = 'ENDLOOP'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'DO'.
        IF iv_next_kw = 'ENDDO'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'WHILE'.
        IF iv_next_kw = 'ENDWHILE'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'TRY'.
        IF iv_next_kw = 'CATCH' OR iv_next_kw = 'CLEANUP' OR iv_next_kw = 'ENDTRY'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'CATCH'.
        IF iv_next_kw = 'CATCH' OR iv_next_kw = 'CLEANUP' OR iv_next_kw = 'ENDTRY' OR iv_next_kw = 'ENDCATCH'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'CASE'.
        IF iv_next_kw = 'ENDCASE'.
          rv_is = abap_true.
        ENDIF.

      WHEN 'WHEN'.
        IF iv_next_kw = 'WHEN' OR iv_next_kw = 'ENDCASE'.
          rv_is = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
