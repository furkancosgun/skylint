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

    METHODS run_for_testing
      IMPORTING is_procedure     TYPE if_ci_atc_source_code_provider=>ty_procedure
                io_code_provider TYPE REF TO if_ci_atc_source_code_provider OPTIONAL
      RETURNING VALUE(rt_findings) TYPE if_ci_atc_check=>ty_findings.

  PROTECTED SECTION.
    METHODS check ABSTRACT
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

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

  METHOD is_open_abap.
    rv_result = xsdbool( sy-saprl = 'OPEN' ).
  ENDMETHOD.

  METHOD run_for_testing.
    mo_code_provider = io_code_provider.
    CLEAR mt_findings.
    check( is_procedure ).
    rt_findings = mt_findings.
  ENDMETHOD.
ENDCLASS.
