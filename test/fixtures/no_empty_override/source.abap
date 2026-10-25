CLASS zcl_skylint_test_empty_ovr DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001.
    METHODS bad_002.
    METHODS bad_003.
    METHODS good_001.
ENDCLASS.
CLASS zcl_skylint_test_empty_ovr IMPLEMENTATION.
  METHOD bad_001.
    super->bad_001( ).
  ENDMETHOD.
  METHOD bad_002.
    super->bad_002( ).
    RETURN.
  ENDMETHOD.
  METHOD bad_003.
    CHECK 1 = 1.
    super->bad_003( ).
    EXIT.
  ENDMETHOD.
  METHOD good_001.
    super->good_001( ).
    do_something( ).
  ENDMETHOD.
ENDCLASS.
