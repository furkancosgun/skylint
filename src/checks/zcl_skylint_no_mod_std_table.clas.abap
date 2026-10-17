CLASS zcl_skylint_no_mod_std_table DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        modify_own_tables TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOT_OWN_TB',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OWN_TABLES'.

    METHODS get_db_target_table
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_table) TYPE string.

    METHODS is_customer_namespace
      IMPORTING iv_name        TYPE string
      RETURNING VALUE(rv_is_z) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_mod_std_table IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Modify Only Own Database Tables'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-modify_own_tables
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Modify only customer-owned (Z/Y or /.../) database tables'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_db_table TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF zcl_skylint_ast_util=>statement_is_db_access( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'DELETE' OR 'UPDATE' OR 'INSERT' OR 'MODIFY'.
          lv_db_table = get_db_target_table( <ls_statement> ).
          IF lv_db_table IS NOT INITIAL.
            IF lv_db_table(1) = '(' OR lv_db_table(1) = '@'.
              CONTINUE.
            ENDIF.

            IF is_customer_namespace( lv_db_table ) = abap_false.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-modify_own_tables ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_db_target_table.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rv_table.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      LOOP AT <ls_tok>-references ASSIGNING <ls_ref>.
        IF    <ls_ref>-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-write_database
           OR <ls_ref>-full_name  CP '\DB:*'.
          IF <ls_ref>-full_name CP '\DB:*'.
            rv_table = substring( val = <ls_ref>-full_name
                                  off = 4 ).
          ELSE.
            rv_table = <ls_tok>-lexeme.
          ENDIF.
          RETURN.
        ELSEIF     <ls_ref>-kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-type
               AND <ls_ref>-full_name CP '\TY:*'
               AND <ls_ref>-full_name NP '\TY:*\TY:*'.
          rv_table = substring( val = <ls_ref>-full_name
                                off = 4 ).
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_customer_namespace.
    rv_is_z = abap_false.

    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.

    rv_is_z = xsdbool( iv_name(1) CA '/YZ' ).
  ENDMETHOD.
ENDCLASS.
