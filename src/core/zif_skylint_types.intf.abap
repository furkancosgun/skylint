INTERFACE zif_skylint_types
  PUBLIC.

  TYPES ty_object_type   TYPE c LENGTH 4.
  TYPES ty_object_name   TYPE c LENGTH 40.
  TYPES ty_keyword       TYPE string.
  TYPES ty_lexeme        TYPE string.
  TYPES ty_full_name     TYPE string.
  TYPES ty_finding_code  TYPE c LENGTH 10.
  TYPES ty_severity      TYPE c LENGTH 1.
  TYPES ty_quickfix_code TYPE c LENGTH 10.

  TYPES:
    BEGIN OF ty_position,
      line   TYPE i,
      column TYPE i,
    END OF ty_position.

  TYPES:
    BEGIN OF ty_test_expected,
      method TYPE string,
      code   TYPE ty_finding_code,
      line   TYPE i,
      column TYPE i,
    END OF ty_test_expected,
    ty_test_expecteds TYPE STANDARD TABLE OF ty_test_expected WITH EMPTY KEY.

  CONSTANTS:
    BEGIN OF object_types,
      class          TYPE ty_object_type VALUE 'CLAS',
      program        TYPE ty_object_type VALUE 'PROG',
      function_group TYPE ty_object_type VALUE 'FUGR',
      interface      TYPE ty_object_type VALUE 'INTF',
    END OF object_types.

  TYPES ty_block_kind TYPE ty_object_type.

  CONSTANTS:
    BEGIN OF block_kinds,
      method           TYPE ty_block_kind VALUE 'METH',
      class_definition TYPE ty_block_kind VALUE 'DECL',
      form_routine     TYPE ty_block_kind VALUE 'FORM',
      function         TYPE ty_block_kind VALUE 'FUNC',
    END OF block_kinds.

  TYPES ty_reference_kind TYPE c LENGTH 2.
  TYPES ty_usage_mode     TYPE c LENGTH 1.
  TYPES ty_usage_grade    TYPE c LENGTH 1.

  CONSTANTS:
    BEGIN OF compiler_reference_kinds,
      data   TYPE ty_reference_kind VALUE 'DA',
      method TYPE ty_reference_kind VALUE 'ME',
      type   TYPE ty_reference_kind VALUE 'TY',
    END OF compiler_reference_kinds.

  CONSTANTS:
    BEGIN OF usage_modes,
      definition             TYPE ty_usage_mode VALUE '2',
      definition_with_write  TYPE ty_usage_mode VALUE '3',
      definition_with_assign TYPE ty_usage_mode VALUE '4',
      read                   TYPE ty_usage_mode VALUE '5',
      write                  TYPE ty_usage_mode VALUE '6',
      read_and_write         TYPE ty_usage_mode VALUE '7',
      read_database          TYPE ty_usage_mode VALUE 'E',
      write_database         TYPE ty_usage_mode VALUE 'F',
      redefinition           TYPE ty_usage_mode VALUE 'R',
    END OF usage_modes.

  CONSTANTS:
    BEGIN OF usage_grades,
      definition TYPE ty_usage_grade VALUE '0',
      direct     TYPE ty_usage_grade VALUE '1',
      component  TYPE ty_usage_grade VALUE '2',
      indirect   TYPE ty_usage_grade VALUE '3',
    END OF usage_grades.

  TYPES:
    BEGIN OF ty_compiler_reference,
      full_name   TYPE ty_full_name,
      kind        TYPE ty_reference_kind,
      usage_grade TYPE ty_usage_grade,
      usage_mode  TYPE ty_usage_mode,
    END OF ty_compiler_reference,
    ty_compiler_references TYPE STANDARD TABLE OF ty_compiler_reference WITH EMPTY KEY.

  TYPES ty_token_type TYPE c LENGTH 1.

  CONSTANTS:
    BEGIN OF token_types,
      identifier TYPE ty_token_type VALUE 'I',
      literal    TYPE ty_token_type VALUE 'S',
      comment    TYPE ty_token_type VALUE 'C',
      pragma     TYPE ty_token_type VALUE 'P',
    END OF token_types.

  TYPES:
    BEGIN OF ty_token,
      lexeme     TYPE ty_lexeme,
      type       TYPE ty_token_type,
      position   TYPE ty_position,
      references TYPE ty_compiler_references,
    END OF ty_token,
    ty_tokens TYPE STANDARD TABLE OF ty_token WITH EMPTY KEY.

  TYPES ty_pseudo_comments TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

  TYPES:
    BEGIN OF ty_statement,
      index           TYPE i,
      keyword         TYPE ty_keyword,
      tokens          TYPE ty_tokens,
      position        TYPE ty_position,
      pseudo_comments TYPE ty_pseudo_comments,
    END OF ty_statement,
    ty_statements TYPE STANDARD TABLE OF ty_statement WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_code_block,
      object_name TYPE ty_object_name,
      object_type TYPE ty_object_type,
      block_kind  TYPE ty_block_kind,
      block_name  TYPE string,
      statements  TYPE ty_statements,
    END OF ty_code_block.

  CONSTANTS:
    BEGIN OF severities,
      error   TYPE ty_severity VALUE 'E',
      warning TYPE ty_severity VALUE 'W',
      note    TYPE ty_severity VALUE 'N',
    END OF severities.

  TYPES ty_code_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_quickfix,
      code           TYPE ty_quickfix_code,
      statement_from TYPE i,
      statement_to   TYPE i,
      token_from     TYPE i,
      token_to       TYPE i,
      new_code       TYPE ty_code_lines,
    END OF ty_quickfix,
    ty_quickfixes TYPE STANDARD TABLE OF ty_quickfix WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_finding,
      code            TYPE ty_finding_code,
      severity        TYPE ty_severity,
      message         TYPE string,
      position        TYPE ty_position,
      statement_index TYPE i,
      quickfixes      TYPE ty_quickfixes,
    END OF ty_finding,
    ty_findings TYPE STANDARD TABLE OF ty_finding WITH EMPTY KEY.

  CONSTANTS:
    BEGIN OF attribute_kinds,
      boolean TYPE string VALUE 'BOOLEAN',
      string  TYPE string VALUE 'STRING',
      integer TYPE string VALUE 'INTEGER',
    END OF attribute_kinds.

  TYPES:
    BEGIN OF ty_finding_code_config,
      code           TYPE ty_finding_code,
      severity       TYPE ty_severity,
      text           TYPE string,
      pseudo_comment TYPE string,
    END OF ty_finding_code_config,
    ty_finding_codes_config TYPE HASHED TABLE OF ty_finding_code_config WITH UNIQUE KEY code.

  TYPES:
    BEGIN OF ty_attribute,
      name  TYPE string,
      kind  TYPE string,
      text  TYPE string,
      value TYPE REF TO data,
    END OF ty_attribute,
    ty_attributes TYPE STANDARD TABLE OF ty_attribute WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_quickfix_code_info,
      code       TYPE ty_quickfix_code,
      short_text TYPE string,
    END OF ty_quickfix_code_info,
    ty_quickfix_code_infos TYPE STANDARD TABLE OF ty_quickfix_code_info WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_config,
      description       TYPE string,
      remote_enablement TYPE abap_bool,
      finding_codes     TYPE ty_finding_codes_config,
      quickfix_codes    TYPE ty_quickfix_code_infos,
      attributes        TYPE ty_attributes,
    END OF ty_config.

ENDINTERFACE.
