CLASS zcl_skylint_no_empty_fae DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unsecure_fae TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_EMPTFAE',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_guard TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'FAEGUARD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EMPTY_FAE'.

    TYPES:
      BEGIN OF ty_condition_result,
        is_positive TYPE abap_bool,
        is_negative TYPE abap_bool,
      END OF ty_condition_result.

    TYPES:
      BEGIN OF ty_block_frame,
        keyword      TYPE string,
        is_protected TYPE abap_bool,
        is_negative  TYPE abap_bool,
        has_exit     TYPE abap_bool,
        is_guarded   TYPE abap_bool,
      END OF ty_block_frame,
      ty_block_stack TYPE STANDARD TABLE OF ty_block_frame WITH EMPTY KEY.

    METHODS extract_fae_table
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_tab       TYPE string
                ev_ref       TYPE string.

    METHODS is_fae_protected
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_select_idx TYPE i
                iv_fae_tab    TYPE string
                iv_fae_ref    TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS eval_condition
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_fae_tab    TYPE string
                iv_fae_ref    TYPE string
      RETURNING VALUE(rs_res) TYPE ty_condition_result.

    METHODS token_matches_table
      IMPORTING is_token          TYPE if_ci_atc_source_code_provider=>ty_token
                iv_fae_tab        TYPE string
                iv_fae_ref        TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    METHODS clean_table_name
      IMPORTING iv_lexeme      TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    METHODS build_quickfix
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx          TYPE i
                iv_fae_tab           TYPE string
      RETURNING VALUE(rt_quickfixes) TYPE ty_quickfixes.

ENDCLASS.


CLASS zcl_skylint_no_empty_fae IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Unsecure FOR ALL ENTRIES (Missing empty itab check)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unsecure_fae
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'FOR ALL ENTRIES without preceding IS NOT INITIAL check causes full table scan'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_guard
                                                short_text = 'Add empty-check guard' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx        TYPE i.
    DATA lv_fae_tab    TYPE string.
    DATA lv_fae_ref    TYPE string.
    DATA lt_quickfixes TYPE ty_quickfixes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      extract_fae_table( EXPORTING is_statement = <ls_statement>
                         IMPORTING ev_tab       = lv_fae_tab
                                   ev_ref       = lv_fae_ref ).

      IF lv_fae_tab IS INITIAL AND lv_fae_ref IS INITIAL.
        CONTINUE.
      ENDIF.

      IF is_fae_protected( it_statements = is_procedure-statements
                           iv_select_idx = lv_idx
                           iv_fae_tab    = lv_fae_tab
                           iv_fae_ref    = lv_fae_ref ) = abap_true.
        CONTINUE.
      ENDIF.

      lt_quickfixes = build_quickfix( is_statement = <ls_statement>
                                      iv_stmt_idx  = lv_idx
                                      iv_fae_tab   = lv_fae_tab ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-unsecure_fae
                        it_quickfixes   = lt_quickfixes ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_quickfix.
    DATA lv_indent TYPE string.
    DATA lv_col    TYPE i.

    IF is_statement-position-column > 1.
      lv_col = is_statement-position-column - 1.
      lv_indent = repeat( val = ` `
                          occ = lv_col ).
    ENDIF.

    rt_quickfixes = VALUE #(
        ( quickfix_insert_before(
              iv_quickfix_code  = c_quickfix_codes-add_guard
              iv_statement_from = iv_stmt_idx
              it_new_code       = VALUE #( ( |{ lv_indent }IF { iv_fae_tab } IS NOT INITIAL.| ) ) ) )
        ( quickfix_insert_after( iv_quickfix_code  = c_quickfix_codes-add_guard
                                 iv_statement_from = iv_stmt_idx
                                 it_new_code       = VALUE #( ( |{ lv_indent }ENDIF.| ) ) ) ) ).
  ENDMETHOD.

  METHOD extract_fae_table.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR ev_tab.
    CLEAR ev_ref.
    ls_token = zcl_skylint_ast_util=>get_token_after_sequence(
                   is_statement = is_statement
                   it_expected  = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ) ).
    IF ls_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    ev_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = ls_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data )-full_name.
    ev_tab = clean_table_name( ls_token-lexeme ).
  ENDMETHOD.

  METHOD clean_table_name.
    rv_name = iv_lexeme.
    IF rv_name CP '@*'.
      rv_name = rv_name+1.
    ENDIF.
    IF rv_name CP 'ME->*'.
      rv_name = rv_name+4.
    ENDIF.
    IF rv_name CP '*[]'.
      rv_name = substring( val = rv_name
                           len = strlen( rv_name ) - 2 ).
    ENDIF.
  ENDMETHOD.

  METHOD token_matches_table.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_matches = abap_false.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).

    IF ls_ref-full_name IS NOT INITIAL AND iv_fae_ref IS NOT INITIAL AND ls_ref-full_name = iv_fae_ref.
      rv_matches = abap_true.
      RETURN.
    ENDIF.

    IF clean_table_name( is_token-lexeme ) = iv_fae_tab.
      rv_matches = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_fae_protected.
    DATA lt_stack         TYPE ty_block_stack.
    DATA ls_cond          TYPE ty_condition_result.
    DATA lv_outer_guarded TYPE abap_bool VALUE abap_false.
    DATA lv_stack_len     TYPE i.
    DATA lv_to_idx        TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_top>  TYPE ty_block_frame.

    rv_yes = abap_false.
    lv_to_idx = iv_select_idx - 1.

    LOOP AT it_statements ASSIGNING <ls_stmt> TO lv_to_idx.
      lv_stack_len = lines( lt_stack ).

      CASE <ls_stmt>-keyword.
        WHEN 'IF'.
          ls_cond = eval_condition( is_statement = <ls_stmt>
                                    iv_fae_tab   = iv_fae_tab
                                    iv_fae_ref   = iv_fae_ref ).
          INSERT VALUE #( keyword      = 'IF'
                          is_protected = ls_cond-is_positive
                          is_negative  = ls_cond-is_negative ) INTO TABLE lt_stack.

        WHEN 'ELSEIF'.
          IF lv_stack_len > 0.
            ls_cond = eval_condition( is_statement = <ls_stmt>
                                      iv_fae_tab   = iv_fae_tab
                                      iv_fae_ref   = iv_fae_ref ).
            ASSIGN lt_stack[ lv_stack_len ] TO <ls_top>.
            <ls_top>-is_protected = ls_cond-is_positive.
            <ls_top>-is_negative  = ls_cond-is_negative.
            <ls_top>-has_exit     = abap_false.
          ENDIF.

        WHEN 'ELSE'.
          IF lv_stack_len > 0.
            ASSIGN lt_stack[ lv_stack_len ] TO <ls_top>.
            <ls_top>-is_protected = abap_false.
            <ls_top>-is_negative  = abap_false.
            <ls_top>-has_exit     = abap_false.
          ENDIF.

        WHEN 'ENDIF'.
          IF lv_stack_len > 0.
            ASSIGN lt_stack[ lv_stack_len ] TO <ls_top>.
            IF <ls_top>-is_negative = abap_true AND <ls_top>-has_exit = abap_true.
              IF lv_stack_len = 1.
                lv_outer_guarded = abap_true.
              ELSE.
                ASSIGN lt_stack[ lv_stack_len - 1 ] TO <ls_top>.
                <ls_top>-is_guarded = abap_true.
              ENDIF.
            ENDIF.
            DELETE lt_stack INDEX lv_stack_len.
          ENDIF.

        WHEN 'LOOP' OR 'WHILE' OR 'DO' OR 'CASE' OR 'TRY'.
          INSERT VALUE #( keyword = <ls_stmt>-keyword ) INTO TABLE lt_stack.

        WHEN 'ENDLOOP' OR 'ENDWHILE' OR 'ENDDO' OR 'ENDCASE' OR 'ENDTRY'.
          IF lv_stack_len > 0.
            DELETE lt_stack INDEX lv_stack_len.
          ENDIF.

        WHEN 'CHECK'.
          ls_cond = eval_condition( is_statement = <ls_stmt>
                                    iv_fae_tab   = iv_fae_tab
                                    iv_fae_ref   = iv_fae_ref ).
          IF ls_cond-is_positive = abap_true.
            IF lv_stack_len = 0.
              lv_outer_guarded = abap_true.
            ELSE.
              ASSIGN lt_stack[ lv_stack_len ] TO <ls_top>.
              <ls_top>-is_guarded = abap_true.
            ENDIF.
          ENDIF.

        WHEN 'RETURN' OR 'RAISE' OR 'EXIT'.
          IF lv_stack_len > 0.
            ASSIGN lt_stack[ lv_stack_len ] TO <ls_top>.
            <ls_top>-has_exit = abap_true.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF lv_outer_guarded = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_stack ASSIGNING <ls_top> WHERE    is_protected = abap_true
                                              OR is_guarded   = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD eval_condition.
    DATA lv_tab_found TYPE abap_bool.
    DATA lv_has_not   TYPE abap_bool.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_res.

    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'OR' ) = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF token_matches_table( is_token   = <ls_tok>
                              iv_fae_tab = iv_fae_tab
                              iv_fae_ref = iv_fae_ref ) = abap_true.
        lv_tab_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_tab_found = abap_false.
      RETURN.
    ENDIF.

    lv_has_not = zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                         iv_lexeme    = 'NOT' ).

    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'INITIAL' ) = abap_true.
      IF lv_has_not = abap_true.
        rs_res-is_positive = abap_true.
      ELSE.
        rs_res-is_negative = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = '0' )        = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = `'0'` )      = abap_true.
      LOOP AT is_statement-tokens TRANSPORTING NO FIELDS WHERE lexeme = '=' OR lexeme = '<='.
        lv_has_not = abap_true.
        EXIT.
      ENDLOOP.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'LINES(' )       = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'LINE_EXISTS(' ) = abap_true.
      IF lv_has_not = abap_true.
        rs_res-is_negative = abap_true.
      ELSE.
        rs_res-is_positive = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
