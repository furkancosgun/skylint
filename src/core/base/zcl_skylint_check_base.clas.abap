CLASS zcl_skylint_check_base DEFINITION
  PUBLIC ABSTRACT
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_ci_atc_check.

  PROTECTED SECTION.
    DATA mo_code_provider     TYPE REF TO if_ci_atc_source_code_provider.
    DATA mo_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory.
    DATA ms_current_object    TYPE if_ci_atc_check=>ty_object.
    DATA mt_findings          TYPE if_ci_atc_check=>ty_findings.
    DATA mo_meta_data_handler TYPE REF TO zcl_skylint_check_meta_data.
    DATA mo_analyzer          TYPE REF TO zif_skylint_analyzer.
    DATA mo_hook_chain        TYPE REF TO zcl_skylint_hook_chain.

    METHODS get_analyzer
      RETURNING VALUE(ro_analyzer) TYPE REF TO zif_skylint_analyzer.

    METHODS register_hook
      IMPORTING io_hook TYPE REF TO zif_skylint_hook.

    METHODS get_hook_chain
      RETURNING VALUE(ro_chain) TYPE REF TO zcl_skylint_hook_chain.

    METHODS set_hook_chain
      IMPORTING io_chain TYPE REF TO zcl_skylint_hook_chain.

    METHODS describe ABSTRACT
      RETURNING VALUE(rs_result) TYPE zcl_skylint_check_meta_data=>ty_config.

    METHODS check ABSTRACT
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS on_before_check.
    METHODS on_after_check.

    METHODS report_statement
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code
                iv_param_1      TYPE string                           OPTIONAL
                iv_param_2      TYPE string                           OPTIONAL
                iv_param_3      TYPE string                           OPTIONAL
                iv_param_4      TYPE string                           OPTIONAL
                io_details      TYPE REF TO cl_ci_atc_finding_details OPTIONAL.

    METHODS report_token
      IMPORTING is_token        TYPE if_ci_atc_source_code_provider=>ty_token
                is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code
                iv_param_1      TYPE string                           OPTIONAL
                iv_param_2      TYPE string                           OPTIONAL
                iv_param_3      TYPE string                           OPTIONAL
                iv_param_4      TYPE string                           OPTIONAL
                io_details      TYPE REF TO cl_ci_atc_finding_details OPTIONAL.

    METHODS report_finding
      IMPORTING is_finding TYPE if_ci_atc_check=>ty_finding.

    METHODS create_quickfix_replace
      IMPORTING iv_quickfix_code  TYPE cl_ci_atc_quickfixes=>ty_quickfix_code
                is_procedure_id   TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_from TYPE i
                iv_statement_to   TYPE i OPTIONAL
                iv_token_from     TYPE i OPTIONAL
                iv_token_to       TYPE i OPTIONAL
                it_new_code       TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details) TYPE REF TO cl_ci_atc_finding_details.

    METHODS create_quickfix_insert_before
      IMPORTING iv_quickfix_code   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code
                is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index TYPE i
                it_new_code        TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)  TYPE REF TO cl_ci_atc_finding_details.

    METHODS create_quickfix_insert_after
      IMPORTING iv_quickfix_code   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code
                is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index TYPE i
                it_new_code        TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)  TYPE REF TO cl_ci_atc_finding_details.

  PRIVATE SECTION.
    METHODS ensure_metadata.
ENDCLASS.


CLASS zcl_skylint_check_base IMPLEMENTATION.
  METHOD ensure_metadata.
    IF mo_meta_data_handler IS BOUND.
      RETURN.
    ENDIF.
    mo_meta_data_handler = NEW zcl_skylint_check_meta_data( describe( ) ).
  ENDMETHOD.

  METHOD if_ci_atc_check~get_meta_data.
    ensure_metadata( ).
    meta_data = mo_meta_data_handler.
  ENDMETHOD.

  METHOD if_ci_atc_check~set_assistant_factory.
    mo_assistant_factory = factory.
  ENDMETHOD.

  METHOD if_ci_atc_check~set_attributes.
    IF mo_hook_chain IS BOUND.
      mo_hook_chain->execute_set_attributes( attributes ).
    ENDIF.
  ENDMETHOD.

  METHOD if_ci_atc_check~verify_prerequisites.
    IF mo_hook_chain IS BOUND.
      verification_findings = mo_hook_chain->execute_verify( ).
    ENDIF.
  ENDMETHOD.

  METHOD if_ci_atc_check~run.
    CLEAR mt_findings.
    ensure_metadata( ).
    ms_current_object = object.
    mo_code_provider = data_provider->get_code_provider( ).

    on_before_check( ).

    TRY.
        DATA(lv_unit) = mo_code_provider->object_to_comp_unit( ms_current_object ).
        DATA(lr_procedures) = mo_code_provider->get_procedures( lv_unit ).
        LOOP AT lr_procedures->* ASSIGNING FIELD-SYMBOL(<ls_procedure>).
          check( <ls_procedure> ).
        ENDLOOP.
      CATCH cx_root.
        RETURN.
    ENDTRY.

    on_after_check( ).
    findings = mt_findings.
  ENDMETHOD.

  METHOD get_analyzer.
    IF mo_analyzer IS NOT BOUND.
      mo_analyzer = zcl_skylint_analyzer=>get_instance( ).
    ENDIF.
    ro_analyzer = mo_analyzer.
  ENDMETHOD.

  METHOD register_hook.
    IF mo_hook_chain IS NOT BOUND.
      mo_hook_chain = NEW zcl_skylint_hook_chain( ).
    ENDIF.
    mo_hook_chain->register_hook( io_hook ).
  ENDMETHOD.

  METHOD get_hook_chain.
    IF mo_hook_chain IS NOT BOUND.
      mo_hook_chain = NEW zcl_skylint_hook_chain( ).
    ENDIF.
    ro_chain = mo_hook_chain.
  ENDMETHOD.

  METHOD set_hook_chain.
    mo_hook_chain = io_chain.
  ENDMETHOD.

  METHOD on_before_check.
    IF mo_hook_chain IS BOUND.
      mo_hook_chain->execute_before( ).
    ENDIF.
  ENDMETHOD.

  METHOD on_after_check.
    IF mo_hook_chain IS BOUND.
      mo_hook_chain->execute_after( ).
    ENDIF.
  ENDMETHOD.

  METHOD report_finding.
    INSERT is_finding INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD report_statement.
    DATA(ls_location) = mo_code_provider->get_statement_location( is_statement ).
    DATA(lv_checksum) = mo_code_provider->get_statement_checksum( is_statement ).
    DATA(lv_has_pc) = mo_meta_data_handler->has_valid_pseudo_comment( is_statement    = is_statement
                                                                       iv_finding_code = iv_finding_code ).

    DATA(ls_params) = VALUE if_ci_atc_check=>ty_message_parameters( param_1 = iv_param_1
                                                                    param_2 = iv_param_2
                                                                    param_3 = iv_param_3
                                                                    param_4 = iv_param_4 ).

    INSERT VALUE #( code               = iv_finding_code
                    location           = ls_location
                    parameters         = ls_params
                    checksum           = lv_checksum
                    has_pseudo_comment = lv_has_pc
                    details            = io_details ) INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD report_token.
    DATA(ls_location) = mo_code_provider->get_statement_location( is_statement ).
    ls_location-position-line   = is_token-position-line.
    ls_location-position-column = is_token-position-column.

    DATA(lv_checksum) = mo_code_provider->get_statement_checksum( is_statement ).
    DATA(lv_has_pc) = mo_meta_data_handler->has_valid_pseudo_comment( is_statement    = is_statement
                                                                       iv_finding_code = iv_finding_code ).

    DATA(ls_params) = VALUE if_ci_atc_check=>ty_message_parameters( param_1 = iv_param_1
                                                                    param_2 = iv_param_2
                                                                    param_3 = iv_param_3
                                                                    param_4 = iv_param_4 ).

    INSERT VALUE #( code               = iv_finding_code
                    location           = ls_location
                    parameters         = ls_params
                    checksum           = lv_checksum
                    has_pseudo_comment = lv_has_pc
                    details            = io_details ) INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD create_quickfix_replace.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lv_st_to) = COND i( WHEN iv_statement_to IS NOT INITIAL THEN iv_statement_to ELSE iv_statement_from ).

    DATA(ls_context_params) = VALUE cl_ci_atc_quickfix_context=>ty_context_descriptor(
                                        procedure_id = is_procedure_id
                                        statements   = VALUE #( from = iv_statement_from
                                                                to   = lv_st_to ) ).

    IF iv_token_from IS NOT INITIAL.
      DATA(lv_tk_to) = COND i( WHEN iv_token_to IS NOT INITIAL THEN iv_token_to ELSE iv_token_from ).
      ls_context_params-tokens = VALUE #( from = iv_token_from to = lv_tk_to ).
    ENDIF.

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context( ls_context_params ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->replace( context = lo_context
                                                                 code    = it_new_code ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD create_quickfix_insert_before.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context(
                           VALUE #( procedure_id = is_procedure_id
                                    statements   = VALUE #( from = iv_statement_index
                                                            to   = iv_statement_index ) ) ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->insert_before( context = lo_context
                                                                       code    = it_new_code ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD create_quickfix_insert_after.
    DATA(lo_quickfixes) = mo_assistant_factory->create_quickfixes( ).

    DATA(lo_context) = mo_assistant_factory->create_quickfix_context(
                           VALUE #( procedure_id = is_procedure_id
                                    statements   = VALUE #( from = iv_statement_index
                                                            to   = iv_statement_index ) ) ).

    lo_quickfixes->create_quickfix( iv_quickfix_code )->insert_after( context = lo_context
                                                                      code    = it_new_code ).

    DATA(lo_details) = mo_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.
ENDCLASS.
