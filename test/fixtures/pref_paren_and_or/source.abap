CLASS zcl_test_pref_paren_and_or DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_pref_paren_and_or IMPLEMENTATION.
  METHOD test_001.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA c TYPE i.
    IF a = 1 AND b = 2 OR c = 3.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA c TYPE i.
    WHILE a = 1 OR b = 2 AND c = 3.
      RETURN.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_003.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA c TYPE i.
    IF ( a = 1 AND b = 2 ) OR c = 3.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA val TYPE i.
    DATA c TYPE i.
    IF val BETWEEN 1 AND 10 OR c = 3.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA c TYPE i.
    IF a = 1 AND b = 2 OR c = 3 ##PREF_PAREN_AND_OR. "#EC PREF_PAREN_AND_OR
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
