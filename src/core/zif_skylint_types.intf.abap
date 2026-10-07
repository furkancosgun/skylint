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

  CONSTANTS:
    BEGIN OF object_types,
      class          TYPE ty_object_type VALUE 'CLAS',
      program        TYPE ty_object_type VALUE 'PROG',
      function_group TYPE ty_object_type VALUE 'FUGR',
      interface      TYPE ty_object_type VALUE 'INTF',
      type_pool      TYPE ty_object_type VALUE 'TYPE',
    END OF object_types.

  TYPES ty_block_kind TYPE ty_object_type.

  CONSTANTS:
    BEGIN OF block_kinds,
      method              TYPE ty_block_kind VALUE 'METH',
      class_definition    TYPE ty_block_kind VALUE 'DECL',
      form_routine        TYPE ty_block_kind VALUE 'FORM',
      function            TYPE ty_block_kind VALUE 'FUNC',
      at_user_command     TYPE ty_block_kind VALUE 'ATUC',
      at_line_selection   TYPE ty_block_kind VALUE 'LISE',
      at_pf_status        TYPE ty_block_kind VALUE 'ATPF',
      at_selection_screen TYPE ty_block_kind VALUE 'ATSS',
      module_in           TYPE ty_block_kind VALUE 'MODI',
      module_out          TYPE ty_block_kind VALUE 'MODO',
      start_of_selection  TYPE ty_block_kind VALUE 'SSEL',
      end_of_selection    TYPE ty_block_kind VALUE 'ESEL',
      top_of_page         TYPE ty_block_kind VALUE 'TOPA',
      top_of_page_during  TYPE ty_block_kind VALUE 'TOPS',
      end_of_page         TYPE ty_block_kind VALUE 'ENPA',
      load_of_program     TYPE ty_block_kind VALUE 'LDPR',
      initialization      TYPE ty_block_kind VALUE 'INIT',
      get_event           TYPE ty_block_kind VALUE 'GET ',
      get_late            TYPE ty_block_kind VALUE 'GETL',
      overflow            TYPE ty_block_kind VALUE '%%%%',
      unknown             TYPE ty_block_kind VALUE '!!!!',
    END OF block_kinds.

  TYPES ty_reference_kind TYPE c LENGTH 2.
  TYPES ty_usage_mode     TYPE c LENGTH 1.
  TYPES ty_usage_grade    TYPE c LENGTH 1.

  CONSTANTS:
    BEGIN OF compiler_reference_kinds,
      data TYPE ty_reference_kind VALUE 'DA',
      method TYPE ty_reference_kind VALUE 'ME',
      type TYPE ty_reference_kind VALUE 'TY',
      association TYPE ty_reference_kind VALUE 'AC',
      authority_object TYPE ty_reference_kind VALUE 'AO',
      authorization_context TYPE ty_reference_kind VALUE 'AT',
      common_part TYPE ty_reference_kind VALUE 'CP',
      event TYPE ty_reference_kind VALUE 'EV',
      form TYPE ty_reference_kind VALUE 'FO',
      function TYPE ty_reference_kind VALUE 'FU',
      function_pool TYPE ty_reference_kind VALUE 'FP',
      database_function TYPE ty_reference_kind VALUE 'DF',
      include TYPE ty_reference_kind VALUE 'IC',
      macro TYPE ty_reference_kind VALUE 'MA',
      macro_trmac TYPE ty_reference_kind VALUE 'RM',
      matchcode TYPE ty_reference_kind VALUE 'MC',
      message TYPE ty_reference_kind VALUE 'MG',
      message_id TYPE ty_reference_kind VALUE 'MI',
      message_number TYPE ty_reference_kind VALUE 'MN',
      message_type TYPE ty_reference_kind VALUE 'MT',
      program TYPE ty_reference_kind VALUE 'PR',
      reference TYPE ty_reference_kind VALUE 'RE',
      shared_data TYPE ty_reference_kind VALUE 'SD',
      shared_type TYPE ty_reference_kind VALUE 'ST',
      table_key TYPE ty_reference_kind VALUE 'TK',
      text_element TYPE ty_reference_kind VALUE 'TE',
      transaction TYPE ty_reference_kind VALUE 'TA',
      transformation TYPE ty_reference_kind VALUE 'TR',
      test_seam TYPE ty_reference_kind VALUE 'TS',
      type_of TYPE ty_reference_kind VALUE 'TO',
      type_of_type TYPE ty_reference_kind VALUE 'TT',
      type_pool TYPE ty_reference_kind VALUE 'TP',
      value TYPE ty_reference_kind VALUE 'VA',
      schema TYPE ty_reference_kind VALUE 'SH',
      bdl_group TYPE ty_reference_kind VALUE 'EG',
      bdl_operation TYPE ty_reference_kind VALUE 'OP',
      bdl_action TYPE ty_reference_kind VALUE 'EA',
      bdl_determination_validation TYPE ty_reference_kind VALUE 'DV',
      bdl_event TYPE ty_reference_kind VALUE 'EE',
      bdl_extension TYPE ty_reference_kind VALUE 'BX',
      entity_parameter TYPE ty_reference_kind VALUE 'EP',
      entity_key TYPE ty_reference_kind VALUE 'EK',
      at_line_selection TYPE ty_reference_kind VALUE 'AL',
      at_pf TYPE ty_reference_kind VALUE 'AF',
      at_selection_screen TYPE ty_reference_kind VALUE 'AS',
      at_selection_screen_block TYPE ty_reference_kind VALUE 'AB',
      at_selection_screen_exit TYPE ty_reference_kind VALUE 'AX',
      at_selection_screen_help TYPE ty_reference_kind VALUE 'AH',
      at_selection_screen_on TYPE ty_reference_kind VALUE 'AN',
      at_selection_screen_on_end TYPE ty_reference_kind VALUE 'AE',
      at_selection_screen_output TYPE ty_reference_kind VALUE 'AP',
      at_selection_screen_radio TYPE ty_reference_kind VALUE 'AR',
      at_selection_screen_value TYPE ty_reference_kind VALUE 'AV',
      at_user_command TYPE ty_reference_kind VALUE 'AU',
      end_of_editing TYPE ty_reference_kind VALUE 'E0',
      end_of_selection TYPE ty_reference_kind VALUE 'E1',
      get TYPE ty_reference_kind VALUE 'GE',
      get_late TYPE ty_reference_kind VALUE 'GL',
      global_interface TYPE ty_reference_kind VALUE 'GI',
      group TYPE ty_reference_kind VALUE 'GR',
      infotype TYPE ty_reference_kind VALUE 'IT',
      initialization TYPE ty_reference_kind VALUE 'E2',
      interface TYPE ty_reference_kind VALUE 'IN',
      intf_pool TYPE ty_reference_kind VALUE 'IP',
      line_of TYPE ty_reference_kind VALUE 'LO',
      load_of_program TYPE ty_reference_kind VALUE 'E3',
      locally_defined_type TYPE ty_reference_kind VALUE 'LT',
      locally_defined_association TYPE ty_reference_kind VALUE 'LA',
      module_in TYPE ty_reference_kind VALUE 'MX',
      module_out TYPE ty_reference_kind VALUE 'MO',
      pf_status TYPE ty_reference_kind VALUE 'PF',
      predefined_data TYPE ty_reference_kind VALUE 'PD',
      predefined_type TYPE ty_reference_kind VALUE 'PT',
      screen TYPE ty_reference_kind VALUE 'SC',
      section TYPE ty_reference_kind VALUE 'SE',
      start_of_editing TYPE ty_reference_kind VALUE 'E4',
      start_of_selection TYPE ty_reference_kind VALUE 'E5',
      system_type TYPE ty_reference_kind VALUE 'YT',
      title TYPE ty_reference_kind VALUE 'TI',
      top_of_page TYPE ty_reference_kind VALUE 'E6',
      top_of_page_line_selection TYPE ty_reference_kind VALUE 'E7',
      dynpro_fields TYPE ty_reference_kind VALUE 'D1',
      dynpro_flow TYPE ty_reference_kind VALUE 'D2',
      domain TYPE ty_reference_kind VALUE 'DO',
      feature_toggle TYPE ty_reference_kind VALUE 'FT',
      switch TYPE ty_reference_kind VALUE 'SW',
      switch_based_feature_toggle TYPE ty_reference_kind VALUE 'SF',
      block TYPE ty_reference_kind VALUE 'BL',
      break_point TYPE ty_reference_kind VALUE 'BR',
      component TYPE ty_reference_kind VALUE 'CO',
      control TYPE ty_reference_kind VALUE 'CT',
      custom_function TYPE ty_reference_kind VALUE 'CF',
      ddls TYPE ty_reference_kind VALUE 'DD',
      dialog TYPE ty_reference_kind VALUE 'DI',
      enhancement_exit TYPE ty_reference_kind VALUE 'EX',
      enhancement_implementation TYPE ty_reference_kind VALUE 'EI',
      enhancement_spot TYPE ty_reference_kind VALUE 'ES',
      enhancement TYPE ty_reference_kind VALUE 'EN',
      service_binding TYPE ty_reference_kind VALUE 'SB',
      set_get_id TYPE ty_reference_kind VALUE 'SG',
      issue_query TYPE ty_reference_kind VALUE 'IQ',
      issue_schema TYPE ty_reference_kind VALUE 'IS',
      scalar_function TYPE ty_reference_kind VALUE 'DS',
      data_access_control TYPE ty_reference_kind VALUE 'DC',
      chdo TYPE ty_reference_kind VALUE 'CD',
      background_queue_context TYPE ty_reference_kind VALUE 'BQ',
      external_schema TYPE ty_reference_kind VALUE 'LS',
      code_composer_template TYPE ty_reference_kind VALUE 'CC',
      qdef_calculation TYPE ty_reference_kind VALUE 'QC',
    END OF compiler_reference_kinds.

  CONSTANTS:
    BEGIN OF usage_modes,
      definition TYPE ty_usage_mode VALUE '2',
      definition_with_write TYPE ty_usage_mode VALUE '3',
      definition_with_assign TYPE ty_usage_mode VALUE '4',
      read TYPE ty_usage_mode VALUE '5',
      write TYPE ty_usage_mode VALUE '6',
      read_and_write TYPE ty_usage_mode VALUE '7',
      read_database TYPE ty_usage_mode VALUE 'E',
      write_database TYPE ty_usage_mode VALUE 'F',
      redefinition TYPE ty_usage_mode VALUE 'R',
      enhancement_point TYPE ty_usage_mode VALUE 'P',
      enhancement_section TYPE ty_usage_mode VALUE 'S',
      name TYPE ty_usage_mode VALUE '0',
      type TYPE ty_usage_mode VALUE '1',
      write_partial TYPE ty_usage_mode VALUE 'D',
      read_reference TYPE ty_usage_mode VALUE '8',
      write_reference TYPE ty_usage_mode VALUE '9',
      read_and_write_reference TYPE ty_usage_mode VALUE 'A',
      any_access_reference TYPE ty_usage_mode VALUE 'B',
      assign TYPE ty_usage_mode VALUE 'C',
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

  TYPES:
    BEGIN OF ty_token,
      lexeme     TYPE ty_lexeme,
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
