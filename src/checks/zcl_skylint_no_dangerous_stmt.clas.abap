CLASS zcl_skylint_no_dangerous_stmt DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dangerous_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'DANGER_STM',
        raise_shortdump     TYPE if_ci_atc_check=>ty_finding_code VALUE 'SHORTDUMP',
        prod_assert         TYPE if_ci_atc_check=>ty_finding_code VALUE 'PROD_ASSRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_pseudo_comments,
        dangerous_statement TYPE string VALUE 'DANGEROUS_STMT',
        raise_shortdump     TYPE string VALUE 'SHORTDUMP',
        prod_assert         TYPE string VALUE 'PROD_ASSERT',
      END OF c_pseudo_comments.

    DATA mv_check_exec_sql            TYPE abap_bool VALUE abap_true.
    DATA mv_check_kernel_call         TYPE abap_bool VALUE abap_true.
    DATA mv_check_system_call         TYPE abap_bool VALUE abap_true.
    DATA mv_check_syntax_check        TYPE abap_bool VALUE abap_true.
    DATA mv_check_insert_report       TYPE abap_bool VALUE abap_true.
    DATA mv_check_generate_dynpro     TYPE abap_bool VALUE abap_true.
    DATA mv_check_generate_report     TYPE abap_bool VALUE abap_true.
    DATA mv_check_generate_subroutine TYPE abap_bool VALUE abap_true.
    DATA mv_check_delete_report       TYPE abap_bool VALUE abap_true.
    DATA mv_check_delete_textpool     TYPE abap_bool VALUE abap_true.
    DATA mv_check_insert_textpool     TYPE abap_bool VALUE abap_true.
    DATA mv_check_delete_dynpro       TYPE abap_bool VALUE abap_true.
    DATA mv_check_export_dynpro       TYPE abap_bool VALUE abap_true.
    DATA mv_check_editor_call         TYPE abap_bool VALUE abap_true.
    DATA mv_check_dynamic_sql         TYPE abap_bool VALUE abap_true.
    DATA mv_check_raise_shortdump     TYPE abap_bool VALUE abap_true.
    DATA mv_check_prod_assert         TYPE abap_bool VALUE abap_true.
    DATA mv_ignore_rap_query_provider TYPE abap_bool VALUE abap_true.

    METHODS is_dynamic_sql
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_dangerous_stmt IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Dangerous Statements (abaplint dangerous_statement)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-dangerous_statement
                       text           = 'Dangerous statement detected; avoid dynamic/unmanaged language construct'
                       pseudo_comment = c_pseudo_comments-dangerous_statement )
                     ( code           = c_finding_codes-raise_shortdump
                       text           = 'Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions'
                       pseudo_comment = c_pseudo_comments-raise_shortdump )
                     ( code           = c_finding_codes-prod_assert
                       text           = 'Avoid native ASSERT in production logic; raise an exception instead'
                       pseudo_comment = c_pseudo_comments-prod_assert ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_EXEC_SQL'
                                                value = REF #( mv_check_exec_sql ) )
                                              ( name  = 'CHECK_KERNEL_CALL'
                                                value = REF #( mv_check_kernel_call ) )
                                              ( name  = 'CHECK_SYSTEM_CALL'
                                                value = REF #( mv_check_system_call ) )
                                              ( name  = 'CHECK_SYNTAX_CHECK'
                                                value = REF #( mv_check_syntax_check ) )
                                              ( name  = 'CHECK_INSERT_REPORT'
                                                value = REF #( mv_check_insert_report ) )
                                              ( name  = 'CHECK_GENERATE_DYNPRO'
                                                value = REF #( mv_check_generate_dynpro ) )
                                              ( name  = 'CHECK_GENERATE_REPORT'
                                                value = REF #( mv_check_generate_report ) )
                                              ( name  = 'CHECK_GENERATE_SUBROUTINE'
                                                value = REF #( mv_check_generate_subroutine ) )
                                              ( name  = 'CHECK_DELETE_REPORT'
                                                value = REF #( mv_check_delete_report ) )
                                              ( name  = 'CHECK_DELETE_TEXTPOOL'
                                                value = REF #( mv_check_delete_textpool ) )
                                              ( name  = 'CHECK_INSERT_TEXTPOOL'
                                                value = REF #( mv_check_insert_textpool ) )
                                              ( name  = 'CHECK_DELETE_DYNPRO'
                                                value = REF #( mv_check_delete_dynpro ) )
                                              ( name  = 'CHECK_EXPORT_DYNPRO'
                                                value = REF #( mv_check_export_dynpro ) )
                                              ( name  = 'CHECK_EDITOR_CALL'
                                                value = REF #( mv_check_editor_call ) )
                                              ( name  = 'CHECK_DYNAMIC_SQL'
                                                value = REF #( mv_check_dynamic_sql ) )
                                              ( name  = 'CHECK_RAISE_SHORTDUMP'
                                                value = REF #( mv_check_raise_shortdump ) )
                                              ( name  = 'CHECK_PROD_ASSERT'
                                                value = REF #( mv_check_prod_assert ) )
                                              ( name  = 'IGNORE_RAP_QUERY_PROVIDER'
                                                value = REF #( mv_ignore_rap_query_provider ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_ignore_dyn_sql TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_ignore_dyn_sql = abap_false.
    IF mv_ignore_rap_query_provider = abap_true AND is_procedure-id-name CP '*IF_RAP_QUERY_PROVIDER~SELECT'.
      lv_ignore_dyn_sql = abap_true.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'RAISE'.
          IF     mv_check_raise_shortdump = abap_true
             AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'SHORTDUMP' )  = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-raise_shortdump ).
          ENDIF.

        WHEN 'ASSERT'.
          IF mv_check_prod_assert = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-prod_assert ).
          ENDIF.

        WHEN 'SYSTEM-CALL'.
          IF mv_check_system_call = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'SYNTAX-CHECK'.
          IF mv_check_syntax_check = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'EXEC'.
          IF     mv_check_exec_sql = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `SQL` )        = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'CALL'.
          IF     mv_check_kernel_call = abap_true
             AND zcl_skylint_ast_util=>token_is_literal( zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                                                          iv_index     = 2 ) )          = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'GENERATE'.
          IF    (     mv_check_generate_subroutine = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `SUBROUTINE` ) = abap_true )
             OR (     mv_check_generate_report = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `REPORT` )     = abap_true )
             OR (     mv_check_generate_dynpro = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `DYNPRO` )     = abap_true ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'INSERT'.
          IF    (     mv_check_insert_report = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `REPORT` )     = abap_true )
             OR (     mv_check_insert_textpool = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `TEXTPOOL` )   = abap_true ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ELSEIF     mv_check_dynamic_sql             = abap_true
                 AND lv_ignore_dyn_sql                = abap_false
                 AND is_dynamic_sql( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'DELETE'.
          IF    (     mv_check_delete_report = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `REPORT` )     = abap_true )
             OR (     mv_check_delete_textpool = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `TEXTPOOL` )   = abap_true )
             OR (     mv_check_delete_dynpro = abap_true
                  AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 2
                                                              iv_expected  = `DYNPRO` )     = abap_true ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ELSEIF     mv_check_dynamic_sql             = abap_true
                 AND lv_ignore_dyn_sql                = abap_false
                 AND is_dynamic_sql( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'EXPORT'.
          IF     mv_check_export_dynpro = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `DYNPRO` )     = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'EDITOR-CALL'.
          IF     mv_check_editor_call = abap_true
             AND zcl_skylint_ast_util=>find_token_sequence(
                     is_statement = <ls_statement>
                     it_expected  = VALUE #( ( `EDITOR-CALL` ) ( `FOR` ) ( `REPORT` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.

        WHEN 'SELECT' OR 'UPDATE' OR 'MODIFY'.
          IF     mv_check_dynamic_sql             = abap_true
             AND lv_ignore_dyn_sql                = abap_false
             AND is_dynamic_sql( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-dangerous_statement ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dynamic_sql.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    IF zcl_skylint_ast_util=>statement_is_db_access( is_statement ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme CP '(*)' AND <ls_token>-lexeme <> '(*)'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
