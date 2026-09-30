CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

    TYPES ty_quickfix_code TYPE c LENGTH 10.

    CLASS-METHODS is_open_abap
      RETURNING VALUE(rv_result) TYPE abap_bool.

    METHODS constructor
      IMPORTING is_config TYPE zcl_skylint_check_meta_data=>ty_config OPTIONAL.

  PROTECTED SECTION.
    METHODS check ABSTRACT
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    TYPES ty_token_lexemes TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS get_token_safe
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index     TYPE i
      EXPORTING es_token     TYPE if_ci_atc_source_code_provider=>ty_token
                ev_found     TYPE abap_bool.

    METHODS get_statement_safe
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_index       TYPE i
      EXPORTING es_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                ev_found       TYPE abap_bool.

    METHODS find_token_sequence
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_index)   TYPE i.

    METHODS match_token_sequence
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                it_expected       TYPE ty_token_lexemes
                iv_start_index    TYPE i DEFAULT 1
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    METHODS matches_token_at
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_index          TYPE i
                iv_expected       TYPE string
                iv_case_sensitive TYPE abap_bool DEFAULT abap_false
      RETURNING VALUE(rv_matched) TYPE abap_bool.

    METHODS token_has_ref
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_kind       TYPE if_ci_atc_source_code_provider=>ty_reference_kind
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS statement_has_db_access
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS statement_is_method_call
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_token_lexeme
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_lexeme     TYPE string
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS report_statement
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code
                iv_param_1      TYPE string                      OPTIONAL
                iv_param_2      TYPE string                      OPTIONAL
                iv_param_3      TYPE string                      OPTIONAL
                iv_param_4      TYPE string                      OPTIONAL
                io_details      TYPE if_ci_atc_check=>ty_details OPTIONAL.

    METHODS report_token
      IMPORTING is_token        TYPE if_ci_atc_source_code_provider=>ty_token
                is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code
                iv_param_1      TYPE string                      OPTIONAL
                iv_param_2      TYPE string                      OPTIONAL
                iv_param_3      TYPE string                      OPTIONAL
                iv_param_4      TYPE string                      OPTIONAL
                io_details      TYPE if_ci_atc_check=>ty_details OPTIONAL.

    METHODS report_finding
      IMPORTING is_finding TYPE if_ci_atc_check=>ty_finding.

    METHODS get_attribute
      IMPORTING iv_name  TYPE string
      EXPORTING ev_value TYPE any.

    METHODS quickfix_replace
      IMPORTING iv_quickfix_code  TYPE ty_quickfix_code
                is_procedure_id   TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_from TYPE i
                iv_statement_to   TYPE i OPTIONAL
                iv_token_from     TYPE i OPTIONAL
                iv_token_to       TYPE i OPTIONAL
                it_new_code       TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details) TYPE if_ci_atc_check=>ty_details.

    METHODS quickfix_insert_before
      IMPORTING iv_quickfix_code   TYPE ty_quickfix_code
                is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index TYPE i
                it_new_code        TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)  TYPE if_ci_atc_check=>ty_details.

    METHODS quickfix_insert_after
      IMPORTING iv_quickfix_code   TYPE ty_quickfix_code
                is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index TYPE i
                it_new_code        TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)  TYPE if_ci_atc_check=>ty_details.

    METHODS quickfix_delete
      IMPORTING iv_quickfix_code   TYPE ty_quickfix_code
                is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index TYPE i
      RETURNING VALUE(ro_details)  TYPE if_ci_atc_check=>ty_details.

  PRIVATE SECTION.
    DATA mo_code_provider     TYPE REF TO if_ci_atc_source_code_provider.
    DATA mo_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory.
    DATA mo_meta_data         TYPE REF TO zcl_skylint_check_meta_data.
    DATA mt_findings          TYPE if_ci_atc_check=>ty_findings.
    DATA mt_attributes        TYPE if_ci_atc_check_meta_data=>ty_attributes.

ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.
  METHOD constructor.
    mo_meta_data = NEW zcl_skylint_check_meta_data( is_config ).
  ENDMETHOD.

  METHOD if_ci_atc_check~get_meta_data.
    meta_data = mo_meta_data.
  ENDMETHOD.

  METHOD if_ci_atc_check~set_assistant_factory.
    mo_assistant_factory = factory.
  ENDMETHOD.

  METHOD if_ci_atc_check~set_attributes.
    mt_attributes = attributes.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    DATA ls_unit       TYPE if_ci_atc_source_code_provider=>ty_compilation_unit.
    DATA lr_procedures TYPE REF TO if_ci_atc_source_code_provider=>ty_procedures.
    FIELD-SYMBOLS <ls_procedure> TYPE if_ci_atc_source_code_provider=>ty_procedure.

    CLEAR mt_findings.
    mo_code_provider = data_provider->get_code_provider( ).

    TRY.
        ls_unit = mo_code_provider->object_to_comp_unit( object ).
        lr_procedures = mo_code_provider->get_procedures( ls_unit ).
        LOOP AT lr_procedures->* ASSIGNING <ls_procedure>.
          check( <ls_procedure> ).
        ENDLOOP.
      CATCH cx_static_check.
        RETURN.
    ENDTRY.

    findings = mt_findings.
  ENDMETHOD.

  METHOD report_statement.
    DATA ls_finding TYPE if_ci_atc_check=>ty_finding.

    ls_finding = lcl_reporter=>create_statement_finding( io_code_provider = mo_code_provider
                                                         io_meta_data     = mo_meta_data
                                                         is_statement     = is_statement
                                                         iv_finding_code  = iv_finding_code
                                                         iv_param_1       = iv_param_1
                                                         iv_param_2       = iv_param_2
                                                         iv_param_3       = iv_param_3
                                                         iv_param_4       = iv_param_4
                                                         io_details       = io_details ).
    INSERT ls_finding INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD report_token.
    DATA ls_finding TYPE if_ci_atc_check=>ty_finding.

    ls_finding = lcl_reporter=>create_token_finding( io_code_provider = mo_code_provider
                                                     io_meta_data     = mo_meta_data
                                                     is_token         = is_token
                                                     is_statement     = is_statement
                                                     iv_finding_code  = iv_finding_code
                                                     iv_param_1       = iv_param_1
                                                     iv_param_2       = iv_param_2
                                                     iv_param_3       = iv_param_3
                                                     iv_param_4       = iv_param_4
                                                     io_details       = io_details ).
    INSERT ls_finding INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD report_finding.
    INSERT is_finding INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD get_attribute.
    FIELD-SYMBOLS <ls_attr>  TYPE if_ci_atc_check_meta_data=>ty_attribute.
    FIELD-SYMBOLS <lv_value> TYPE any.

    CLEAR ev_value.
    ASSIGN mt_attributes[ name = iv_name ] TO <ls_attr>.
    IF sy-subrc = 0 AND <ls_attr>-value IS BOUND.
      ASSIGN <ls_attr>-value->* TO <lv_value>.
      IF sy-subrc = 0.
        ev_value = <lv_value>.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD quickfix_replace.
    ro_details = lcl_quickfix=>replace_code( io_assistant_factory = mo_assistant_factory
                                             iv_quickfix_code     = iv_quickfix_code
                                             is_procedure_id      = is_procedure_id
                                             iv_statement_from    = iv_statement_from
                                             iv_statement_to      = iv_statement_to
                                             iv_token_from        = iv_token_from
                                             iv_token_to          = iv_token_to
                                             it_new_code          = it_new_code ).
  ENDMETHOD.

  METHOD quickfix_insert_before.
    ro_details = lcl_quickfix=>insert_before( io_assistant_factory = mo_assistant_factory
                                              iv_quickfix_code     = iv_quickfix_code
                                              is_procedure_id      = is_procedure_id
                                              iv_statement_index   = iv_statement_index
                                              it_new_code          = it_new_code ).
  ENDMETHOD.

  METHOD quickfix_insert_after.
    ro_details = lcl_quickfix=>insert_after( io_assistant_factory = mo_assistant_factory
                                             iv_quickfix_code     = iv_quickfix_code
                                             is_procedure_id      = is_procedure_id
                                             iv_statement_index   = iv_statement_index
                                             it_new_code          = it_new_code ).
  ENDMETHOD.

  METHOD quickfix_delete.
    ro_details = lcl_quickfix=>delete( io_assistant_factory = mo_assistant_factory
                                       iv_quickfix_code     = iv_quickfix_code
                                       is_procedure_id      = is_procedure_id
                                       iv_statement_index   = iv_statement_index ).
  ENDMETHOD.

  METHOD get_token_safe.
    zcl_skylint_ast_util=>get_token_safe(
      EXPORTING
        is_statement = is_statement
        iv_index     = iv_index
      IMPORTING
        es_token     = es_token
        ev_found     = ev_found ).
  ENDMETHOD.

  METHOD get_statement_safe.
    zcl_skylint_ast_util=>get_statement_safe(
      EXPORTING
        it_statements = it_statements
        iv_index      = iv_index
      IMPORTING
        es_statement  = es_statement
        ev_found      = ev_found ).
  ENDMETHOD.

  METHOD find_token_sequence.
    rv_index = zcl_skylint_ast_util=>find_token_sequence(
        is_statement      = is_statement
        it_expected       = it_expected
        iv_start_index    = iv_start_index
        iv_case_sensitive = iv_case_sensitive ).
  ENDMETHOD.

  METHOD match_token_sequence.
    rv_matched = zcl_skylint_ast_util=>match_token_sequence(
        is_statement      = is_statement
        it_expected       = it_expected
        iv_start_index    = iv_start_index
        iv_case_sensitive = iv_case_sensitive ).
  ENDMETHOD.

  METHOD matches_token_at.
    rv_matched = zcl_skylint_ast_util=>matches_token_at(
        is_statement      = is_statement
        iv_index          = iv_index
        iv_expected       = iv_expected
        iv_case_sensitive = iv_case_sensitive ).
  ENDMETHOD.

  METHOD token_has_ref.
    rv_has = zcl_skylint_ast_util=>token_has_ref(
        is_token = is_token
        iv_kind  = iv_kind ).
  ENDMETHOD.

  METHOD statement_has_db_access.
    rv_has = zcl_skylint_ast_util=>statement_has_db_access( is_statement ).
  ENDMETHOD.

  METHOD statement_is_method_call.
    rv_has = zcl_skylint_ast_util=>statement_is_method_call( is_statement ).
  ENDMETHOD.

  METHOD has_token_lexeme.
    rv_has = zcl_skylint_ast_util=>has_token_lexeme(
        is_statement = is_statement
        iv_lexeme    = iv_lexeme ).
  ENDMETHOD.

  METHOD is_open_abap.
    rv_result = xsdbool( sy-saprl = 'OPEN' ).
  ENDMETHOD.
ENDCLASS.
