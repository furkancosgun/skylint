CLASS zcl_skylint_test_empty_ovr DEFINITION.
  PUBLIC SECTION.
    METHODS bad_001.
    METHODS good_001.
ENDCLASS.
CLASS zcl_skylint_test_empty_ovr IMPLEMENTATION.
  METHOD bad_001.
    super->bad_001( ).
  ENDMETHOD.
  METHOD good_001.
    super->good_001( ).
    do_something( ).
  ENDMETHOD.
ENDCLASS.
