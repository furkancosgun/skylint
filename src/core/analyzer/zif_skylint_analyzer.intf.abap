INTERFACE zif_skylint_analyzer PUBLIC.

  CONSTANTS c_max_line_length TYPE i VALUE 255.

  TYPES:
    BEGIN OF ENUM ty_bracket_type STRUCTURE bracket_type,
      none,
      opening,
      closing,
      clopening,
    END OF ENUM ty_bracket_type STRUCTURE bracket_type.

  TYPES:
    BEGIN OF ENUM ty_connective STRUCTURE connective,
      none,
      and,
      or,
      equiv,
      not,
    END OF ENUM ty_connective STRUCTURE connective.

  METHODS is_keyword
    IMPORTING iv_token      TYPE if_ci_atc_source_code_provider=>ty_token
              iv_keyword    TYPE string
    RETURNING VALUE(rv_yes) TYPE abap_bool.

  METHODS bracket_type
    IMPORTING iv_token       TYPE if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(rv_type) TYPE ty_bracket_type.

  METHODS is_comparison_operator
    IMPORTING iv_token      TYPE if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(rv_yes) TYPE abap_bool.

  METHODS is_logical_connective
    IMPORTING iv_token       TYPE if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(rv_type) TYPE ty_connective.

  METHODS find_token
    IMPORTING it_tokens       TYPE if_ci_atc_source_code_provider=>ty_tokens
              iv_lexeme       TYPE string
              iv_start        TYPE i DEFAULT 1
    RETURNING VALUE(rv_index) TYPE i.

  METHODS find_clause
    IMPORTING it_tokens       TYPE if_ci_atc_source_code_provider=>ty_tokens
              iv_clause       TYPE string
              iv_start        TYPE i DEFAULT 1
    RETURNING VALUE(rv_index) TYPE i.

  METHODS has_clause
    IMPORTING it_tokens     TYPE if_ci_atc_source_code_provider=>ty_tokens
              iv_clause     TYPE string
    RETURNING VALUE(rv_yes) TYPE abap_bool.

  METHODS find_keyword_sequence
    IMPORTING it_keywords   TYPE string_table
              is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
    RETURNING VALUE(rv_pos) TYPE i.

  METHODS find_closing_bracket
    IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
              iv_open_pos   TYPE i
    RETURNING VALUE(rv_end) TYPE i
    RAISING   cx_static_check.

  METHODS flatten
    IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
    RETURNING VALUE(rv_code) TYPE string.

  METHODS break_lines
    IMPORTING iv_code         TYPE string
              iv_max_length   TYPE i DEFAULT c_max_line_length
    RETURNING VALUE(rt_lines) TYPE if_ci_atc_quickfix=>ty_code
    RAISING   cx_static_check.

  METHODS format
    IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
    RETURNING VALUE(rt_code) TYPE if_ci_atc_quickfix=>ty_code
    RAISING   cx_static_check.

  METHODS negate_operator
    IMPORTING iv_operator       TYPE string
    RETURNING VALUE(rv_negated) TYPE string
    RAISING   cx_static_check.

ENDINTERFACE.
