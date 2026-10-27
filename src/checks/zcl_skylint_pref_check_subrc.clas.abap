CLASS zcl_skylint_pref_check_subrc DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CHKSC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CHECK_SUBRC'.

    DATA mv_check_select_single TYPE abap_bool VALUE abap_true.
    DATA mv_check_read_table    TYPE abap_bool VALUE abap_true.
    DATA mv_check_find_search   TYPE abap_bool VALUE abap_true.
    DATA mv_check_assign        TYPE abap_bool VALUE abap_true.

    METHODS statement_sets_subrc
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_sets) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_check_subrc IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Check sy-subrc after DB, table and string operations'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-check_subrc
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Check sy-subrc after SELECT SINGLE, READ, FIND, SEARCH'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_SELECT_SINGLE'
                                                                value = REF #( mv_check_select_single ) )
                                                              ( name  = 'CHECK_READ_TABLE'
                                                                value = REF #( mv_check_read_table ) )
                                                              ( name  = 'CHECK_FIND_SEARCH'
                                                                value = REF #( mv_check_find_search ) )
                                                              ( name  = 'CHECK_ASSIGN'
                                                                value = REF #( mv_check_assign ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF statement_sets_subrc( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = lv_stmt_idx ).

      IF ls_next_stmt-keyword IS INITIAL OR zcl_skylint_ast_util=>statement_checks_sy_subrc( ls_next_stmt ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-check_subrc ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD statement_sets_subrc.
    rv_sets = abap_false.

    CASE is_statement-keyword.
      WHEN 'SELECT'.
        IF     mv_check_select_single = abap_true
           AND zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                       iv_index     = 2
                                                       iv_expected  = `SINGLE` )   = abap_true.
          rv_sets = abap_true.
        ENDIF.
      WHEN 'READ'.
        IF     mv_check_read_table = abap_true
           AND zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                       iv_index     = 2
                                                       iv_expected  = `TABLE` )    = abap_true.
          rv_sets = abap_true.
        ENDIF.
      WHEN 'FIND' OR 'SEARCH'.
        rv_sets = mv_check_find_search.
      WHEN 'ASSIGN'.
        rv_sets = mv_check_assign.
      WHEN 'OPEN'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 2
                                                   iv_expected  = `DATASET` ) = abap_true.
          rv_sets = abap_true.
        ENDIF.
      WHEN 'UPDATE'.
        IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                             iv_lexeme    = 'SET' ) > 0.
          rv_sets = abap_true.
        ENDIF.
      WHEN 'DELETE'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 2
                                                   iv_expected  = `FROM` ) = abap_true.
          rv_sets = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
