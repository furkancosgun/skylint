CLASS zcl_skylint_test_double_space DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_double_space IMPLEMENTATION.
  METHOD test_001.
    DATA  lv_a TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a
      TYPE i.
  ENDMETHOD.
ENDCLASS.
