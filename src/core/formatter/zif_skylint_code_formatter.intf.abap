INTERFACE zif_skylint_code_formatter PUBLIC.


  METHODS flatten
    IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
    RETURNING VALUE(rv_code) TYPE string.


  METHODS break_lines
    IMPORTING iv_code         TYPE string
              iv_max_length   TYPE i DEFAULT zif_skylint_types=>c_max_line_length
    RETURNING VALUE(rt_lines) TYPE if_ci_atc_quickfix=>ty_code
    RAISING   zcx_skylint_error.


  METHODS format
    IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
    RETURNING VALUE(rt_code) TYPE if_ci_atc_quickfix=>ty_code
    RAISING   zcx_skylint_error.

ENDINTERFACE.
