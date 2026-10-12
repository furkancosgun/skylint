CLASS zcl_skylint_check_044 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dangerous_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'DANGER_STM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_check_system_call         TYPE abap_bool VALUE abap_true.
    DATA mv_check_syntax_check        TYPE abap_bool VALUE abap_true.
    DATA mv_check_generate_subroutine TYPE abap_bool VALUE abap_true.
    DATA mv_check_report_manipulation TYPE abap_bool VALUE abap_true.
    DATA mv_check_exec_sql            TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_check_044 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Dangerous / Unmanaged Dynamic Statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-dangerous_statement
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Dangerous or unmanaged dynamic statement detected' ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_SYSTEM_CALL'
                                                                value = REF #( mv_check_system_call ) )
                                                              ( name  = 'CHECK_SYNTAX_CHECK'
                                                                value = REF #( mv_check_syntax_check ) )
                                                              ( name  = 'CHECK_GENERATE_SUBROUTINE'
                                                                value = REF #( mv_check_generate_subroutine ) )
                                                              ( name  = 'CHECK_REPORT_MANIPULATION'
                                                                value = REF #( mv_check_report_manipulation ) )
                                                              ( name  = 'CHECK_EXEC_SQL'
                                                                value = REF #( mv_check_exec_sql ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_check_system_call TYPE abap_bool.
    DATA lv_check_syntax      TYPE abap_bool.
    DATA lv_check_generate    TYPE abap_bool.
    DATA lv_check_report      TYPE abap_bool.
    DATA lv_check_exec_sql    TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'CHECK_SYSTEM_CALL'
                   IMPORTING ev_value = lv_check_system_call ).
    get_attribute( EXPORTING iv_name  = 'CHECK_SYNTAX_CHECK'
                   IMPORTING ev_value = lv_check_syntax ).
    get_attribute( EXPORTING iv_name  = 'CHECK_GENERATE_SUBROUTINE'
                   IMPORTING ev_value = lv_check_generate ).
    get_attribute( EXPORTING iv_name  = 'CHECK_REPORT_MANIPULATION'
                   IMPORTING ev_value = lv_check_report ).
    get_attribute( EXPORTING iv_name  = 'CHECK_EXEC_SQL'
                   IMPORTING ev_value = lv_check_exec_sql ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF lv_check_system_call = abap_true AND <ls_statement>-keyword = 'SYSTEM-CALL'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
        CONTINUE.
      ENDIF.

      IF lv_check_syntax = abap_true AND <ls_statement>-keyword = 'SYNTAX-CHECK'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
        CONTINUE.
      ENDIF.

      IF     lv_check_exec_sql = abap_true
         AND <ls_statement>-keyword = 'EXEC'
         AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 2
                                                     iv_expected  = `SQL` )        = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
        CONTINUE.
      ENDIF.

      IF     lv_check_generate = abap_true
         AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                        it_expected  = VALUE #( ( `GENERATE` ) ( `SUBROUTINE` ) ) ) > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
        CONTINUE.
      ENDIF.

      IF     lv_check_report = abap_true
         AND (    zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                             it_expected  = VALUE #( ( `INSERT` ) ( `REPORT` ) ) ) > 0
               OR zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                             it_expected  = VALUE #( ( `DELETE` ) ( `REPORT` ) ) ) > 0
               OR zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                             it_expected  = VALUE #( ( `READ` ) ( `REPORT` ) ) )   > 0 ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
