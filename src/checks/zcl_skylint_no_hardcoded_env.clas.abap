CLASS zcl_skylint_no_hardcoded_env DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        hardcoded_env TYPE if_ci_atc_check=>ty_finding_code VALUE 'ENV_CHECK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'HARDCODED_ENV'.

    CONSTANTS:
      BEGIN OF c_env_vars,
        none  TYPE string VALUE '',
        sysid TYPE string VALUE 'SYSID',
        mandt TYPE string VALUE 'MANDT',
        host  TYPE string VALUE 'HOST',
        dbsys TYPE string VALUE 'DBSYS',
        opsys TYPE string VALUE 'OPSYS',
        uname TYPE string VALUE 'UNAME',
      END OF c_env_vars.

    DATA mv_check_sysid      TYPE abap_bool VALUE abap_true.
    DATA mv_check_mandt      TYPE abap_bool VALUE abap_true.
    DATA mv_check_host       TYPE abap_bool VALUE abap_true.
    DATA mv_check_dbsys      TYPE abap_bool VALUE abap_true.
    DATA mv_check_opsys      TYPE abap_bool VALUE abap_true.
    DATA mv_check_uname      TYPE abap_bool VALUE abap_true.
    DATA mv_only_conditional TYPE abap_bool VALUE abap_false.

    METHODS is_env_var_token
      IMPORTING is_token          TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_env_var) TYPE string.

    METHODS is_env_enabled
      IMPORTING iv_env_var        TYPE string
      RETURNING VALUE(rv_enabled) TYPE abap_bool.

    METHODS is_statement_conditional
      IMPORTING is_statement          TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_conditional) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_hardcoded_env IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid reading environment system fields (sy-sysid, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-hardcoded_env
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid reading environment system fields (sy-sysid, sy-uname, etc.)'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_SYSID'
                                                value = REF #( mv_check_sysid ) )
                                              ( name  = 'CHECK_MANDT'
                                                value = REF #( mv_check_mandt ) )
                                              ( name  = 'CHECK_HOST'
                                                value = REF #( mv_check_host ) )
                                              ( name  = 'CHECK_DBSYS'
                                                value = REF #( mv_check_dbsys ) )
                                              ( name  = 'CHECK_OPSYS'
                                                value = REF #( mv_check_opsys ) )
                                              ( name  = 'CHECK_UNAME'
                                                value = REF #( mv_check_uname ) )
                                              ( name  = 'ONLY_CONDITIONAL'
                                                value = REF #( mv_only_conditional ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_env TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF mv_only_conditional = abap_true AND is_statement_conditional( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_env = is_env_var_token( <ls_token> ).
        IF lv_env IS NOT INITIAL AND is_env_enabled( lv_env ) = abap_true.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-hardcoded_env ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_env_var_token.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_env_var = c_env_vars-none.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    IF ls_ref-full_name IS INITIAL.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>is_read_usage( ls_ref ) = abap_false.
      RETURN.
    ENDIF.

    CASE ls_ref-full_name.
      WHEN '\DA:SY\DA:SYSID' OR '\DA:SYST\DA:SYSID'.
        rv_env_var = c_env_vars-sysid.
      WHEN '\DA:SY\DA:MANDT' OR '\DA:SYST\DA:MANDT'.
        rv_env_var = c_env_vars-mandt.
      WHEN '\DA:SY\DA:HOST' OR '\DA:SYST\DA:HOST'.
        rv_env_var = c_env_vars-host.
      WHEN '\DA:SY\DA:DBSYS' OR '\DA:SYST\DA:DBSYS'.
        rv_env_var = c_env_vars-dbsys.
      WHEN '\DA:SY\DA:OPSYS' OR '\DA:SYST\DA:OPSYS'.
        rv_env_var = c_env_vars-opsys.
      WHEN '\DA:SY\DA:UNAME' OR '\DA:SYST\DA:UNAME'.
        rv_env_var = c_env_vars-uname.
    ENDCASE.
  ENDMETHOD.

  METHOD is_env_enabled.
    rv_enabled = abap_false.
    CASE iv_env_var.
      WHEN c_env_vars-sysid.
        rv_enabled = mv_check_sysid.
      WHEN c_env_vars-mandt.
        rv_enabled = mv_check_mandt.
      WHEN c_env_vars-host.
        rv_enabled = mv_check_host.
      WHEN c_env_vars-dbsys.
        rv_enabled = mv_check_dbsys.
      WHEN c_env_vars-opsys.
        rv_enabled = mv_check_opsys.
      WHEN c_env_vars-uname.
        rv_enabled = mv_check_uname.
    ENDCASE.
  ENDMETHOD.

  METHOD is_statement_conditional.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_conditional = abap_false.

    CASE is_statement-keyword.
      WHEN 'IF' OR 'ELSEIF' OR 'CHECK' OR 'WHILE' OR 'CASE' OR 'WHEN'.
        rv_conditional = abap_true.
        RETURN.
    ENDCASE.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok> WHERE references IS INITIAL.
      IF    <ls_tok>-lexeme = 'COND'
         OR <ls_tok>-lexeme = 'SWITCH'
         OR <ls_tok>-lexeme = 'WHERE'.
        rv_conditional = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
