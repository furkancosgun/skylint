CLASS /skyl/cl_no_full_scan_sel DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        full_scan TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_FULL_SC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_FULL_SCAN_SELECT'.

    DATA mv_allow_up_to_n TYPE abap_bool VALUE abap_false.

    METHODS has_top_level_where
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_full_scan_sel IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Flag SELECT statements on DB tables without a WHERE clause'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-full_scan
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid SELECT without a WHERE condition on database tables (full table scan)'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'ALLOW_UP_TO_N'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_allow_up_to_n ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_table TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SELECT'.
        CONTINUE.
      ENDIF.

      lv_table = /skyl/cl_ast_util=>statement_get_db_target( <ls_statement> ).
      IF lv_table IS NOT INITIAL AND lv_table(1) = '@'.
        CONTINUE.
      ENDIF.

      IF has_top_level_where( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      IF     mv_allow_up_to_n = abap_true
         AND /skyl/cl_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `UP` ) ( `TO` ) ) ) > 0.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-full_scan ).
    ENDLOOP.
  ENDMETHOD.

  METHOD has_top_level_where.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_depth = 0 AND /skyl/cl_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                               iv_lexeme = 'WHERE' ) = abap_true.
        rv_has = abap_true.
        RETURN.
      ENDIF.
      lv_depth += /skyl/cl_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
