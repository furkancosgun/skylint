INTERFACE zif_skylint_types
  PUBLIC.

  TYPES:
    ty_object_type   TYPE c LENGTH 4,
    ty_object_name   TYPE c LENGTH 40,
    ty_keyword       TYPE string,
    ty_lexeme        TYPE string,
    ty_full_name     TYPE string,
    ty_finding_code  TYPE c LENGTH 10,
    ty_severity      TYPE c LENGTH 1,
    ty_quickfix_code TYPE c LENGTH 10.

  TYPES:
    BEGIN OF ty_position,
      line   TYPE i,
      column TYPE i,
    END OF ty_position.

  TYPES ty_compilation_unit_kind TYPE ty_object_type.

  CONSTANTS:
    BEGIN OF compilation_unit_kinds,
      class          TYPE ty_compilation_unit_kind VALUE 'CLAS',
      report         TYPE ty_compilation_unit_kind VALUE 'PROG',
      function_group TYPE ty_compilation_unit_kind VALUE 'FUGR',
      interface      TYPE ty_compilation_unit_kind VALUE 'INTF',
    END OF compilation_unit_kinds.

  TYPES:
    BEGIN OF ty_compilation_unit,
      kind TYPE ty_compilation_unit_kind,
      name TYPE ty_object_name,
    END OF ty_compilation_unit.

  TYPES ty_procedure_kind TYPE ty_object_type.

  CONSTANTS:
    BEGIN OF procedure_kinds,
      method           TYPE ty_procedure_kind VALUE 'METH',
      class_definition TYPE ty_procedure_kind VALUE 'DECL',
      form_routine     TYPE ty_procedure_kind VALUE 'FORM',
      function         TYPE ty_procedure_kind VALUE 'FUNC',
    END OF procedure_kinds.

  TYPES:
    BEGIN OF ty_procedure_id,
      kind      TYPE ty_procedure_kind,
      name      TYPE string,
      main_unit TYPE ty_compilation_unit,
    END OF ty_procedure_id.

  TYPES:
    ty_reference_kind TYPE c LENGTH 2,
    ty_usage_mode     TYPE c LENGTH 1,
    ty_usage_grade    TYPE c LENGTH 1.

  CONSTANTS:
    BEGIN OF compiler_reference_kinds,
      data      TYPE ty_reference_kind VALUE 'DA',
      method    TYPE ty_reference_kind VALUE 'ME',
      type      TYPE ty_reference_kind VALUE 'TY',
      form      TYPE ty_reference_kind VALUE 'FO',
      function  TYPE ty_reference_kind VALUE 'FU',
      interface TYPE ty_reference_kind VALUE 'IN',
      table_key TYPE ty_reference_kind VALUE 'TK',
      message   TYPE ty_reference_kind VALUE 'MG',
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

  TYPES ty_statement_type TYPE c LENGTH 1.

  CONSTANTS:
    BEGIN OF statement_types,
      standard      TYPE ty_statement_type VALUE 'K',
      compute       TYPE ty_statement_type VALUE 'C',
      method_direct TYPE ty_statement_type VALUE 'A',
      comment       TYPE ty_statement_type VALUE 'P',
      pragma        TYPE ty_statement_type VALUE 'G',
    END OF statement_types.

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
      keyword         TYPE ty_keyword,
      type            TYPE ty_statement_type,
      tokens          TYPE ty_tokens,
      position        TYPE ty_position,
      pseudo_comments TYPE ty_pseudo_comments,
      include         TYPE ty_object_name,
      level           TYPE i,
      index           TYPE i,
      is_in_scope     TYPE abap_bool,
    END OF ty_statement,
    ty_statements TYPE STANDARD TABLE OF ty_statement WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY keyword COMPONENTS keyword.

  TYPES:
    BEGIN OF ty_procedure,
      id         TYPE ty_procedure_id,
      statements TYPE ty_statements,
    END OF ty_procedure.

  CONSTANTS:
    BEGIN OF severities,
      error   TYPE ty_severity VALUE 'E',
      warning TYPE ty_severity VALUE 'W',
      info    TYPE ty_severity VALUE 'I',
    END OF severities.

  TYPES ty_quickfix_kind TYPE c LENGTH 1.

  CONSTANTS:
    BEGIN OF quickfix_kinds,
      replace       TYPE ty_quickfix_kind VALUE 'R',
      insert_before TYPE ty_quickfix_kind VALUE 'B',
      insert_after  TYPE ty_quickfix_kind VALUE 'A',
      delete        TYPE ty_quickfix_kind VALUE 'D',
    END OF quickfix_kinds.

  TYPES ty_code_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_quickfix,
      code           TYPE ty_quickfix_code,
      kind           TYPE ty_quickfix_kind,
      statement_from TYPE i,
      statement_to   TYPE i,
      token_from     TYPE i,
      token_to       TYPE i,
      new_code       TYPE ty_code_lines,
    END OF ty_quickfix,
    ty_quickfixes TYPE STANDARD TABLE OF ty_quickfix WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_finding,
      code       TYPE ty_finding_code,
      severity   TYPE ty_severity,
      message    TYPE string,
      position   TYPE ty_position,
      quickfixes TYPE ty_quickfixes,
    END OF ty_finding,
    ty_findings TYPE STANDARD TABLE OF ty_finding WITH EMPTY KEY.

  CONSTANTS:
    BEGIN OF attribute_kinds,
      boolean    TYPE string VALUE 'BOOLEAN',
      string     TYPE string VALUE 'STRING',
      integer    TYPE string VALUE 'INTEGER',
      elementary TYPE string VALUE 'ELEMENTARY',
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
