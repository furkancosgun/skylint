CLASS cx_ci_atc_check_invalid_attr DEFINITION
  PUBLIC
  INHERITING FROM cx_ci_atc
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.

  METHODS constructor
    IMPORTING
      !textid LIKE if_t100_message=>t100key OPTIONAL
      !previous LIKE previous OPTIONAL .
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS CX_CI_ATC_CHECK_INVALID_ATTR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
CALL METHOD super->constructor
EXPORTING
previous = previous
.
CLEAR me->textid.
IF textid IS INITIAL.
  if_t100_message~t100key = if_t100_message=>default_textid.
ELSE.
  if_t100_message~t100key = textid.
ENDIF.
  ENDMETHOD.
ENDCLASS.