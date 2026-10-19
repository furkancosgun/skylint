CLASS zcl_skylint_no_empty_fae DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unsecure_fae TYPE if_ci_atc_check=>ty_finding_code VALUE 'FAENOCHECK',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_guard TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'FAEGUARD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EMPTY_FAE'.

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
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_tab) TYPE string.

    METHODS is_fae_protected
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_select_idx TYPE i
                iv_tab_name   TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_positive_check
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tab_name   TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_negative_check
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tab_name   TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS find_table_token_index
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tab_name   TYPE string
      RETURNING VALUE(rv_idx) TYPE i.

    METHODS token_matches_table
      IMPORTING is_token          TYPE if_ci_atc_source_code_provider=>ty_token
                iv_tab_name       TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    METHODS clean_table_name
      IMPORTING iv_lexeme      TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    METHODS build_quickfix
      IMPORTING is_statement         TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx          TYPE i
                iv_tab_name          TYPE string
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
    DATA lt_quickfixes TYPE ty_quickfixes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.
      lv_idx = sy-tabix.
      lv_fae_tab = extract_fae_table( <ls_statement> ).

      IF lv_fae_tab IS INITIAL.
        CONTINUE.
      ENDIF.

      IF is_fae_protected( it_statements = is_procedure-statements
                           iv_select_idx = lv_idx
                           iv_tab_name   = lv_fae_tab ) = abap_true.
        CONTINUE.
      ENDIF.

      lt_quickfixes = build_quickfix( is_statement = <ls_statement>
                                      iv_stmt_idx  = lv_idx
                                      iv_tab_name  = lv_fae_tab ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-unsecure_fae
                        it_quickfixes   = lt_quickfixes ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_quickfix.
    DATA lv_indent TYPE string.

    IF is_statement-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = is_statement-position-column - 1 ).
    ENDIF.

    rt_quickfixes = VALUE #(
        ( quickfix_insert_before(
              iv_quickfix_code  = c_quickfix_codes-add_guard
              iv_statement_from = iv_stmt_idx
              it_new_code       = VALUE #( ( |{ lv_indent }IF { iv_tab_name } IS NOT INITIAL.| ) ) ) )
        ( quickfix_insert_after( iv_quickfix_code  = c_quickfix_codes-add_guard
                                 iv_statement_from = iv_stmt_idx
                                 it_new_code       = VALUE #( ( |{ lv_indent }ENDIF.| ) ) ) ) ).
  ENDMETHOD.

  METHOD extract_fae_table.
    DATA ls_tab_token TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_tab.
    ls_tab_token = zcl_skylint_ast_util=>get_token_after_sequence(
                       is_statement = is_statement
                       it_expected  = VALUE #( ( `FOR` ) ( `ALL` ) ( `ENTRIES` ) ( `IN` ) ) ).
    IF ls_tab_token-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    rv_tab = clean_table_name( ls_tab_token-lexeme ).
  ENDMETHOD.

  METHOD clean_table_name.
    DATA lv_len TYPE i.

    rv_name = to_upper( iv_lexeme ).
    IF rv_name CP '@*'.
      rv_name = rv_name+1.
    ENDIF.
    IF rv_name CP '*[]'.
      lv_len = strlen( rv_name ) - 2.
      rv_name = rv_name(lv_len).
    ENDIF.
  ENDMETHOD.

  METHOD token_matches_table.
    DATA lv_clean TYPE string.
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    lv_clean = clean_table_name( is_token-lexeme ).
    IF lv_clean = iv_tab_name.
      rv_matches = abap_true.
      RETURN.
    ENDIF.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    rv_matches = xsdbool( ls_ref-full_name CS |\\DA:{ iv_tab_name }| ).
  ENDMETHOD.

  METHOD find_table_token_index.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_idx = 0.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF token_matches_table( is_token    = <ls_tok>
                              iv_tab_name = iv_tab_name ) = abap_true.
        rv_idx = sy-tabix.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_fae_protected.
    DATA lt_stack         TYPE ty_block_stack.
    DATA ls_frame         TYPE ty_block_frame.
    DATA lv_outer_guarded TYPE abap_bool VALUE abap_false.
    DATA lv_idx           TYPE i.
    DATA ls_stmt          TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_stack_len     TYPE i.
    FIELD-SYMBOLS <ls_top> TYPE ty_block_frame.

    rv_yes = abap_false.

    DO iv_select_idx - 1 TIMES.
      lv_idx = sy-index.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_idx ).
      lv_stack_len = lines( lt_stack ).

      CASE ls_stmt-keyword.
        WHEN 'IF'.
          CLEAR ls_frame.
          ls_frame-keyword      = 'IF'.
          ls_frame-is_protected = is_positive_check( is_statement = ls_stmt
                                                     iv_tab_name  = iv_tab_name ).
          ls_frame-is_negative  = is_negative_check( is_statement = ls_stmt
                                                     iv_tab_name  = iv_tab_name ).
          INSERT ls_frame INTO TABLE lt_stack.

        WHEN 'ELSEIF'.
          IF lv_stack_len > 0.
            ASSIGN lt_stack[ lv_stack_len ] TO <ls_top>.
            <ls_top>-is_protected = is_positive_check( is_statement = ls_stmt
                                                       iv_tab_name  = iv_tab_name ).
            <ls_top>-is_negative  = is_negative_check( is_statement = ls_stmt
                                                       iv_tab_name  = iv_tab_name ).
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
          CLEAR ls_frame.
          ls_frame-keyword = ls_stmt-keyword.
          INSERT ls_frame INTO TABLE lt_stack.

        WHEN 'ENDLOOP' OR 'ENDWHILE' OR 'ENDDO' OR 'ENDCASE' OR 'ENDTRY'.
          IF lv_stack_len > 0.
            DELETE lt_stack INDEX lv_stack_len.
          ENDIF.

        WHEN 'CHECK'.
          IF is_positive_check( is_statement = ls_stmt
                                iv_tab_name  = iv_tab_name ) = abap_true.
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
    ENDDO.

    IF lv_outer_guarded = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_stack ASSIGNING <ls_top>.
      IF <ls_top>-is_protected = abap_true OR <ls_top>-is_guarded = abap_true.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_positive_check.
    DATA lv_tab_idx   TYPE i.
    DATA lv_init_idx  TYPE i.
    DATA lv_tok_count TYPE i.
    DATA lv_not_count TYPE i.
    DATA ls_next      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_comp      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_prev      TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'OR' ) = abap_true.
      RETURN.
    ENDIF.

    lv_tab_idx = find_table_token_index( is_statement = is_statement
                                         iv_tab_name  = iv_tab_name ).
    IF lv_tab_idx = 0.
      RETURN.
    ENDIF.

    lv_tok_count = lines( is_statement-tokens ).

    lv_init_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'INITIAL' ).
    IF lv_init_idx > 0.
      IF lv_init_idx > 1.
        READ TABLE is_statement-tokens INTO ls_prev INDEX lv_init_idx - 1.
        IF sy-subrc = 0 AND ls_prev-lexeme = 'NOT'.
          lv_not_count += 1.
        ENDIF.
      ENDIF.
      IF lv_tab_idx > 1.
        READ TABLE is_statement-tokens INTO ls_prev INDEX lv_tab_idx - 1.
        IF sy-subrc = 0 AND ls_prev-lexeme = 'NOT'.
          lv_not_count += 1.
        ENDIF.
      ENDIF.

      IF lv_not_count = 1.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_tab_idx > 1.
      READ TABLE is_statement-tokens INTO ls_prev INDEX lv_tab_idx - 1.
      IF sy-subrc = 0 AND ls_prev-lexeme = 'LINES('.
        IF lv_tab_idx + 2 <= lv_tok_count.
          READ TABLE is_statement-tokens INTO ls_next INDEX lv_tab_idx + 1.
          IF sy-subrc = 0 AND ls_next-lexeme = ')'.
            READ TABLE is_statement-tokens INTO ls_comp INDEX lv_tab_idx + 2.
            IF sy-subrc = 0 AND ( ls_comp-lexeme = '>' OR ls_comp-lexeme = '>=' OR ls_comp-lexeme = '<>' ).
              rv_res = abap_true.
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_tab_idx > 1.
      READ TABLE is_statement-tokens INTO ls_prev INDEX lv_tab_idx - 1.
      IF sy-subrc = 0 AND ls_prev-lexeme = 'LINE_EXISTS('.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD is_negative_check.
    DATA lv_tab_idx   TYPE i.
    DATA lv_init_idx  TYPE i.
    DATA lv_tok_count TYPE i.
    DATA lv_not_count TYPE i.
    DATA ls_next      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_comp      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_prev      TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                               iv_lexeme    = 'OR' ) = abap_true.
      RETURN.
    ENDIF.

    lv_tab_idx = find_table_token_index( is_statement = is_statement
                                         iv_tab_name  = iv_tab_name ).
    IF lv_tab_idx = 0.
      RETURN.
    ENDIF.

    lv_tok_count = lines( is_statement-tokens ).

    lv_init_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'INITIAL' ).
    IF lv_init_idx > 0.
      IF lv_init_idx > 1.
        READ TABLE is_statement-tokens INTO ls_prev INDEX lv_init_idx - 1.
        IF sy-subrc = 0 AND ls_prev-lexeme = 'NOT'.
          lv_not_count += 1.
        ENDIF.
      ENDIF.
      IF lv_tab_idx > 1.
        READ TABLE is_statement-tokens INTO ls_prev INDEX lv_tab_idx - 1.
        IF sy-subrc = 0 AND ls_prev-lexeme = 'NOT'.
          lv_not_count += 1.
        ENDIF.
      ENDIF.

      IF lv_not_count = 0.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_tab_idx > 1.
      READ TABLE is_statement-tokens INTO ls_prev INDEX lv_tab_idx - 1.
      IF sy-subrc = 0 AND ls_prev-lexeme = 'LINES('.
        IF lv_tab_idx + 2 <= lv_tok_count.
          READ TABLE is_statement-tokens INTO ls_next INDEX lv_tab_idx + 1.
          IF sy-subrc = 0 AND ls_next-lexeme = ')'.
            READ TABLE is_statement-tokens INTO ls_comp INDEX lv_tab_idx + 2.
            IF sy-subrc = 0 AND ( ls_comp-lexeme = '=' OR ls_comp-lexeme = '<=' ).
              rv_res = abap_true.
              RETURN.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
