CLASS zcl_skylint_check_035 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        db_access_in_ut TYPE if_ci_atc_check=>ty_finding_code VALUE 'DBACCESSUT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DB_ACCESS_UT'.

    METHODS is_test_procedure
      IMPORTING is_procedure  TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_direct_db_access
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_db_delete
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_db_insert
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_db_modify
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS has_token
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_035 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural kaldırılsın
    super->constructor(
        VALUE #( description       = 'Avoid direct database access in unit tests'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-db_access_in_ut
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid direct database operations in unit tests; use test doubles'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_test_procedure( is_procedure ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_direct_db_access( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-db_access_in_ut ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_test_procedure.
    DATA ls_stmt      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_proc_name TYPE string.
    DATA lv_unit_name TYPE string.

    rv_res = abap_false.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-method.
      RETURN.
    ENDIF.

    lv_proc_name = to_upper( is_procedure-id-name ).
    lv_unit_name = to_upper( is_procedure-id-main_unit-name ).

    IF    lv_proc_name CP 'TEST*'  OR lv_proc_name CP '*TEST*'
       OR lv_unit_name CP '*TEST*' OR lv_unit_name CP 'LTC*' OR lv_unit_name CP 'LTCL*'.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements INTO ls_stmt.
      IF    has_token( is_statement = ls_stmt
                       iv_lexeme    = 'TESTING' )             = abap_true
         OR has_token( is_statement = ls_stmt
                       iv_lexeme    = 'HARMLESS' )            = abap_true
         OR has_token( is_statement = ls_stmt
                       iv_lexeme    = 'CL_ABAP_UNIT_ASSERT' ) = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_direct_db_access.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_res = abap_false.

    " 1. Check compiler references if present
    LOOP AT is_statement-tokens INTO ls_tok.
      LOOP AT ls_tok-references INTO ls_ref.
        IF    ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read_database
           OR ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-write_database.
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " 2. Syntactic AST classification
    CASE is_statement-keyword.
      WHEN 'SELECT' OR 'COMMIT' OR 'ROLLBACK' OR 'UPDATE'.
        rv_res = abap_true.
      WHEN 'DELETE'.
        rv_res = is_db_delete( is_statement ).
      WHEN 'INSERT'.
        rv_res = is_db_insert( is_statement ).
      WHEN 'MODIFY'.
        rv_res = is_db_modify( is_statement ).
    ENDCASE.
  ENDMETHOD.

  METHOD is_db_delete.
    rv_res = abap_false.

    IF matches_token_at( is_statement      = is_statement
                         iv_index          = 2
                         iv_expected       = `TABLE`
                         iv_case_sensitive = abap_true ) = abap_true.
      RETURN.
    ENDIF.

    IF    has_token( is_statement = is_statement
                     iv_lexeme    = 'INDEX' )    = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'ADJACENT' ) = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'TO' )       = abap_true.
      RETURN.
    ENDIF.

    IF has_token( is_statement = is_statement
                  iv_lexeme    = 'FROM' ) = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_db_insert.
    rv_res = abap_false.
    IF    has_token( is_statement = is_statement
                     iv_lexeme    = 'TABLE' )    = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'INDEX' )    = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'LINES' )    = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'INITIAL' )  = abap_true.
      RETURN.
    ENDIF.

    IF    has_token( is_statement = is_statement
                     iv_lexeme    = 'FROM' )     = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'VALUES' )   = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_db_modify.
    rv_res = abap_false.
    IF matches_token_at( is_statement      = is_statement
                         iv_index          = 2
                         iv_expected       = `TABLE`
                         iv_case_sensitive = abap_true ) = abap_true.
      RETURN.
    ENDIF.

    IF    has_token( is_statement = is_statement
                     iv_lexeme    = 'INDEX' )        = abap_true
       OR has_token( is_statement = is_statement
                     iv_lexeme    = 'TRANSPORTING' ) = abap_true.
      RETURN.
    ENDIF.

    IF has_token( is_statement = is_statement
                  iv_lexeme    = 'FROM' ) = abap_true.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_token.
    rv_res = has_token_lexeme( is_statement = is_statement
                               iv_lexeme    = iv_lexeme ).
  ENDMETHOD.
ENDCLASS.
