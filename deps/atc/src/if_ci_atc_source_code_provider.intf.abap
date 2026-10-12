"! <p class="shorttext synchronized" lang="en">Data provider for ATC checks that analyze ABAP code</p>
"! Provides detailed information about ABAP source code. Similar to the data structures used by the legacy Code Inspector checks inheriting
"! from {@link CL_CI_TEST_ABAP_COMP_PROCS}. The main entry point is {@link IF_CI_ATC_SOURCE_CODE_PROVIDER.METH:GET_PROCEDURES}.
"!
interface IF_CI_ATC_SOURCE_CODE_PROVIDER
  public .


  types:
    ty_object_type TYPE c LENGTH 4 .
  types:
    "! Kind of an ABAP compilation unit
    BEGIN OF ENUM ty_compilation_unit_kind STRUCTURE compilation_unit_kinds BASE TYPE ty_object_type,
      "! Invalid (this enum does not have a meaningful initial value)
      invalid        VALUE IS INITIAL,
      "! An ABAP Objects class
      class          VALUE 'CLAS',
      "! An ABAP report
      report         VALUE 'PROG',
      "! An ABAP function group
      function_group VALUE 'FUGR',
      "! An ABAP type pool
      type_pool      VALUE 'TYPE',
      "! An ABAP Objects interface
      interface      VALUE 'INTF',
    END OF ENUM ty_compilation_unit_kind STRUCTURE compilation_unit_kinds .
  types:
    ty_compilation_unit_name TYPE c LENGTH 40 .
  types:
    "! An ABAP compilation unit
    BEGIN OF ty_compilation_unit,
      "! Kind, e.g. program, class, function group
      kind TYPE ty_compilation_unit_kind,
      "! Name
      name TYPE ty_compilation_unit_name,
    END OF ty_compilation_unit .
  types:
    "! Kind of an ABAP procedure
    BEGIN OF ENUM ty_procedure_kind STRUCTURE procedure_kinds BASE TYPE ty_object_type,
      "! Invalid (this enum does not have a meaningful initial value)
      invalid             VALUE IS INITIAL,
      "! A method (of a global or local class)
      method              VALUE 'METH',
      "! A (global or local) class definition
      class_definition    VALUE 'DECL',
      "! A FORM subroutine in a report or function group.
      form_routine        VALUE 'FORM',
      "! A function module in a function group
      function            VALUE 'FUNC',
      "! The AT USER-COMMAND event in a report
      at_user_command     VALUE 'ATUC',
      "! The AT LINE-SELECTION event in a report
      at_line_selection   VALUE 'LISE',
      "! The AT PFnn event in a report
      at_pf_status        VALUE 'ATPF',
      "! The AT SELECTION-SCREEN event in a report
      at_selection_screen VALUE 'ATSS',
      "! The input section of a dynpro module
      module_in           VALUE 'MODI',
      "! The output section of a dynpro module
      module_out          VALUE 'MODO',
      "! The START-OF-SELECTION event in a report
      start_of_selection  VALUE 'SSEL',
      "! The END-OF-SELECTION event in a report
      end_of_selection    VALUE 'ESEL',
      "! The TOP-OF-PAGE event in a report
      top_of_page         VALUE 'TOPA',
      "! The TOP-OF-PAGE DURING LINE-SELECTION event in a report
      top_of_page_during  VALUE 'TOPS',
      "! The END-OP-PAGE event in a report
      end_of_page         VALUE 'ENPA',
      "! THe LOAD-OF-PROGRAM event in a report
      load_of_program     VALUE 'LDPR',
      "! The INITIALIZATION event in a report
      initialization      VALUE 'INIT',
      "! The GET event in a report
      get                 VALUE 'GET ',
      "! The GET LATE event in a report
      get_late            VALUE 'GETL',
      "! Procedure that can be emitted in certain compiler error situations
      overflow            VALUE '%%%%',
      "! Unknown procedure type
      unknown             VALUE '!!!!',
    END OF ENUM ty_procedure_kind STRUCTURE procedure_kinds .
  types TY_PROCEDURE_NAME type STRING .
  types:
    "! Unique identifier for an ABAP procedure
    BEGIN OF ty_procedure_id,
      "! The kind of the procedure
      kind      TYPE ty_procedure_kind,
      "! The name of the procedure
      name      TYPE ty_procedure_name,
      "! The compilation unit that contains this procedure. Note that names are globally unique for some
      "! procedure kinds (e.g. for function modules), partially unique for others (e.g. for global but not local methods)
      "! and completely non-unique for the rest (e.g. for FORM subroutines).
      main_unit TYPE ty_compilation_unit,
    END OF ty_procedure_id .
  types TY_KEYWORD type STRING .
  types TY_LEXEME type STRING .
  types:
    "! Position within an ABAP include
    BEGIN OF ty_source_position,
      "! Line inside an include
      line   TYPE i,
      "! Column inside an include (maximally 255)
      column TYPE int1,
    END OF ty_source_position .
  types TY_FULL_NAME type STRING .
  types:
    ty_compiler_reference_tag TYPE c LENGTH 2 .
  types:
    "! Kind of a compilar reference
    BEGIN OF ENUM ty_reference_kind STRUCTURE compiler_reference_kinds BASE TYPE ty_compiler_reference_tag,
      "! Invalid (this enum does not have a meaningful initial value)
      invalid                      VALUE IS INITIAL,
      "! An association (of a CDS view)
      association                  VALUE 'AC',
      "! An authority object
      authority_object             VALUE 'AO',
      authorization_context        VALUE 'AT',
      "! Common part (obsolete shared data between reports and function modules)
      common_part                  VALUE 'CP',
      "! A variable defined by the DATA statement
      data                         VALUE 'DA',
      "! An ABAP Objects event defined by the EVENTS or CLASS-EVENTS statements
      event                        VALUE 'EV',
      "! A FORM subroutine
      form                         VALUE 'FO',
      "! A function module
      function                     VALUE 'FU',
      "! A function group
      function_pool                VALUE 'FP',
      "! A database function
      database_function            VALUE 'DF',
      "! An include (used in an INCLUDE statement)
      include                      VALUE 'IC',
      "! A macro defined locally or in a type group
      macro                        VALUE 'MA',
      "! A macro defined in the TRMAC table
      macro_trmac                  VALUE 'RM',
      matchcode                    VALUE 'MC',
      "! A T100-style message
      message                      VALUE 'MG',
      "! Message class of a T100-style message
      message_id                   VALUE 'MI',
      "! Message number of a T100-style message
      message_number               VALUE 'MN',
      "! Display type of a T100-style message
      message_type                 VALUE 'MT',
      "! Method of an ABAP Objects class
      method                       VALUE 'ME',
      "! A program (not necessarily a report), in the sense of what {@link CL_CI_ATC_DATA_PROVIDER.METH:MAIN_PROGRAM_FROM_COMP_UNIT} returns
      program                      VALUE 'PR',
      reference                    VALUE 'RE',
      shared_data                  VALUE 'SD',
      "! An anonymous type (e.g. the type of an object defined via 'DATA char TYPE c LENGTH 40')
      shared_type                  VALUE 'ST',
      "! A secondary table key
      table_key                    VALUE 'TK',
      "! A text element
      text_element                 VALUE 'TE',
      transaction                  VALUE 'TA',
      transformation               VALUE 'TR',
      "! An ABAP unit test seam
      test_seam                    VALUE 'TS',
      "! A type
      type                         VALUE 'TY',
      "! A "path element" for references to types that cannot be named directly
      type_of                      VALUE 'TO',
      type_of_type                 VALUE 'TT',
      "! A type pool
      type_pool                    VALUE 'TP',
      value                        VALUE 'VA',
      schema                       VALUE 'SH',


      "! A group for behavior implementations
      bdl_group                    VALUE 'EG',
      "! An operation of a behavior definition
      bdl_operation                VALUE 'OP',
      "! An action of a behavior definition
      bdl_action                   VALUE 'EA',
      "! A determination or validation of a behavior definition
      bdl_determination_validation VALUE 'DV',
      "! Event of a behavior definition
      bdl_event                    VALUE 'EE',
      "! BDL extension
      bdl_extension                VALUE 'BX',
      "! Parameter of a CDS entity
      entity_parameter             VALUE 'EP',
      "! Key of a CDS entity
      entity_key                   VALUE 'EK',

      "! Reporting event
      at_line_selection            VALUE 'AL',
      "! Reporting event
      at_pf                        VALUE 'AF',
      "! Reporting event
      at_selection_screen          VALUE 'AS',
      "! Selection screen element
      at_selection_screen_block    VALUE 'AB',
      "! Selection screen element
      at_selection_screen_exit     VALUE 'AX',
      "! Selection screen element
      at_selection_screen_help     VALUE 'AH',
      "! Reporting event
      at_selection_screen_on       VALUE 'AN',
      "! Reporting event
      at_selection_screen_on_end   VALUE 'AE',
      "! Selection screen element
      at_selection_screen_output   VALUE 'AP',
      "! Selection screen element
      at_selection_screen_radio    VALUE 'AR',
      "! Selection screen element
      at_selection_screen_value    VALUE 'AV',
      "! Reporting event
      at_user_command              VALUE 'AU',
      "! Reporting event
      end_of_editing               VALUE 'E0',
      "! Reporting event
      end_of_selection             VALUE 'E1',
      "! Reporting event (for logical databases)
      get                          VALUE 'GE',
      "! Reporting event (for logical databases)
      get_late                     VALUE 'GL',
      "! Global interface variable of a function module (do not confuse this with an ABAP objects interface!)
      global_interface             VALUE 'GI',
      group                        VALUE 'GR',
      "! HR infotype
      infotype                     VALUE 'IT',
      "! Reporting event
      initalization                VALUE 'E2',
      "! An ABAP objects interface
      interface                    VALUE 'IN',
      "! An ABAP objects interface main program
      intf_pool                    VALUE 'IP',
      line_of                      VALUE 'LO',
      "! Reporting event
      load_of_program              VALUE 'E3',
      "! Anonymous type defined within a statement
      locally_defined_type         VALUE 'LT',
      "! Association defined within a SELECT statement (e.g. via hierarchy functions)
      locally_defined_association  VALUE 'LA',
      "! Dynpro module event
      module_in                    VALUE 'MX',
      "! Dynpro module event
      module_out                   VALUE 'MO',
      "! A dynpro menu status
      pf_status                    VALUE 'PF',
      predefined_data              VALUE 'PD',
      "! Built-in ABAP type, e.g. I
      predefined_type              VALUE 'PT',
      "! A dynpro screen (referred to e.g. by a 'LEAVE TO SCREEN xxx' statement
      screen                       VALUE 'SC',
      section                      VALUE 'SE',
      "! Reporting event
      start_of_editing             VALUE 'E4',
      "! Reporting event
      start_of_selection           VALUE 'E5',
      system_type                  VALUE 'YT',
      title                        VALUE 'TI',
      "! Reporting event
      top_of_page                  VALUE 'E6',
      top_of_page_line_selection   VALUE 'E7',
      dynpro_fields                VALUE 'D1',
      dynpro_flow                  VALUE 'D2',
      domain                       VALUE 'DO',
      feature_toggle               VALUE 'FT',
      switch                       VALUE 'SW',
      switch_based_feature_toggle  VALUE 'SF',

      block                        VALUE 'BL',
      break_point                  VALUE 'BR',
      component                    VALUE 'CO',
      control                      VALUE 'CT',
      custom_function              VALUE 'CF',
      ddls                         VALUE 'DD',
      dialog                       VALUE 'DI',
      enhancement_exit             VALUE 'EX',
      enhancement_implementation   VALUE 'EI',
      enhancement_spot             VALUE 'ES',
      enhancement                  VALUE 'EN',
      service_binding              VALUE 'SB',
      set_get_id                   VALUE 'SG',
      issue_query                  VALUE 'IQ',
      issue_schema                 VALUE 'IS',
      scalar_function              VALUE 'DS',
      data_access_control          VALUE 'DC',
      chdo                         VALUE 'CD',
      background_queue_context     VALUE 'BQ',
      external_schema              VALUE 'LS',
      code_composer_template       VALUE 'CC',
      qdef_calculation             VALUE 'QC',
    END OF ENUM ty_reference_kind STRUCTURE compiler_reference_kinds .
  types:
    ty_compiler_usage_tag TYPE c LENGTH 1 .
  types:
    "! Grades of usages of references. Roughly answers the question how much detail about the referenced entity the compiler
    "! needs to know at this point.
    BEGIN OF ENUM ty_usage_grade STRUCTURE usage_grades BASE TYPE ty_compiler_usage_tag,
      "! Invalid (this enum has no meaningful initial value)
      invalid    VALUE IS INITIAL,
      "! This is the definition location for this reference
      definition VALUE '0',
      "! This reference is used directly
      direct     VALUE '1',
      "! This reference is only used here to address one of its components
      component  VALUE '2',
      "! This reference is used indirectly here. Usually this means that the name of the reference
      "! does not appear in the source code, but that the compiler has nevertheless linked it to this location.
      indirect   VALUE '3',
    END OF ENUM ty_usage_grade STRUCTURE usage_grades .
  types:
    "! Modes of usages of references. Roughly answers the question what happens with the reference at this location
    BEGIN OF ENUM ty_usage_mode STRUCTURE usage_modes BASE TYPE ty_compiler_usage_tag,
      "! Invalid (this enumeration type has no meaningful initial value)
      invalid                  VALUE IS INITIAL,
      "! This is an enhancement point
      enhancement_point        VALUE 'P',
      "! This is an enhancement section
      enhancement_section      VALUE 'S',
      name                     VALUE '0',
      "! This is a type
      type                     VALUE '1',
      "! This is a definition
      definition               VALUE '2',
      "! This is a definition and a write position, i.e. an inline DATA(...) definition
      definition_with_write    VALUE '3',
      "! This is a definition and an assignment position, i.e. an inline FIELD-SYMBOL(...) definition
      definition_with_assign   VALUE '4',
      "! This is a read position
      read                     VALUE '5',
      "! This is a write position
      write                    VALUE '6',
      "! Some components of the object are written at this position
      write_partial            VALUE 'D',
      "! This is a read and a write position
      read_and_write           VALUE '7',
      "! This is a read position for an object referenced by this object
      read_reference           VALUE '8',
      "! This is a write position for an object referenced by this object
      write_reference          VALUE '9',
      "! This is a read and a write position for an object referenced by this object
      read_and_write_reference VALUE 'A',
      any_access_reference     VALUE 'B',
      "! This is an assignment position
      assign                   VALUE 'C',
      "! This read data from the database
      read_database            VALUE 'E',
      "! This writes data to the database
      write_database           VALUE 'F',
      "! This is a redefinition of an inherited method
      redefinition             VALUE 'R',
    END OF ENUM ty_usage_mode STRUCTURE usage_modes .
  types:
    "! <p>A compiler reference. Compiler references refer to symbols in the symbol table via their full names (globally unique
    "! identifiers for symbols) and contain basic information about how the symbol is accessed at the current position.</p>
    "!
    "! <p><strong>
    "! Caution:</strong> While the full names of symbols have a structure, it is not guaranteed that the same symbol will have the exact same full
    "! name for all compiler versions (i.e. kernel releases), so it is advised to treat these as opaque identifiers.</p>
    BEGIN OF ty_compiler_reference,
      "! Full name of the corresponding symbol
      full_name   TYPE ty_full_name,
      "! Kind of the referenced symbol, e.g. whether it is a type or a data object
      kind        TYPE ty_reference_kind,
      "! Usage grade of the referenced symbol, i.e. how much of it is accessed here
      usage_grade TYPE ty_usage_grade,
      "! Usage mode of the referenced symbol, i.e. in what manner it is accessed here, e.g.
      "! whether it is read or written to
      usage_mode  TYPE ty_usage_mode,
    END OF ty_compiler_reference .
  types:
    ty_compiler_references TYPE STANDARD TABLE OF ty_compiler_reference WITH EMPTY KEY .
  types:
    "! A token as tokenized by the SCAN ABAP-SOURCE statement
    BEGIN OF ty_token,
      "! The lexeme, i.e. the textual content of the token
      lexeme     TYPE ty_lexeme,
      "! The position of the token within its include
      position   TYPE ty_source_position,
      "! The compiler symbols that are bound to the token
      references TYPE ty_compiler_references,
    END OF ty_token .
  types:
    ty_tokens TYPE STANDARD TABLE OF ty_token WITH EMPTY KEY .
  types:
    ty_pseudo_comments TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line .
  types:
    ty_include TYPE c LENGTH 40 .
  types:
    "! An ABAP statement
    BEGIN OF ty_statement,
      "! The keyword the ABAP statement starts with. Assignment operations like 'a = b.' start
      "! implicitly with COMPUTE, while functional method calls 'obj->meth( )' start with +CALL_METHOD.
      keyword         TYPE ty_keyword,
      "! The tokens this statement consists of. The terminator '.' or ',' is not a token.
      tokens          TYPE ty_tokens,
      "! Pseudo comments that refer to this statement
      pseudo_comments TYPE ty_pseudo_comments,
      "! The include this statement is found in
      include         TYPE ty_include,
      "! Position of the first token of the statement within the include
      position        TYPE ty_source_position,
      "! Whether or not this statement is in the scope of code for which
      "! problems should be reported
      is_in_scope     TYPE abap_bool,
      "! Index (in the blocks table in {@link IF_CI_ATC_SOURCE_CODE_PROVIDER.TY_PROCEDURE}) of the innermost block that contains this statement
      block           TYPE i,
    END OF ty_statement .
  types:
    ty_statements TYPE STANDARD TABLE OF ty_statement WITH EMPTY KEY
      WITH NON-UNIQUE SORTED KEY keyword COMPONENTS keyword .
  types TY_FLAG type SYCHAR01 .
  types:
    BEGIN OF ENUM ty_block_type structure block_type BASE TYPE ty_flag,
      "! Invalid (this enumeration type has no meaningful initial value)
      invalid     VALUE IS INITIAL,
      "! source code begin
      program     VALUE  'P',
      "!  method, form, function or module
      routine     VALUE  'R',
      "! define, exec or inject
      macro       VALUE  'M',
      "! do, while, loop, provide, select or with
      iteration   VALUE  'I',
      "! if, case, on, at, try, or seam
      alternation VALUE  'A',
      "! when, else, then, elseif, catch or cleanup
      condition   VALUE  'C',
      "! check, continue, exit, return, reject, stop, leave, raise, call or submit
      jump        VALUE  'J',
      "! data, data_common, statics, constants, types or selection_screen
      declaration VALUE  'D',
      "! load_of_program, initialization, start_of_selection, end_of_selection, start_of_editing, end_of_editing,
      "! top_of_page, top_of_page_during, end_of_page system_exit, at_user_command, at_line_selection, at_selection_screen
      "! at_pf_i or ldb_get
      event       VALUE  'E',
      "! class_definition, class_implementation, interface or public/package/protected/private section
      class       VALUE  'L',
      "! sequence of statements
      sequence    VALUE  'S',
    END OF ENUM ty_block_type structure block_type .
  types:
    BEGIN OF ENUM ty_statement_type structure statement_type BASE TYPE ty_flag,
      "! Invalid (this enumeration type has no meaningful initial value)
      invalid              VALUE IS INITIAL,
      program              VALUE 'P',
      report               VALUE 'R',
      function_pool        VALUE 'F',
      type_pool            VALUE 'T',
      class_pool           VALUE 'C',
      interface_pool       VALUE 'I',

      sequence             VALUE '?',

      module               VALUE 'M',
      function             VALUE 'U',
      form                 VALUE 'O',
      method               VALUE 'H',

      define               VALUE 'N',
      exec                 VALUE 'E',
      inject               VALUE '(',

      do                   VALUE 'D',
      while                VALUE 'W',
      loop                 VALUE 'L',
      provide              VALUE 'V',
      select               VALUE 'S',
      with                 VALUE 'Q',

      if                   VALUE 'i',
      case                 VALUE 'c',
      on                   VALUE 'o',
      at                   VALUE 'a',
      try                  VALUE '_',
      seam                 VALUE ')',

      when                 VALUE 'w',
      else                 VALUE 'e',
      then                 VALUE '>',
      elseif               VALUE 'f',
      catch                VALUE '+',
      cleanup              VALUE '-',

      check                VALUE 'h',
      continue             VALUE 'n',
      exit                 VALUE 'x',
      return               VALUE '!',
      reject               VALUE 'r',
      stop                 VALUE 'p',
      leave                VALUE 'l',
      raise                VALUE '0',
      call                 VALUE '1',
      submit               VALUE 'u',
      retry                VALUE 'K',

      data                 VALUE 'd',
      data_common          VALUE 'm',
      statics              VALUE 's',
      constants            VALUE 'k',
      types                VALUE 't',
      selection_screen     VALUE 'b',

      class_definition     VALUE 'X',
      class_implementation VALUE 'Y',
      interface            VALUE 'Z',
      public_section       VALUE 'A',
      package_section      VALUE 'J',
      protected_section    VALUE 'B',
      private_section      VALUE 'G',

      load_of_program      VALUE 'g',
      initialization       VALUE '2',
      start_of_selection   VALUE '3',
      end_of_selection     VALUE '4',
      start_of_editing     VALUE '5',
      end_of_editing       VALUE '6',
      top_of_page          VALUE '7',
      top_of_page_during   VALUE '8',
      end_of_page          VALUE '9',
      system_exit          VALUE 'j',
      at_user_command      VALUE 'q',
      at_line_selection    VALUE 'v',
      at_selection_screen  VALUE 'y',
      at_pf_i              VALUE 'z',
      ldb_get              VALUE '<',
    END OF ENUM ty_statement_type structure statement_type .
  types:
    "! Interval of positive integers. Valid intervals have either TO > FROM > 0 or TO = FROM = 0.
    BEGIN OF ty_interval,
      from TYPE i,
      to TYPE i,
    END OF ty_interval .
  types:
    "! Information about a programming block
    BEGIN OF ty_block,
      type           TYPE ty_block_type,
      "! The type of the statement that this block starts with
      statement_type TYPE ty_statement_type,
      "! The statements that belong to this block. The interval values are indices in the statement table of the current {@link IF_CI_ATC_SOURCE_CODE_PROVIDER.TY_PROCEDURE}
      statements     TYPE ty_interval,
      "! The blocks that are nested within this block
      blocks         TYPE ty_interval,
      "! The parent block this bock is nested within. If there is no parent, this is zero.
      parent         TYPE i,
    END OF ty_block .
  types:
  "! A table of information about programming blocks
    ty_blocks TYPE STANDARD TABLE OF ty_block WITH EMPTY KEY .
  types:
    "! Analysis structure for an ABAP procedure
    BEGIN OF ty_procedure,
      "! Unique identifier for the procedure
      id         TYPE ty_procedure_id,
      "! All statements of the procedure, including introductory statements like 'START-OF-SELECTION.'
      statements TYPE ty_statements,
      "! Table of (nested) programming blocks that are present within this procedure
      blocks     TYPE ty_blocks,
    END OF ty_procedure .
  types:
    ty_procedures TYPE STANDARD TABLE OF ty_procedure WITH EMPTY KEY
      WITH UNIQUE HASHED KEY id COMPONENTS id .
  types TY_TOKEN_INDEX type I .

  "! Returns the analysis data for all procedures of an ABAP compilation unit. The return type is a reference because the procedures are
  "! represented by a deep table type for which copying (or moving by value in general) can incur significant runtime costs. Be careful not to accidentally trigger a
  "! copy of the whole table body.
  "! @parameter compilation_unit | The compilation unit
  "! @parameter procedures | Procedures of the compilation unit
  "! @raising cx_ci_atc_invalid_comp_unit | Raised when the compilation unit cannot be found in the source system
  methods GET_PROCEDURES
    importing
      !COMPILATION_UNIT type TY_COMPILATION_UNIT
    returning
      value(PROCEDURES) type ref to TY_PROCEDURES
    raising
      CX_CI_ATC_INVALID_COMP_UNIT .
  "! Returns the procedure called by a specific token, i.e. the target of a PERFORM, CALL FUNCTION, CALL METHOD or inline method call.
  "! E.g. for a statement 'CALL FUNCTION 'FUNC'.', this method expects the 'FUNC' token in the CALLING_TOKEN parameter.
  "! @parameter compilation_unit | The current compilation unit (necessary to find the symbol referred to by the CALLING_TOKEN)
  "! @parameter calling_token | The token denoting the called procedure
  "! @parameter procedure | Analysis data for the called procedure
  "! @raising cx_ci_atc_token_no_call | Raised when the CALLING_TOKEN is not actually part of a procedure call
  methods GET_CALLED_PROCEDURE
    importing
      !COMPILATION_UNIT type TY_COMPILATION_UNIT
      !CALLING_TOKEN type TY_TOKEN
    returning
      value(PROCEDURE) type TY_PROCEDURE
    raising
      CX_CI_ATC_TOKEN_NO_CALL .
  "! Turns a generic object into a compilation unit. This will produce a runtime error if you
  "! pass in an object that does not correspond to an ABAP compilation unit (e.g. a dictionary structure).
  "! @parameter object | R3TR object corresponding to an ABAP compilation unit
  "! @parameter compilation_unit | The corresponding ABAP compilation unit
  methods OBJECT_TO_COMP_UNIT
    importing
      !OBJECT type IF_CI_ATC_CHECK=>TY_OBJECT
    returning
      value(COMPILATION_UNIT) type TY_COMPILATION_UNIT .
  "! Convenience method that returns the location of a given statement.
  "!
  "! @parameter statement | ABAP statement
  "! @parameter location | The statement's location
  methods GET_STATEMENT_LOCATION
    importing
      !STATEMENT type TY_STATEMENT
    returning
      value(LOCATION) type IF_CI_ATC_CHECK=>TY_LOCATION .
  "! Computes a checksum with a cyclic redundancy check (CRC) algorithm for the given statement.
  "! Note that any change to the tokens of the statement will change the checksum, but no change to the definitions
  "! of the variables used by it will. Changes of surrounding statements are irrelevant.
  "!
  "! @parameter statement | <p class="shorttext synchronized" lang="en"></p>
  "! @parameter checksum | <p class="shorttext synchronized" lang="en"></p>
  methods GET_STATEMENT_CHECKSUM
    importing
      !STATEMENT type TY_STATEMENT
    returning
      value(CHECKSUM) type IF_CI_ATC_CHECK=>TY_CHECKSUM .
  methods IS_KEYWORD default ignore
    importing
      !STRING type STRING
    returning
      value(RESULT) type ABAP_BOOL .
endinterface.