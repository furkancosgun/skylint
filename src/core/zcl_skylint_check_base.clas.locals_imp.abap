CLASS lcl_reporter DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS create_statement_finding
      IMPORTING io_code_provider  TYPE REF TO if_ci_atc_source_code_provider
                io_meta_data      TYPE REF TO zcl_skylint_check_meta_data
                is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code   TYPE if_ci_atc_check=>ty_finding_code
                iv_param_1        TYPE string                      OPTIONAL
                iv_param_2        TYPE string                      OPTIONAL
                iv_param_3        TYPE string                      OPTIONAL
                iv_param_4        TYPE string                      OPTIONAL
                io_details        TYPE if_ci_atc_check=>ty_details OPTIONAL
      RETURNING VALUE(rs_finding) TYPE if_ci_atc_check=>ty_finding.

    CLASS-METHODS create_token_finding
      IMPORTING io_code_provider  TYPE REF TO if_ci_atc_source_code_provider
                io_meta_data      TYPE REF TO zcl_skylint_check_meta_data
                is_token          TYPE if_ci_atc_source_code_provider=>ty_token
                is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_finding_code   TYPE if_ci_atc_check=>ty_finding_code
                iv_param_1        TYPE string                      OPTIONAL
                iv_param_2        TYPE string                      OPTIONAL
                iv_param_3        TYPE string                      OPTIONAL
                iv_param_4        TYPE string                      OPTIONAL
                io_details        TYPE if_ci_atc_check=>ty_details OPTIONAL
      RETURNING VALUE(rs_finding) TYPE if_ci_atc_check=>ty_finding.
ENDCLASS.


CLASS lcl_reporter IMPLEMENTATION.
  METHOD create_statement_finding.
    DATA ls_location TYPE if_ci_atc_check=>ty_location.
    DATA lv_checksum TYPE if_ci_atc_check=>ty_checksum.
    DATA lv_has_pc   TYPE abap_bool.
    DATA ls_params   TYPE if_ci_atc_check=>ty_message_parameters.

    IF io_code_provider IS INITIAL OR io_meta_data IS INITIAL.
      RETURN.
    ENDIF.

    ls_location = io_code_provider->get_statement_location( is_statement ).
    lv_checksum = io_code_provider->get_statement_checksum( is_statement ).
    lv_has_pc   = io_meta_data->has_valid_pseudo_comment( is_statement    = is_statement
                                                          iv_finding_code = iv_finding_code ).

    ls_params-param_1 = iv_param_1.
    ls_params-param_2 = iv_param_2.
    ls_params-param_3 = iv_param_3.
    ls_params-param_4 = iv_param_4.

    rs_finding-code               = iv_finding_code.
    rs_finding-location           = ls_location.
    rs_finding-parameters         = ls_params.
    rs_finding-checksum           = lv_checksum.
    rs_finding-has_pseudo_comment = lv_has_pc.
    rs_finding-details            = io_details.
  ENDMETHOD.

  METHOD create_token_finding.
    DATA ls_location TYPE if_ci_atc_check=>ty_location.
    DATA lv_checksum TYPE if_ci_atc_check=>ty_checksum.
    DATA lv_has_pc   TYPE abap_bool.
    DATA ls_params   TYPE if_ci_atc_check=>ty_message_parameters.

    IF io_code_provider IS INITIAL OR io_meta_data IS INITIAL.
      RETURN.
    ENDIF.

    ls_location                 = io_code_provider->get_statement_location( is_statement ).
    ls_location-position-line   = is_token-position-line.
    ls_location-position-column = is_token-position-column.

    lv_checksum = io_code_provider->get_statement_checksum( is_statement ).
    lv_has_pc   = io_meta_data->has_valid_pseudo_comment( is_statement    = is_statement
                                                          iv_finding_code = iv_finding_code ).

    ls_params-param_1 = iv_param_1.
    ls_params-param_2 = iv_param_2.
    ls_params-param_3 = iv_param_3.
    ls_params-param_4 = iv_param_4.

    rs_finding-code               = iv_finding_code.
    rs_finding-location           = ls_location.
    rs_finding-parameters         = ls_params.
    rs_finding-checksum           = lv_checksum.
    rs_finding-has_pseudo_comment = lv_has_pc.
    rs_finding-details            = io_details.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_quickfix DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS replace_code
      IMPORTING io_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory
                iv_quickfix_code     TYPE zcl_skylint_check_base=>ty_quickfix_code
                is_procedure_id      TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_from    TYPE i
                iv_statement_to      TYPE i OPTIONAL
                iv_token_from        TYPE i OPTIONAL
                iv_token_to          TYPE i OPTIONAL
                it_new_code          TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)    TYPE if_ci_atc_check=>ty_details.

    CLASS-METHODS insert_before
      IMPORTING io_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory
                iv_quickfix_code     TYPE zcl_skylint_check_base=>ty_quickfix_code
                is_procedure_id      TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index   TYPE i
                it_new_code          TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)    TYPE if_ci_atc_check=>ty_details.

    CLASS-METHODS insert_after
      IMPORTING io_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory
                iv_quickfix_code     TYPE zcl_skylint_check_base=>ty_quickfix_code
                is_procedure_id      TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index   TYPE i
                it_new_code          TYPE if_ci_atc_quickfix=>ty_code
      RETURNING VALUE(ro_details)    TYPE if_ci_atc_check=>ty_details.

    CLASS-METHODS delete
      IMPORTING io_assistant_factory TYPE REF TO cl_ci_atc_assistant_factory
                iv_quickfix_code     TYPE zcl_skylint_check_base=>ty_quickfix_code
                is_procedure_id      TYPE if_ci_atc_source_code_provider=>ty_procedure_id
                iv_statement_index   TYPE i
      RETURNING VALUE(ro_details)    TYPE if_ci_atc_check=>ty_details.
ENDCLASS.


CLASS lcl_quickfix IMPLEMENTATION.
  METHOD replace_code.
    DATA lo_quickfixes     TYPE REF TO cl_ci_atc_quickfixes.
    DATA lo_context        TYPE REF TO cl_ci_atc_quickfix_context.
    DATA lo_details        TYPE REF TO cl_ci_atc_finding_details.
    DATA ls_context_params TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor.
    DATA lv_st_to          TYPE i.
    DATA lv_tk_to          TYPE i.

    IF io_assistant_factory IS INITIAL.
      RETURN.
    ENDIF.

    lv_st_to = iv_statement_to.
    IF lv_st_to IS INITIAL.
      lv_st_to = iv_statement_from.
    ENDIF.

    ls_context_params-procedure_id = is_procedure_id.
    ls_context_params-statements-from = iv_statement_from.
    ls_context_params-statements-to   = lv_st_to.

    IF iv_token_from IS NOT INITIAL.
      lv_tk_to = iv_token_to.
      IF lv_tk_to IS INITIAL.
        lv_tk_to = iv_token_from.
      ENDIF.
      ls_context_params-tokens-from = iv_token_from.
      ls_context_params-tokens-to   = lv_tk_to.
    ENDIF.

    lo_quickfixes = io_assistant_factory->create_quickfixes( ).
    IF lo_quickfixes IS INITIAL.
      RETURN.
    ENDIF.
    lo_context    = io_assistant_factory->create_quickfix_context( ls_context_params ).
    lo_quickfixes->create_quickfix( iv_quickfix_code )->replace( context = lo_context
                                                                 code    = it_new_code ).

    lo_details = io_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD insert_before.
    DATA lo_quickfixes     TYPE REF TO cl_ci_atc_quickfixes.
    DATA lo_context        TYPE REF TO cl_ci_atc_quickfix_context.
    DATA lo_details        TYPE REF TO cl_ci_atc_finding_details.
    DATA ls_context_params TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor.

    IF io_assistant_factory IS INITIAL.
      RETURN.
    ENDIF.

    ls_context_params-procedure_id = is_procedure_id.
    ls_context_params-statements-from = iv_statement_index.
    ls_context_params-statements-to   = iv_statement_index.

    lo_quickfixes = io_assistant_factory->create_quickfixes( ).
    lo_context    = io_assistant_factory->create_quickfix_context( ls_context_params ).
    lo_quickfixes->create_quickfix( iv_quickfix_code )->insert_before( context = lo_context
                                                                       code    = it_new_code ).

    lo_details = io_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD insert_after.
    DATA lo_quickfixes     TYPE REF TO cl_ci_atc_quickfixes.
    DATA lo_context        TYPE REF TO cl_ci_atc_quickfix_context.
    DATA lo_details        TYPE REF TO cl_ci_atc_finding_details.
    DATA ls_context_params TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor.

    IF io_assistant_factory IS INITIAL.
      RETURN.
    ENDIF.

    ls_context_params-procedure_id = is_procedure_id.
    ls_context_params-statements-from = iv_statement_index.
    ls_context_params-statements-to   = iv_statement_index.

    lo_quickfixes = io_assistant_factory->create_quickfixes( ).
    lo_context    = io_assistant_factory->create_quickfix_context( ls_context_params ).
    lo_quickfixes->create_quickfix( iv_quickfix_code )->insert_after( context = lo_context
                                                                      code    = it_new_code ).

    lo_details = io_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.

  METHOD delete.
    DATA lo_quickfixes     TYPE REF TO cl_ci_atc_quickfixes.
    DATA lo_context        TYPE REF TO cl_ci_atc_quickfix_context.
    DATA lo_details        TYPE REF TO cl_ci_atc_finding_details.
    DATA ls_context_params TYPE cl_ci_atc_quickfix_context=>ty_context_descriptor.
    DATA lt_empty_code     TYPE if_ci_atc_quickfix=>ty_code.

    IF io_assistant_factory IS INITIAL.
      RETURN.
    ENDIF.

    ls_context_params-procedure_id = is_procedure_id.
    ls_context_params-statements-from = iv_statement_index.
    ls_context_params-statements-to   = iv_statement_index.

    lo_quickfixes = io_assistant_factory->create_quickfixes( ).
    lo_context    = io_assistant_factory->create_quickfix_context( ls_context_params ).
    lo_quickfixes->create_quickfix( iv_quickfix_code )->replace( context = lo_context
                                                                 code    = lt_empty_code ).

    lo_details = io_assistant_factory->create_finding_details( ).
    ro_details = lo_details->attach_quickfixes( lo_quickfixes ).
  ENDMETHOD.
ENDCLASS.
