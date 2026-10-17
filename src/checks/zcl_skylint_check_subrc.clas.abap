CLASS zcl_skylint_check_subrc DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHECK_SUBRC'.

    DATA mv_check_select_single   TYPE abap_bool VALUE abap_true.
    DATA mv_check_read_table      TYPE abap_bool VALUE abap_true.
    DATA mv_check_authority_check TYPE abap_bool VALUE abap_true.
    DATA mv_check_find_search     TYPE abap_bool VALUE abap_true.
    DATA mv_check_assign          TYPE abap_bool VALUE abap_true.

    METHODS statement_sets_subrc
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_sets) TYPE abap_bool.

    METHODS checks_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_subrc_token
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_subrc IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Check sy-subrc after DB, table and string operations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-check_subrc
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Check sy-subrc after SELECT SINGLE, READ, AUTHORITY-CHECK, FIND, SEARCH'
                       pseudo_comment = c_pseudo_comment ) )
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
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF statement_sets_subrc( <ls_statement> ) = abap_false.
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
      WHEN 'AUTHORITY-CHECK'.
        rv_sets = mv_check_authority_check.
      WHEN 'FIND' OR 'SEARCH'.
        rv_sets = mv_check_find_search.
      WHEN 'ASSIGN'.
        rv_sets = mv_check_assign.
    ENDCASE.
  ENDMETHOD.

  METHOD checks_sy_subrc.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF is_subrc_token( <ls_token> ) = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_subrc_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_is = abap_false.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE     kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
               AND usage_mode = if_ci_atc_source_code_provider=>usage_modes-read.
      IF <ls_ref>-full_name = '\DA:SY\DA:SUBRC' OR <ls_ref>-full_name = '\DA:SYST\DA:SUBRC'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
