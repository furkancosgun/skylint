INTERFACE zif_skylint_quickfix PUBLIC.

  TYPES ty_quickfix_code TYPE c LENGTH 10.

  METHODS replace
    IMPORTING iv_quickfix_code  TYPE ty_quickfix_code
              is_procedure_id   TYPE if_ci_atc_source_code_provider=>ty_procedure_id
              iv_statement_from TYPE i
              iv_statement_to   TYPE i OPTIONAL
              iv_token_from     TYPE i OPTIONAL
              iv_token_to       TYPE i OPTIONAL
              it_new_code       TYPE if_ci_atc_quickfix=>ty_code
    RETURNING VALUE(ro_details) TYPE if_ci_atc_check=>ty_details.

  METHODS insert_before
    IMPORTING iv_quickfix_code   TYPE ty_quickfix_code
              is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
              iv_statement_index TYPE i
              it_new_code        TYPE if_ci_atc_quickfix=>ty_code
    RETURNING VALUE(ro_details)  TYPE if_ci_atc_check=>ty_details.

  METHODS insert_after
    IMPORTING iv_quickfix_code   TYPE ty_quickfix_code
              is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
              iv_statement_index TYPE i
              it_new_code        TYPE if_ci_atc_quickfix=>ty_code
    RETURNING VALUE(ro_details)  TYPE if_ci_atc_check=>ty_details.

  METHODS delete_statement
    IMPORTING iv_quickfix_code   TYPE ty_quickfix_code
              is_procedure_id    TYPE if_ci_atc_source_code_provider=>ty_procedure_id
              iv_statement_index TYPE i
    RETURNING VALUE(ro_details)  TYPE if_ci_atc_check=>ty_details.

ENDINTERFACE.
