CLASS zcl_skylint_reporter DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_reporter.

    METHODS constructor
      IMPORTING io_code_provider TYPE REF TO if_ci_atc_source_code_provider
                io_meta_data     TYPE REF TO zcl_skylint_check_meta_data.

  PRIVATE SECTION.
    DATA mo_code_provider TYPE REF TO if_ci_atc_source_code_provider.
    DATA mo_meta_data     TYPE REF TO zcl_skylint_check_meta_data.
    DATA mt_findings      TYPE if_ci_atc_check=>ty_findings.
ENDCLASS.


CLASS zcl_skylint_reporter IMPLEMENTATION.
  METHOD constructor.
    mo_code_provider = io_code_provider.
    mo_meta_data     = io_meta_data.
  ENDMETHOD.

  METHOD zif_skylint_reporter~report_statement.
    DATA(ls_location) = mo_code_provider->get_statement_location( is_statement ).
    DATA(lv_checksum) = mo_code_provider->get_statement_checksum( is_statement ).
    DATA(lv_has_pc) = mo_meta_data->has_valid_pseudo_comment( is_statement    = is_statement
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

  METHOD zif_skylint_reporter~report_token.
    DATA(ls_location) = mo_code_provider->get_statement_location( is_statement ).
    ls_location-position-line   = is_token-position-line.
    ls_location-position-column = is_token-position-column.

    DATA(lv_checksum) = mo_code_provider->get_statement_checksum( is_statement ).
    DATA(lv_has_pc) = mo_meta_data->has_valid_pseudo_comment( is_statement    = is_statement
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

  METHOD zif_skylint_reporter~report_finding.
    INSERT is_finding INTO TABLE mt_findings.
  ENDMETHOD.

  METHOD zif_skylint_reporter~get_findings.
    rt_findings = mt_findings.
  ENDMETHOD.

  METHOD zif_skylint_reporter~clear.
    CLEAR mt_findings.
  ENDMETHOD.
ENDCLASS.
