INTERFACE zif_skylint_token_navigator PUBLIC.


  METHODS is_keyword
    IMPORTING iv_token      TYPE if_ci_atc_source_code_provider=>ty_token
              iv_keyword    TYPE string
    RETURNING VALUE(rv_yes) TYPE abap_bool.


  METHODS bracket_type
    IMPORTING iv_token       TYPE if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(rv_type) TYPE zif_skylint_types=>ty_bracket_type.


  METHODS find_token
    IMPORTING it_tokens       TYPE if_ci_atc_source_code_provider=>ty_tokens
              iv_lexeme       TYPE string
              iv_from         TYPE REF TO if_ci_atc_source_code_provider=>ty_token OPTIONAL
    RETURNING VALUE(ro_token) TYPE REF TO if_ci_atc_source_code_provider=>ty_token.


  METHODS find_clause
    IMPORTING it_tokens       TYPE if_ci_atc_source_code_provider=>ty_tokens
              iv_clause       TYPE string
              iv_from         TYPE REF TO if_ci_atc_source_code_provider=>ty_token OPTIONAL
    RETURNING VALUE(ro_token) TYPE REF TO if_ci_atc_source_code_provider=>ty_token.


  METHODS has_clause
    IMPORTING it_tokens     TYPE if_ci_atc_source_code_provider=>ty_tokens
              iv_clause     TYPE string
    RETURNING VALUE(rv_yes) TYPE abap_bool.


  METHODS has_keyword_sequence
    IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
              it_keywords   TYPE string_table
    RETURNING VALUE(rv_yes) TYPE abap_bool.


  METHODS find_closing_bracket
    IMPORTING is_statement          TYPE if_ci_atc_source_code_provider=>ty_statement
              io_open_token         TYPE REF TO if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(ro_close_token) TYPE REF TO if_ci_atc_source_code_provider=>ty_token
    RAISING   zcx_skylint_error.

ENDINTERFACE.
