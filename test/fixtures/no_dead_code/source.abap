CLASS zcl_skylint_test_no_dead_code DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_no_dead_code IMPLEMENTATION.
  METHOD test_001.
    IF 1 = 2.
      DATA lv_a TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_b TYPE i.
    IF lv_b = 2.
      lv_b = 3.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
