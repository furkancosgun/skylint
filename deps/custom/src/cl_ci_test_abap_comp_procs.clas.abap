class CL_CI_TEST_ABAP_COMP_PROCS definition
  public
  inheriting from CL_CI_TEST_ABAP_COMPILER
  create public .

public section.

  types:
    begin of T_FIELD,
        NAME   type STRING,
        TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS,
      end of T_FIELD .
  types:
    T_FIELD_LIST type standard table of T_FIELD with default key .

  constants C_CODE_SUMMARY type SCI_ERRC value 'STAT' ##NO_TEXT.
  constants C_CODE_DETAIL type SCI_ERRC value 'DETAIL' ##NO_TEXT.
  constants C_CODE_LEVEL type SCI_ERRC value 'LEVEL' ##NO_TEXT.
  constants C_DBTAB_UNKNOWN type TABNAME value '<DBTAB_UNKNOWN>' ##NO_TEXT.
  class-data TEST type SYCHAR01 .

  methods CONSTRUCTOR .
  class-methods CHECK_FOR_ENDSELECT
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
    returning
      value(P_NEEDS_ENDSELECT) type ABAP_BOOL .
  methods GET_DBTAB_IN_SELECT_STMT
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
    exporting
      !P_DB_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN .
  methods GET_INTO_FIELD_LIST
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
    exporting
      !P_FROM_LIST type T_FIELD_LIST
      !P_TO_LIST type T_FIELD_LIST
      !P_CORRESPONDING type ABAP_BOOL .

  methods CLEAR
    redefinition .
  methods GET_DBTAB_SYMBOL_ENTRY
    redefinition .
  methods GET_RESULT_NODE
    redefinition .
  methods RUN
    redefinition .
  methods RUN_END
    redefinition .
  methods VERIFY_TEST
    redefinition .
protected section.

  types:
    T_CRC type hashed table of SCI_CRC64 with unique key TABLE_LINE .
  types:
    begin of T_PROC_ID,
      PROGRAM   type PROGRAM,
      PROC_TYPE type SYCHAR04,
      PROC_NAME type STRING,
    end of   T_PROC_ID .
  types:
    T_PROC_IDS type sorted table of T_PROC_ID with unique key TABLE_LINE .
  types:
    begin of T_SOURCE_POSITION,
      ID              type T_PROC_ID,
      INCLUDE         type PROGRAM,
      LINE_IN_INCLUDE type I,
      LINE_IN_PROC    type I,
      COLUMN          type I,
    end of T_SOURCE_POSITION .
  types:
    begin of T_PROC_CALL,
      PROC_ID      type T_PROC_ID,
      CRC          type SCR_CRC64,
      LEVEL        type I,
      LEVEL_EXTERN type I,
      HOOK         type ref to OBJECT,
    end of   T_PROC_CALL .
  types:
    T_PROC_CALLS type sorted table of T_PROC_CALL with unique key PROC_ID CRC .
  types:
    begin of T_PROC_CALLED_ENTRY,
      ID      type T_PROC_ID,
      INCLUDE type PROGRAM,
      LINE    type I,
      CRC     type SCI_CRC64,
      HOOK    type ref to OBJECT,
    end   of T_PROC_CALLED_ENTRY .
  types:
    T_PROC_CALLED type sorted table of  T_PROC_CALLED_ENTRY with unique key ID .
  types:
    T_FULL_NAMES type standard table of STRING with non-unique default key .
  types:
    T_SORTED_FULL_NAMES type sorted table of STRING with unique key TABLE_LINE .
  types:
    begin of T_SCAN,
      PROGRAM        type PROGRAM,
      TOKENS         type STOKESX_TAB,
      STATEMENTS     type SSTMNT_TAB,
      LEVELS         type SLEVEL_TAB,
      STRUCTURES     type SSTRUC_TAB,
      STMNT_2_ORIGIN type CL_CI_SCAN=>T_STMNT_2_ORIGIN_TAB,
      ORIGINS        type CL_CI_SCAN=>T_ORIGIN_TAB,
    end of   T_SCAN .
  types:
    begin of T_CALLED_ENTRY,
      PROC_ID   type T_PROC_ID,
      USED_VARS type T_SORTED_FULL_NAMES,
    end of T_CALLED_ENTRY .
  types:
    T_CALLED_ENTRIES type sorted table of T_CALLED_ENTRY with unique key PROC_ID .
  types:
    begin of T_STACK_ENTRY,
      PROC_ID      type T_PROC_ID,
      STMT         type CL_ABAP_COMP_PROCS=>T_STMT,
      STMT_PROC_ID type T_PROC_ID,
      LOOP         type ABAP_BOOL,
      STMT_IDX     type I,
      LEVEL_1      type I,
      LEVEL_2      type I,
      LEVEL_3      type I,
    end of T_STACK_ENTRY .
  types:
    T_STACK_ENTRIES type standard table of T_STACK_ENTRY
                                                                   with key PROC_ID STMT-KEYWORD STMT-INCLUDE STMT-LINE STMT-COLUMN .
  types:
    begin of T_REF,
      PROGRAM         type PROGRAM,
      INCLUDE         type PROGRAM,
      LINE            type I,
      COLUMN          type INT2,
      KIND            type SCI_ERRC,
      NAME            type STRING,
      SOURCE          type STRING,
      INFO1           type STRING,
      INFO2           type STRING,
      INFO3           type STRING,
      INFO4           type STRING,
      STACK           type T_STACK_ENTRIES,
      PROC_POS        type SCIS_PROC_POS,
      STACK_OF_VAR    type T_STACK_ENTRIES,
      NO_MOVES        type SCI_NO_MOVES,
      COMMENTS        type CL_ABAP_COMP_PROCS=>T_COMMENTS,
      CHECKSUM        type SCI_CRC64,
      FINDING_ORIGINS type CL_ABAP_COMP_PROCS=>T_ORIGINS,
    end   of T_REF .
  types:
    T_INFOS       type standard table of T_REF with non-unique default key .
  types:
    begin of T_VAR,
      FULL_NAME type STRING,
      VALUE     type STRING,
      STACK     type T_STACK_ENTRIES,
      NO_MOVES  type SCI_NO_MOVES,
    end   of T_VAR .
  types:
    T_VARS type sorted table of T_VAR with unique key FULL_NAME VALUE .
  types:
    begin of T_VALUE,
      COMP     type STRING,
      VALUE    type STRING,
      STACK    type T_STACK_ENTRIES,
      NO_MOVES type SCI_NO_MOVES,
    end of T_VALUE .
  types:
    T_VALUES type hashed table of T_VALUE with unique key VALUE .
  types:
    begin of T_ASSIGN,
      FROM type STRING,
      TO   type STRING,
    end   of T_ASSIGN .
  types:
    T_ASSIGNS type sorted table of T_ASSIGN with unique key TO FROM
                                                                      with non-unique sorted key FROM components FROM .
  types:
    begin of T_COLLECT,
      VARS         type T_VARS,
      USED_VARS    type T_SORTED_FULL_NAMES,
      ASSIGNS      type T_ASSIGNS,
      STACK        type T_STACK_ENTRIES,
      MACRO_CALLED type ABAP_BOOL,
      HOOK         type ref to OBJECT,
    end of T_COLLECT .
  types:
    begin of T_PARAM,
      FORM_PARAM type STRING,
      ACT_PARAM  type CL_ABAP_COMP_PROCS=>T_TOKEN,
      CONDITION  type I,
      KIND       type SYCHAR01,
    end   of T_PARAM .
  types:
    T_PARAMS type standard table of T_PARAM with non-unique default key .
  types:
    begin of T_REF_CHECK,
      PROGRAM   type PROGRAM,
      REF_CHECK type ref to CL_ABAP_COMPILER,
    end   of T_REF_CHECK .
  types:
    begin of T_ABAP_COMPILER,
      PROGRAM       type PROGRAM,
      ABAP_COMPILER type ref to CL_ABAP_COMPILER,
    end   of T_ABAP_COMPILER .
  types:
    begin of T_METHOD_DEFINITION,
      PROGRAM   type PROGRAM,
      FULL_NAME type STRING,
      STMT      type CL_ABAP_COMP_PROCS=>T_STMT,
    end   of T_METHOD_DEFINITION .
  types:
    begin of T_TYPE_PROGRAM,
      TYPE    type STRING,
      PROGRAM type PROGRAM,
    end   of T_TYPE_PROGRAM .
  types:
    begin of T_PROC_INFO,
      PROC_TYPE type SYCHAR04,
      PROC_NAME type STRING,
      LEVEL_1   type I,
      LEVEL_2   type I,
      LEVEL_3   type I,
    end of T_PROC_INFO .
  types:
    T_PROC_INFOS type hashed table of T_PROC_INFO with unique key PROC_TYPE PROC_NAME .
  types:
    begin of T_SYMB_INFO,
      FULL_NAME type STRING,
      KIND      type STRING,
      INFO      type STRING,
    end of T_SYMB_INFO .
  types:
    T_SYMB_INFOS type hashed table of T_SYMB_INFO with unique key FULL_NAME KIND .
  types:
    T_PROG_INFOS_RAW type standard table of SCI_PROG_INFO .
  types:
    begin of T_PROG_INFO,
      PROC_INFOS type T_PROC_INFOS,
      SYMB_INFOS type T_SYMB_INFOS,
      PROGRAM    type PROGRAM,
      SDATE      type TRDIR-SDATE,
      STIME      type TRDIR-STIME,
      LOADED     type ABAP_BOOL,
      CHANGED    type ABAP_BOOL,
    end   of T_PROG_INFO .
  types:
    T_PROG_INFOS type hashed table of T_PROG_INFO with unique key PROGRAM .
  types:
    begin of T_FUNCTION_PROGRAM,
      FUNCNAME type STRING,
      PNAME    type TFDIR-PNAME,
    end   of T_FUNCTION_PROGRAM .
  types:
    begin of T_FULL_NAME_PROC_ID,
      FULL_NAME type STRING,
      PROC_ID   type T_PROC_ID,
    end of   T_FULL_NAME_PROC_ID .
  types T_SYMBOL type CL_ABAP_SYMBOL=>T_SYMBOL .
  types T_SYMBOLS type CL_ABAP_SYMBOL=>T_SYMBOLS .
  types:
    T_STRING_TAB type standard table of STRING with default key .

  class-data:
    FULL_NAME_PROC_ID type hashed table of T_FULL_NAME_PROC_ID with unique key FULL_NAME .
  class-data REF_PROCS type ref to CL_ABAP_COMP_PROCS .
  constants C_CLASS_DEFER type I value 3 ##NO_TEXT.
  constants C_CLASS_DEF_GLOB type I value 2 ##NO_TEXT.
  constants C_CLASS_DEF_LOC type I value 1 ##NO_TEXT.
  constants C_CLASS_IMPL type I value 5 ##NO_TEXT.
  constants C_CLASS_LOAD type I value 4 ##NO_TEXT.
  constants C_CLASS_FOR_TESTING type I value 5 ##NO_TEXT.
  class-data LEVEL type I value 20 ##NO_TEXT.
  constants C_CODE_ADDVAR type SCI_ERRC value 'ADDVAR' ##NO_TEXT.
  constants C_CODE_UNCLEAR type SCI_ERRC value 'UNCLEAR  ' ##NO_TEXT.
  constants C_MAX_INT type I value 2147483647 ##NO_TEXT.
  class-data:
    PROGRAMS        type hashed table of PROGRAM  with unique key TABLE_LINE .
  class-data:
    ERRONEOUS_PROGRAMS type hashed table of PROGRAM with unique key TABLE_LINE .
  class-data DYNPROS type CL_DYNP_COMP_PROCS=>T_DYNPROS .
  class-data MAIN_PROGRAM type PROGRAM .
  class-data INFOS type T_INFOS .
  class-data PROC_DEFS type CL_ABAP_COMP_PROCS=>T_PROCS .
  class-data:
    SCANS type sorted table of T_SCAN with unique key PROGRAM .
  class-data CHARSIZE type I .
  class-data:
    REF_CHECKS type hashed table of T_REF_CHECK with unique key PROGRAM .
  class-data:
    PROC_IDS_USED type hashed table of T_PROC_ID with unique key TABLE_LINE .
  class-data PROC_CALLS type T_PROC_CALLS .
  class-data:
    CLASSES type hashed table of STRING with unique key TABLE_LINE .
  class-data:
    METHOD_DEFINITIONS type sorted table of T_METHOD_DEFINITION with unique key PROGRAM FULL_NAME .
  class-data:
    TYPE_PROGRAM       type hashed table of T_TYPE_PROGRAM with unique key TYPE .
  data TAKE_ALL_SYMBOLS type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data SCAN_NEEDED type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data PA_DEBUG type SYCHAR01 .
  data PA_FULLNAME type SYCHAR255 .
  data CALLED_ENTRIES type T_CALLED_ENTRIES .
  data PROG_INFOS type T_PROG_INFOS .
  constants MAX_SAME_CALLS type I value 10 ##NO_TEXT.
  data DIAGNOSIS type ABAP_BOOL .
  class-data PROGRAM_LIST type SCIT_PROGRAM_HASH .
  class-data OBJECTSET type ref to CL_CI_OBJECTSET .
  class-data:
    FUNCTION_PROGRAM type hashed table of T_FUNCTION_PROGRAM with unique key FUNCNAME .
  data PREPARE type ABAP_BOOL .
  data:
    ABAP_COMPILER type sorted table of T_ABAP_COMPILER with unique key PROGRAM .
  data INSIDE_EXEC_SQL type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.

  methods GET_SELECT_STMT_INFOS
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
    exporting
      !P_SELECT_FIELDS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_SOURCE type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_TARGET_FIELDS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_TARGET_ITAB type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_WHERE_CLAUSE type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_HAS_ENDSELECT type ABAP_BOOL .
  methods IS_TABLE_WITH_HEAD
    importing
      value(P_NAME) type STRING
      !P_PROGRAM type PROGRAM
    returning
      value(P_RESULT) type ABAP_BOOL .
  methods CHECK_FOR_EXEC_SQL
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_LEVEL type I optional
      !P_PROC_IDS type T_PROC_IDS optional
    changing
      !P_COLLECT type T_COLLECT optional
    returning
      value(P_EXEC_SQL_CHANGED) type ABAP_BOOL .
  methods CONVERT_TO_PROC_ID
    importing
      !P_FULL_NAME type STRING
      !P_PROGRAM type PROGRAM optional
    exporting
      !P_PROC type T_PROC_ID .
  methods EXPORT_PROG_INFOS
    changing
      !P_PROG_INFOS type T_PROG_INFOS_RAW .
  methods IMPORT_PROG_INFO
    importing
      !P_PROGRAM type PROGRAM
      !P_VERSION type I
      !P_SDATE type TRDIR-SDATE
      !P_STIME type TRDIR-STIME
    exporting
      !P_PROG_INFO type XSTRING
      !P_SUBRC type SY-SUBRC .
  methods PUSH_STACK
    importing
      !P_PROC_ID type T_PROC_ID
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_STMT_IDX type I optional
      !P_STMT_PROC_ID type T_PROC_ID optional
      !P_LOOP type ABAP_BOOL default ABAP_FALSE
    changing
      !P_STACK type T_STACK_ENTRIES .
  methods POP_STACK
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_PROC_ID type T_PROC_ID optional
    exporting
      !P_LEVEL_1 type I
      !P_LEVEL_2 type I
      !P_LEVEL_3 type I
    changing
      !P_STACK type T_STACK_ENTRIES
    exceptions
      NO_MATCH .
  methods SET_PROC_INFO
    importing
      !P_LEVEL_1 type I default C_MAX_INT
      !P_LEVEL_2 type I default C_MAX_INT
      !P_LEVEL_3 type I default C_MAX_INT
    changing
      !P_STACK type T_STACK_ENTRIES .
  methods IS_IN_LOOP
    importing
      !P_STACK type T_STACK_ENTRIES
    returning
      value(P_IN_LOOP) type ABAP_BOOL .
  methods ANALYZE_START
    importing
      !P_REF_CHECK type ref to CL_ABAP_COMPILER
    exporting
      !P_REFS type T_INFOS .
  methods GET_CLASS_STMT_KIND
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
    returning
      value(P_KIND) type I .
  methods COMPARE_COMPONENTS
    importing
      !P_TYPE_1 type ref to CL_ABAP_COMP_STRUCTURE_TYPE
      !P_TYPE_2 type ref to CL_ABAP_COMP_STRUCTURE_TYPE
    returning
      value(P_RESULT) type ABAP_BOOL .
  methods LOAD_PROGRAM_PROC_DEFS
    importing
      !P_PROGRAM type PROGRAM
      !P_PREPARE_CALLS type ABAP_BOOL optional
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_CALLER_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_INFORM type ABAP_BOOL default ABAP_TRUE
    exporting
      !P_CHECKSUM type SCR_CRC64
      !P_SDATE type D
      !P_STIME type T
    exceptions
      ERROR .
  methods ANALYZE_PROCEDURE
    importing
      !P_PROC_ID type T_PROC_ID
      !P_LEVEL type I
    changing
      !P_COLLECT type T_COLLECT .
  methods ANALYZE_EVENT_PROCEDURE
    importing
      !P_PROGRAM type PROGRAM
      !P_PROC_TYPE type T_PROC_ID-PROC_TYPE
    changing
      !P_COLLECT type T_COLLECT .
  methods GET_CLAUSE_VAR
    importing
      !P_WORD_3 type STRING optional
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_WORD_1 type STRING
      !P_WORD_2 type STRING optional
      !P_WORD_4 type STRING optional
      !P_WORD_5 type STRING optional
      !P_TAG type SCR_TAG
    returning
      value(P_RESULT) type STRING .
  methods ANALYZE_CALL_WITH_STACK
    importing
      !P_PROC_ID type T_PROC_ID
      !P_PROC_IDS type T_PROC_IDS optional
      value(P_LEVEL) type I
      !P_PARAMS type T_PARAMS optional
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_MACRO_CALLED type ABAP_BOOL default ABAP_FALSE
      !P_FORCE type ABAP_BOOL default ABAP_FALSE
      !P_STMT_IDX type I optional                                "obsolete
      !P_STMT_PROC_ID type T_PROC_ID optional        "obsolete
      !P_STMT_PROGRAM type PROGRAM optional          "obsolete
    changing
      !P_COLLECT type T_COLLECT .
  methods ANALYZE_CALL
    importing
      !P_PROC_ID type T_PROC_ID
      value(P_PROC_IDS) type T_PROC_IDS
      value(P_LEVEL) type I
      !P_PARAMS type T_PARAMS optional
      !P_FORCE type ABAP_BOOL default ABAP_FALSE
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
    changing
      !P_COLLECT type T_COLLECT .
  methods ANALYZE_PERFORMS
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_PERFORM_IDS type T_PROC_IDS
      !P_LEVEL type I
      !P_LEVEL_EXTERN type I optional
      !P_PROC_IDS type T_PROC_IDS
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_MACRO_CALLED type ABAP_BOOL default ABAP_FALSE
      !P_STMT_IDX type I optional                        "obsolete
    changing
      !P_COLLECT type T_COLLECT .
  methods GET_PERFORM_PARAMS
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_USE_CACHE type ABAP_BOOL optional
    exporting
      !P_PARAMS type T_PARAMS .
  methods GET_FORM_INFOS
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_ONLY_LOCAL type ABAP_BOOL default ABAP_FALSE
      !P_CONDITION type I optional
      !P_LEVEL type I optional
      !P_USE_CACHE type ABAP_BOOL optional
      !P_RESTRICT_TO_OBJECTSET type ABAP_BOOL default ABAP_FALSE
      !P_PROC_IDS type T_PROC_IDS optional
    exporting
      !P_PARAMS type T_PARAMS
      !P_PROC_ID type T_PROC_ID
      !P_PERFORM_IDS type T_PROC_IDS
    changing
      !P_COLLECT type T_COLLECT
    exceptions
      NOT_FOUND
      NON_LOCAL_FORM
      NOT_RELEVANT
      NOT_IN_OBJECTSET
      ERROR .
  methods GET_FUNCTION_INFOS
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_PROC_IDS type T_PROC_IDS
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_ONLY_LOCAL type ABAP_BOOL default ABAP_FALSE
      !P_CONDITION type I optional
      !P_LEVEL type I optional
      !P_USE_CACHE type ABAP_BOOL optional
      !P_RESTRICT_TO_OBJECTSET type ABAP_BOOL default ABAP_FALSE
    exporting
      !P_PARAMS type T_PARAMS
      !P_PROC_ID type T_PROC_ID
    changing
      !P_COLLECT type T_COLLECT
    exceptions
      NOT_FOUND
      NON_LOCAL_FUNCTION
      NOT_RELEVANT
      NOT_IN_OBJECTSET
      RFC_UPD_FUNCTION .
  methods GET_METHOD_INFOS
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_LEVEL type I
      !P_LEVEL_EXTERN type I optional
      !P_PROC_IDS type T_PROC_IDS
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      value(P_INDEX) type I
      !P_ONLY_LOCAL type ABAP_BOOL optional
      !P_CONDITION type I optional
      !P_USE_CACHE type ABAP_BOOL optional
      !P_RESTRICT_TO_OBJECTSET type ABAP_BOOL default ABAP_FALSE
    exporting
      !P_PARAMS type T_PARAMS
      !P_PROC_ID type T_PROC_ID
    changing
      !P_COLLECT type T_COLLECT
    exceptions
      NOT_FOUND
      NON_LOCAL_METHOD
      NOT_RELEVANT
      NOT_IN_OBJECTSET .
  methods ANALYZE_PROC
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_FROM type I default 1
      !P_PROC_IDS type T_PROC_IDS optional
      value(P_LEVEL) type I default LEVEL
      !P_PARAMS type T_PARAMS optional
    changing
      !P_COLLECT type T_COLLECT .
  methods APPEND_VAR
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_VALUES type T_VALUES
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_PROGRAM type PROGRAM optional
    changing
      !P_VARS type T_VARS .
  methods MOVE_VAR
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_VALUES type T_VALUES
      !P_CONDITION type I
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_PROGRAM type P_PROGRAM optional               "obsolete
    changing
      !P_VARS type T_VARS .
  methods CHECK_VAR
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_VARS type T_VARS
      !P_EXACT type ABAP_BOOL default ABAP_FALSE
    exporting
      !P_USED_VARS type T_VARS
    returning
      value(P_VALUES) type T_VALUES .
  class-methods FIND_CLAUSE
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_WORD_1 type STRING
      !P_WORD_2 type STRING optional
      !P_WORD_3 type STRING optional
      !P_WORD_4 type STRING optional
      !P_WORD_5 type STRING optional
      !P_START_INDEX type I default 1
    returning
      value(P_TOKEN) type CL_ABAP_COMP_PROCS=>T_TOKEN .
  class-methods FIND_CLAUSE_INDEX
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_WORD_1 type STRING
      !P_WORD_2 type STRING optional
      !P_WORD_3 type STRING optional
      !P_WORD_4 type STRING optional
      !P_WORD_5 type STRING optional
      !P_START_INDEX type I default 1
    exporting
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_INDEX type I .
  methods SET_FORM_PARAMS
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_CONDITION type I
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PARAMS type T_PARAMS
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_PROGRAM type PROGRAM optional               "obsolete
    changing
      !P_VARS type T_VARS .
  methods GET_TOKEN_DATA_TYPE
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_PROGRAM type PROGRAM
    returning
      value(P_TYPE) type ref to CL_ABAP_COMP_TYPE .
  methods ANALYZE_SCREEN
    importing
      !P_PROGRAM type PROGRAM optional
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_DYNNR type SYDYNNR optional
      !P_LEVEL type I
      value(P_PROC_IDS) type T_PROC_IDS optional
      !P_WITH_STACK type ABAP_BOOL default ABAP_FALSE
    changing
      !P_COLLECT type T_COLLECT .
  methods LOAD_DYNPRO_PROC_DEFS
    importing
      !P_PROGRAM type PROGRAM
      !P_DYNNR type SYDYNNR
    raising
      CX_DYNP_SCAN_ERROR .
  methods ANALYZE_DYNPRO_FLOW
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_PROC_IDS type T_PROC_IDS optional
      !P_LEVEL type I default LEVEL
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_WITH_STACK type ABAP_BOOL default ABAP_FALSE
    changing
      !P_COLLECT type T_COLLECT .
  methods ANALYZE_DYNPRO_FIELDS
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_PROC_IDS type T_PROC_IDS
    changing
      !P_COLLECT type T_COLLECT .
  methods ANALYZE_CALL_MODULE_WITH_STACK
    importing
      !P_PROC_ID type T_PROC_ID
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      value(P_LEVEL) type I
      !P_PROC_IDS type T_PROC_IDS
      !P_STMT_IDX type I optional                       "obsolete
      !P_STMT_PROC_ID type T_PROC_ID optional       "obsolete
    changing
      !P_COLLECT type T_COLLECT .
  methods ANALYZE_CALL_MODULE
    importing
      !P_PROC_ID type T_PROC_ID optional
      !P_REF type SCR_TOKEN_REF optional
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      value(P_LEVEL) type I
      !P_PROC_IDS type T_PROC_IDS
    changing
      !P_COLLECT type T_COLLECT .
  methods SET_ENDFORM_PARAMS
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_PARAMS type T_PARAMS
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional                   "to be changed to non-optional
      !P_PROGRAM type PROGRAM optional       "obsolete
    changing
      !P_VARS type T_VARS .
  methods SET_ENDMETHOD_PARAMS
    importing
      !P_PARAMS type T_PARAMS
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional                   "to be changed to non-optional
      !P_PROGRAM type PROGRAM optional       "obsolete
    changing
      !P_VARS type T_VARS .
  methods SET_ENDFUNCTION_PARAMS
    importing
      !P_PARAMS type T_PARAMS
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional                   "to be changed to non-optional
      !P_PROGRAM type PROGRAM optional       "obsolete
    changing
      !P_VARS type T_VARS .
  methods GET_REF_CHECK
    importing
      !P_PROGRAM type PROGRAM
    returning
      value(P_REF_CHECK) type ref to CL_ABAP_COMPILER .
  methods GET_ABAP_COMPILER
    importing
      !P_PROGRAM type PROGRAM
      !P_INSERT_COMPILER type ref to CL_ABAP_COMPILER optional
      !P_NO_INSERT type ABAP_BOOL default ABAP_FALSE
    returning
      value(P_ABAP_COMPILER) type ref to CL_ABAP_COMPILER .
  methods GET_METHOD_DEFINITION
    importing
      !P_PROGRAM type PROGRAM
      !P_FULL_NAME type STRING
    exporting
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT .
  methods GET_PUBLIC_OR_TESTING_METHODS
    importing
      !P_PROGRAM type P_PROGRAM
    exporting
      !P_PROC_DEFS type CL_ABAP_COMP_PROCS=>T_PROCS .
  methods ADD_METHOD
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
    changing
      !P_PROC_DEFS type CL_ABAP_COMP_PROCS=>T_PROCS .
  methods FIND_PATTERN
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_WORD_1 type STRING
      !P_WORD_2 type STRING optional
      !P_WORD_3 type STRING optional
      !P_WORD_4 type STRING optional
    returning
      value(P_RESULT) type ABAP_BOOL .
  methods GET_METHOD_CLASS
    importing
      !P_FULL_NAME type STRING
    returning
      value(P_FULL_NAME_CLASS) type STRING .
  methods ADD_INFO
    importing
      !P_INCLUDE type PROGRAM optional
      !P_LINE type I optional
      !P_COLUMN type I optional
      !P_KIND type SCI_ERRC
      !P_SOURCE type CSEQUENCE optional
      !P_NAME type CSEQUENCE optional
      !P_STACK type T_STACK_ENTRIES optional
      !P_STACK_OF_VAR type T_STACK_ENTRIES optional
      !P_PROC_POS type SCIS_PROC_POS optional
      !P_NO_MOVES type SCI_NO_MOVES optional
      !P_INFO1 type CSEQUENCE optional
      !P_INFO2 type CSEQUENCE optional
      !P_INFO3 type CSEQUENCE optional
      !P_INFO4 type CSEQUENCE optional
      !P_COMMENTS type CL_ABAP_COMP_PROCS=>T_COMMENTS optional
      !P_PROGRAM type PROGRAM optional
      !P_CHECKSUM type SCI_CRC64 optional
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_STMT_SUPPLIED type ABAP_BOOL default ABAP_TRUE .
  methods DELETE_VAR
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
    changing
      !P_VARS type T_VARS .
  methods END_OF_TOP_PROC
    importing
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
    changing
      !P_COLLECT type T_COLLECT .
  methods GET_CALL_CHECKSUM
    importing
      !P_PARAMS type T_PARAMS
      !P_VARS type T_VARS
      !P_IN_LOOP type ABAP_BOOL
    returning
      value(P_RESULT) type SCR_CRC64 .
  methods DETERMINE_OBJLST
    exceptions
      INSPECTION_DOES_NOT_EXIST .
  methods LOAD_OBJLST
    exceptions
      INSPECTION_DOES_NOT_EXIST .
  methods IS_IN_OBJLST
    importing
      !P_PROGRAM type PROGRAM
    returning
      value(P_IS_IN_OBJLST) type ABAP_BOOL .
  class-methods CRC64
    importing
      !P_INPUT type ANY
      !P_LENGTH type I
    changing
      !P_CRC_VALUE type SCR_CRC64
    exceptions
      PARAMETER_ERROR .
  class-methods CRC64_CLIKE
    importing
      !P_INPUT type CLIKE
    changing
      !P_CRC_VALUE type SCR_CRC64
    exceptions
      PARAMETER_ERROR .
  class-methods GET_SOURCE_NAME
    importing
      !P_INCLUDE type PROGRAM
    returning
      value(P_TEXT) type STRING .
  class-methods INTERSECTION
    importing
      !P_VARS type T_VARS
      !P_USED_VARS type T_SORTED_FULL_NAMES
    returning
      value(P_INTERSECTION) type T_VARS .
  methods REMOVE_PARAMS
    importing
      !P_PARAMS type T_PARAMS
    changing
      !P_VARS type T_VARS .
  class-methods FIND_CLAUSE_PRE
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_WORD_1 type STRING
      !P_WORD_2 type STRING optional
      !P_WORD_3 type STRING optional
      !P_WORD_4 type STRING optional
      !P_WORD_5 type STRING optional
      !P_START_INDEX type I default 1
    returning
      value(P_TOKEN) type CL_ABAP_COMP_PROCS=>T_TOKEN .
  methods GET_PROC_OP_LINE
    importing
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_LINE type I optional
    returning
      value(P_OP_LINE) type I .
  methods CHECK_DB_TABLE_FOR_PARAMS
    importing
      !P_PROGRAM type PROGRAM
      !P_TABNAME type TABNAME
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_TABLES type SCIT_TABL
      !P_BUFF type SYCHAR01
      !P_TABKAT type I
      !P_INFORM type ABAP_BOOL default ABAP_TRUE
    returning
      value(P_RESULT) type ABAP_BOOL .
  methods CHECK_DB_TABLE
    importing
      !P_PROGRAM type PROGRAM
      !P_TABNAME type TABNAME
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT optional
      !P_TOKEN_IDX type I optional
      !P_READ_OP type ABAP_BOOL default ABAP_TRUE
      !P_INFORM type ABAP_BOOL default ABAP_TRUE
    returning
      value(P_RESULT) type ABAP_BOOL .
  methods GET_DBTAB_NAME_FROM_TOKEN
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_PROGRAM type P_PROGRAM
      !P_DYN_POSSIBLE type ABAP_BOOL default ABAP_TRUE
      !P_CHECK type ABAP_BOOL default ABAP_TRUE
    returning
      value(P_TABNAME) type TABNAME .
  methods GET_TARGET
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_SHORT_FORM_ALLOWED type ABAP_BOOL
      !P_NEXT type STRING optional
      !P_NEXT_OR type T_STRING_TAB optional
    exporting
      !P_TOKEN_DB type CL_ABAP_COMP_PROCS=>T_TOKEN
    changing
      !P_TOKEN_IDX type I .
  methods GET_DBTAB_NAME_FROM_STMT
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROGRAM type PROGRAM
      !P_DYN_POSSIBLE type ABAP_BOOL default ABAP_TRUE
      !P_NO_CHECK type ABAP_BOOL default ABAP_FALSE
      !P_FORCE_CHECK type ABAP_BOOL default ABAP_FALSE
    exporting
      value(P_TABNAME) type TABNAME
      !P_CURSOR_INDEX type I
      !P_OKAY type ABAP_BOOL
      !P_TOKEN_IDX type I .
  methods END_OF_PROC
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional
    changing
      !P_COLLECT type T_COLLECT .
  methods CHECK_VAR_EXT
    importing
      !P_TOKEN type CL_ABAP_COMP_PROCS=>T_TOKEN
      !P_COLLECT type T_COLLECT
      !P_PATTERN type STRING default '*'
    returning
      value(P_VALUES) type T_VALUES .
  methods GET_VARS
    importing
      !P_FULL_NAME type STRING
      !P_COLLECT type T_COLLECT
    returning
      value(P_FULL_NAMES) type T_FULL_NAMES .
  methods SET_FORM_PARAMS_EXT
    importing
      !P_TOKENS type CL_ABAP_COMP_PROCS=>T_TOKENS
      !P_CONDITION type I
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_PARAMS type T_PARAMS
      !P_PROC type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY optional                           "to be changed to non-optional
      !P_PROGRAM type PROGRAM optional               "to be deleted
    changing
      !P_COLLECT type T_COLLECT .
  class-methods IS_TOKEN
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
      !P_INDEX type I
      !P_EXPECTED type CLIKE
    returning
      value(P_IS_TOKEN) type ABAP_BOOL .
  methods IMPORT_PROG_INFOS
    importing
      !P_PROGRAM type PROGRAM .
  methods GET_ALIAS_METHOD
    importing
      !P_PROGRAM type PROGRAM
      !P_FULL_NAME type STRING
    exporting
      !P_ALIAS_FULL_NAME type STRING .
  methods COMPARE_STACKS
    importing
      !P_STACK_1 type T_STACK_ENTRIES
      !P_STACK_2 type T_STACK_ENTRIES
    exporting
      !P_INDEX type I .
  methods JOIN_VARS
    importing
      !P_VARS type T_VARS
    changing
      !P_COLLECT type T_COLLECT .
  methods GET_ALIAS_DATA
    importing
      !P_PROGRAM type PROGRAM
      !P_FULL_NAME type STRING
    exporting
      !P_ALIAS_FULL_NAME type STRING .
  methods PREPARE_CALLS
    importing
      !P_PROCS type CL_ABAP_COMP_PROCS=>T_PROCS .
  methods GET_PROC_CALLED_PROGRAMS
    importing
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
    changing
      !P_PROGRAMS type SCIT_PROGRAM_HASH .
  methods IS_PERFORM_IF_FOUND
    importing
      !P_STMT type CL_ABAP_COMP_PROCS=>T_STMT
    returning
      value(P_RESULT) type SYCHAR01 .
  methods GET_STMT_CHECKSUM
    importing
      !P_PROC_DEF type CL_ABAP_COMP_PROCS=>T_PROC_ENTRY
      !P_INDEX_STMT type I
      !P_STMT_RANGE type I default 2
    changing
      value(P_CHECKSUM) type SCI_CRC64 .
  methods LINKS_TO_WB_NAVIGATION
    importing
      !P_LINKS type SCIT_SOURCE_LINK
    exporting
      !P_WB_NAVIGATIONS type SCIT_WB_NAVIGATION .
  METHODS is_stmt_sequence_possible
    IMPORTING
      !p_first        TYPE t_stack_entries
      !p_second       TYPE t_stack_entries
    RETURNING
      VALUE(p_result) TYPE abap_bool .

  methods GET_LOCAL_CHECKSUM
    redefinition .
  methods INFORM
    redefinition .
private section.
ENDCLASS.



CLASS CL_CI_TEST_ABAP_COMP_PROCS IMPLEMENTATION.
ENDCLASS.