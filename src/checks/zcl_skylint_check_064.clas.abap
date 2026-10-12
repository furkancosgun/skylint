CLASS zcl_skylint_check_064 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHECKSUBRC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_check_select_single   TYPE abap_bool VALUE abap_true.
    DATA mv_check_read_table      TYPE abap_bool VALUE abap_true.
    DATA mv_check_authority_check TYPE abap_bool VALUE abap_true.
    DATA mv_check_find_search     TYPE abap_bool VALUE abap_true.
    DATA mv_check_assign          TYPE abap_bool VALUE abap_true.

    METHODS checks_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_064 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Check sy-subrc after DB, table and string operations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-check_subrc
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Check sy-subrc after SELECT SINGLE, READ, AUTHORITY-CHECK, FIND, SEARCH' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_SELECT_SINGLE'
                                                value = REF #( mv_check_select_single ) )
                                              ( name  = 'CHECK_READ_TABLE'
                                                value = REF #( mv_check_read_table ) )
                                              ( name  = 'CHECK_AUTHORITY_CHECK'
                                                value = REF #( mv_check_authority_check ) )
                                              ( name  = 'CHECK_FIND_SEARCH'
                                                value = REF #( mv_check_find_search ) )
                                              ( name  = 'CHECK_ASSIGN'
                                                value = REF #( mv_check_assign ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_check_sel_single TYPE abap_bool.
    DATA lv_check_read_tab   TYPE abap_bool.
    DATA lv_check_auth       TYPE abap_bool.
    DATA lv_check_find       TYPE abap_bool.
    DATA lv_check_assign     TYPE abap_bool.
    DATA lv_sets_subrc       TYPE abap_bool.
    DATA ls_next_stmt        TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'CHECK_SELECT_SINGLE'
                   IMPORTING ev_value = lv_check_sel_single ).
    get_attribute( EXPORTING iv_name  = 'CHECK_READ_TABLE'
                   IMPORTING ev_value = lv_check_read_tab ).
    get_attribute( EXPORTING iv_name  = 'CHECK_AUTHORITY_CHECK'
                   IMPORTING ev_value = lv_check_auth ).
    get_attribute( EXPORTING iv_name  = 'CHECK_FIND_SEARCH'
                   IMPORTING ev_value = lv_check_find ).
    get_attribute( EXPORTING iv_name  = 'CHECK_ASSIGN'
                   IMPORTING ev_value = lv_check_assign ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_sets_subrc = abap_false.

      CASE <ls_statement>-keyword.
        WHEN 'SELECT'.
          IF     lv_check_sel_single = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `SINGLE` )     = abap_true.
            lv_sets_subrc = abap_true.
          ENDIF.
        WHEN 'READ'.
          IF     lv_check_read_tab = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `TABLE` )      = abap_true.
            lv_sets_subrc = abap_true.
          ENDIF.
        WHEN 'AUTHORITY-CHECK'.
          IF lv_check_auth = abap_true.
            lv_sets_subrc = abap_true.
          ENDIF.
        WHEN 'FIND' OR 'SEARCH'.
          IF lv_check_find = abap_true.
            lv_sets_subrc = abap_true.
          ENDIF.
        WHEN 'ASSIGN'.
          IF lv_check_assign = abap_true.
            lv_sets_subrc = abap_true.
          ENDIF.
      ENDCASE.

      IF lv_sets_subrc = abap_false.
        CONTINUE.
      ENDIF.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = sy-tabix ).

      IF ls_next_stmt-keyword IS INITIAL OR checks_sy_subrc( ls_next_stmt ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-check_subrc ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD checks_sy_subrc.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex TYPE string.

    rv_res = abap_false.
    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = ls_tok-lexeme.
      IF lv_lex = 'SY-SUBRC'.
        rv_res = abap_true.
        RETURN.
      ENDIF.

      LOOP AT ls_tok-references TRANSPORTING NO FIELDS
           WHERE     full_name  CS 'SUBRC'
                 AND usage_mode  = if_ci_atc_source_code_provider=>usage_modes-read.
        rv_res = abap_true.
        RETURN.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
