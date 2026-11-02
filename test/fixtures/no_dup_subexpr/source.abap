CLASS zcl_skylint_test_dup_subexpr DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_dup_subexpr IMPLEMENTATION.
  METHOD test_001.
    DATA a TYPE i.
    IF a = 1 AND a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA a TYPE i.
    DATA b TYPE i.
    IF a = 1 AND b = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA a TYPE i.
    IF ( a > 1 ) OR ( a > 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA a TYPE i.
    DATA b TYPE i.
    IF ( a = 1 ) AND ( b = 2 ) AND ( a = 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA a TYPE i.
    IF a = 1 AND a = 1. "#EC NO_DUP_SUBEXPR
    ENDIF.
  ENDMETHOD.
ENDCLASS.
