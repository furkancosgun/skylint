class CL_CI_TEST_ABAP_COMPILER definition
  public
  inheriting from CL_CI_TEST_PROGRAM
  create public .

  public section.

*"* public components of class CL_CI_TEST_ABAP_COMPILER
*"* do not include other source files here!!!
    methods CONSTRUCTOR .

    methods CLEAR
        redefinition .
    methods GET_RESULT_NODE
        redefinition .
    methods RUN_BEGIN
        redefinition .
    methods VERIFY_TEST
        redefinition .
protected section.

*"* protected components of class CL_CI_TEST_ABAP_COMPILER
*"* do not include other source files here!!!
  class-data REF_INCLUDE type ref to CL_CI_SOURCE_INCLUDE .
  class-data REF_SCAN type ref to CL_CI_SCAN .
  data NEED_WARNINGS type SYCHAR01 .
  data NEED_INFOS type SYCHAR01 .
  data NEED_COMMENTS type SYCHAR01 .
  class-data REF_CHECK type ref to CL_ABAP_COMPILER .
  class-data TAB_INFOS type RSYNTMSGS .
  class-data TAB_LONGTEXT type RSLINLTAB .
  class-data INFOS_LOADED type ABAP_BOOL .

  methods GET_CODE
    importing
      !P_KEYWORD type TRMSG_KEYW
      !P_MSGNUMBER type TRMSG_NUM3
    returning
      value(P_CODE) type SCI_ERRC .
  methods GET_LONG_TEXT
    importing
      !P_LONG_TEXTS type RSLINLTAB
      !P_KIND type SYCHAR01
      !P_NUMBER type I
    returning
      value(P_RESULT) type XSTRING .
  methods GET_INFO_LONGTEXT
    exporting
      !P_INFOS type SYNT_ERRORS
      !P_LONGTEXT type RSLINLTAB .
  methods CHECK_SCOPE
    importing
      !P_REF_SCAN type ref to CL_CI_SCAN
      !P_POSITION type I
    returning
      value(P_RESULT) type ABAP_BOOL .
  methods RAISE_COMP_MESSAGE
    importing
      !P_TEST type SCI_CHK
      !P_CODE type SCI_ERRC
      !P_MSG_INDEX type I
      !P_LONGTEXTS type RSLINLTAB
      !P_MESSAGE type RSLINLMSG
      !P_DEFAULT_KIND type SCI_ERRTY .

  methods GET
    redefinition .
  methods INFORM
    redefinition .
ENDCLASS.



CLASS CL_CI_TEST_ABAP_COMPILER IMPLEMENTATION.
ENDCLASS.