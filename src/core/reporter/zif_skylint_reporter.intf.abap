INTERFACE zif_skylint_reporter PUBLIC.

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

  METHODS get_findings
    RETURNING VALUE(rt_findings) TYPE if_ci_atc_check=>ty_findings.

  METHODS clear.

ENDINTERFACE.
