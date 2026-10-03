class CL_ABAP_COMP_PROCS definition
  public
  create public .

public section.

  types:
    T_AST_ENTRIES type standard table of SCR_ABAP_AST .
  types:
    begin of T_PROC_ID,
        PROGRAM   type PROGRAM,
        PROC_TYPE type SYCHAR04,
        PROC_NAME type STRING,
      end of   T_PROC_ID .
  types:
    begin of T_TOKEN,
        STR    type STRING,
        REFS   type SCR_TOKEN_REFS,
        LINE   type I,
        COLUMN type I,
      end   of T_TOKEN .
  types:
    T_TOKENS type standard table of T_TOKEN with non-unique default key .
  types:
    T_COMMENTS type hashed table of STRING with unique key TABLE_LINE .
  types:
    begin of T_BLOCK,
        TYPE       type STRU_TYPE,
        STMNT_TYPE type STRU_TYPE,
        STMNT_FROM type I,
        STMNT_TO   type I,
        BLOCK_FROM type I,
        BLOCK_TO   type I,
        BACK       type I,
      end of T_BLOCK .
  types:
    T_BLOCKS type standard table of T_BLOCK with non-unique default key .
  types:
    begin of T_STMT,
        KEYWORD       type STRING,
        TOKENS        type T_TOKENS,
        COMMENTS      type T_COMMENTS,
        INCLUDE       type PROGRAM,
        LINE          type I,
        COLUMN        type I,
        NON_BUF_DB_OP type ABAP_BOOL,
        IDX           type I,
        LINKS_ORIGINS type sorted table of I with unique key TABLE_LINE,
        LINK_BLOCKS   type I,
      end   of T_STMT .
  types:
    T_STMTS type standard table of T_STMT with non-unique default key .
  types:
    begin of T_STMT_OLD,
        KEYWORD       type STRING,
        TOKENS        type T_TOKENS,
        COMMENTS      type T_COMMENTS,
        INCLUDE       type PROGRAM,
        LINE          type I,
        COLUMN        type I,
        NON_BUF_DB_OP type ABAP_BOOL,
      end   of T_STMT_OLD .
  types:
    T_STMTS_OLD type standard table of T_STMT_OLD with non-unique default key .
  types T_ORIGINS type CL_CI_SCAN=>T_ORIGIN_TAB .
  types:
    begin of T_PROC_ENTRY,
        PROC_ID       type T_PROC_ID,
        KIND          type SYCHAR01,
        INCLUDE       type PROGRAM,
        FIRST_OP_STMT type I,
        STMTS         type T_STMTS,
        BLOCKS        type T_BLOCKS,
        ORIGINS       type T_ORIGINS,
        CONTENT       type XSTRING,
      end   of T_PROC_ENTRY .
  types:
    T_PROCS type sorted table of T_PROC_ENTRY with non-unique key PROC_ID-PROGRAM PROC_ID-PROC_TYPE PROC_ID-PROC_NAME .
  types:
    begin of T_PROC_ENTRY_OLD,
        PROC_ID       type T_PROC_ID,
        KIND          type SYCHAR01,
        INCLUDE       type PROGRAM,
        FIRST_OP_STMT type I,
        STMTS         type T_STMTS_OLD,
        CONTENT       type XSTRING,
      end   of T_PROC_ENTRY_OLD .
  types:
    T_PROCS_OLD type sorted table of T_PROC_ENTRY_OLD with non-unique key PROC_ID-PROGRAM PROC_ID-PROC_TYPE PROC_ID-PROC_NAME .
  types:
    begin of T_COMMON,
        FULL_NAME_LOCAL type STRING,
        FULL_NAME       type STRING,
      end   of T_COMMON .
  types T_SYMBOL type CL_ABAP_SYMBOL=>T_SYMBOL_DB .
  types T_SYMBOLS type CL_ABAP_SYMBOL=>T_SYMBOLS_DB .
  types:
    T_SYMBOL_NAMES type hashed table of STRING with unique key TABLE_LINE .
  types:
    begin of T_SCAN_RESULT,
        SUBRC          type SY-SUBRC,
        MESSAGE        type SYCHAR200,
        LINE           type INT4,
        WORD           type SYCHAR30,
        INCLUDE        type PROGRAM,
        TOKENS         type STOKESX_TAB,
        STATEMENTS     type SSTMNT_TAB,
        LEVELS         type SLEVEL_TAB,
        STRUCTURES     type SSTRUC_TAB,
        STMNT_2_ORIGIN type CL_CI_SCAN=>T_STMNT_2_ORIGIN_TAB,
        ORIGINS        type CL_CI_SCAN=>T_ORIGIN_TAB,
      end of T_SCAN_RESULT .

  data:
    COMMONS type hashed table of T_COMMON with unique key FULL_NAME_LOCAL .
  data PROCS type T_PROCS read-only .
  data SYMBOLS type T_SYMBOLS read-only .
  data ORIGINS type T_ORIGINS .
  constants C_VERSION type I value 120 ##NO_TEXT.
  class-data DATA_VERSION type I read-only .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR
    importing
      !P_REF_SCAN type ref to CL_CI_SCAN
      !P_REF_COMP type ref to CL_ABAP_COMPILER
      !P_PROGRAM type PROGRAM
      !P_SUBC type TRDIR-SUBC
    exceptions
      SYNTAX_ERROR .
  class-methods GET_PROC_DEFS
    importing
      !P_SRCID type SCR_SOURCE_ID optional
      !P_NEEDED_REMOTE_VERSION type I optional
      !P_PROGRAM type PROGRAM
      !P_NO_CACHE type SYCHAR01 optional
      !P_UNPACK type SYCHAR01 default 'X'
      !P_PREPARE type SYCHAR01 optional
      !P_SYMB_REF type ref to CL_ABAP_SYMBOL optional
      value(P_REF_CHECK) type ref to CL_ABAP_COMPILER optional
      !P_NO_PROGRESS_INDICATOR type SYCHAR01 optional
    exporting
      !P_PROC_DEFS type T_PROCS
      !P_SCAN_RESULT type T_SCAN_RESULT
      !P_SYMBOLS type T_SYMBOLS
      !P_CHECKSUM type SCR_CRC64
      !P_NEW_REF_CHECK type ref to CL_ABAP_COMPILER
      !P_SDATE type TRDIR-SDATE
      !P_STIME type TRDIR-STIME
      !P_TIME type I
      !P_SRC_SCP_ENABLED type ABAP_BOOL
      !P_CHARSIZE type I
    exceptions
      PROGRAM_FATAL_SYNTAX_ERROR
      INVALID_CHECKSUM
      DATA_NOT_FOUND
      REMOTE_COMP_PROCS_NOT_FOUND
      REMOTE_COMP_PROCS_WRG_VERSION
      REMOTE_SYMBOLS_NOT_FOUND
      REMOTE_SYMBOLS_WRONG_VERSION
      REMOTE_SCAN_NOT_FOUND
      REMOTE_SCAN_WRONG_VERSION
      REMOTE_MISSING_INITIALIZATION .
  class-methods MODIFY_AST_ENTRY
    importing
      !P_ENTRY type SCR_ABAP_AST .
  class-methods MODIFY_AST_ENTRIES
    importing
      !P_ENTRIES type T_AST_ENTRIES .
  class-methods SET_TOUCH
    importing
      !P_SRCID type SCR_SOURCE_ID optional
      !P_PROGRAM type PROGRAM .
  class-methods UNPACK_PROC_DEFS
    changing
      !P_PROC_DEFS type T_PROCS .
  class-methods UNPACK_PROC_DEF
    exporting
      !P_STMTS type T_STMTS
    changing
      !P_CONTENT type XSTRING .
  methods TEST_FULL_NAME
    importing
      !P_FULL_NAME type STRING
    exporting
      !P_CORRECT_FULL_NAME type STRING
    returning
      value(P_RESULT) type ABAP_BOOL
    exceptions
      PROGRAM_FATAL_SYNTAX_ERROR .
  class-methods GET_INSTANCE
    importing
      !P_PROGRAM type PROGRAM
      value(P_ABAP_COMPILER) type ref to CL_ABAP_COMPILER optional
    exporting
      value(P_ABAP_COMP_PROCS) type ref to CL_ABAP_COMP_PROCS
    exceptions
      PROGRAM_FATAL_SYNTAX_ERROR .
  class-methods CLEAN_DB_ENTRIES .
  class-methods IMPORT_PROC_DEFS
    importing
      !P_CONTENT type SCR_ABAP_AST-CONTENT
    exporting
      !P_PROC_DEFS type T_PROCS
      !P_CHECKSUM type SCR_CRC64
      !P_SRC_SCP_ENABLED type ABAP_BOOL
      !P_CHARSIZE type I .
  class-methods CLEAR .
  protected section.

    data REF_SCAN type ref to CL_CI_SCAN .
    data FIRST_TOKEN_LINE type I .
    data FIRST_TOKEN_COL type I .
    data LAST_TOKEN_LINE type I .
    data LAST_TOKEN_COL type I .
    data START_OF_SELECTION type ABAP_BOOL .
    data REF_COMP type ref to CL_ABAP_COMPILER .
    methods SCAN_PROGRAM .
    methods SCAN_PROCEDURE
      importing
        !P_PROC_TYPE type SYCHAR04
        !P_PROC_NAME type STRING .
    ENDCLASS.

    CLASS cl_ci_test_abap_comp_procs DEFINITION PUBLIC INHERITING FROM cl_ci_test_root ABSTRACT.
      PUBLIC SECTION.
        METHODS analyze_proc
          IMPORTING
            !p_proc TYPE cl_abap_comp_procs=>t_proc_entry OPTIONAL.
    ENDCLASS.

    CLASS cl_ci_test_abap_comp_procs IMPLEMENTATION.
      METHOD analyze_proc.
        RETURN.
      ENDMETHOD.
    ENDCLASS.