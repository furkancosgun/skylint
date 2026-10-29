CLASS zcl_skylint_no_mod_std_table DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        modify_own_tables TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_MOD_STD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_MOD_STD_TABLE'.

    DATA mv_own_tables     TYPE string    VALUE '^[yz/]'.
    DATA mv_report_dynamic TYPE abap_bool VALUE abap_true.

    METHODS is_own_table
      IMPORTING iv_name        TYPE string
      RETURNING VALUE(rv_is_z) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_mod_std_table IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Modify Only Own Database Tables'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-modify_own_tables
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Modify only customer-owned database tables (see OWN_TABLES)'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'OWN_TABLES'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_own_tables ) )
                                     ( name  = 'REPORT_DYNAMIC'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_report_dynamic ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_db_table TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF zcl_skylint_ast_util=>statement_is_db_access( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'DELETE' OR 'UPDATE' OR 'INSERT' OR 'MODIFY'.
          lv_db_table = zcl_skylint_ast_util=>statement_get_db_target( <ls_statement> ).
          IF lv_db_table IS INITIAL.
            CONTINUE.
          ENDIF.

          IF lv_db_table(1) = '('.
            IF mv_report_dynamic = abap_true.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_own_tables ).
            ENDIF.
            CONTINUE.
          ENDIF.

          IF is_own_table( lv_db_table ) = abap_false.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-modify_own_tables ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_own_table.
    rv_is_z = zcl_skylint_ast_util=>matches_regex( iv_text    = to_lower( iv_name )
                                                   iv_pattern = mv_own_tables
                                                   iv_pcre    = abap_false ).
  ENDMETHOD.
ENDCLASS.
