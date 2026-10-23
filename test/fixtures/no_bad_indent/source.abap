CLASS zcl_skylint_test_bad_indent DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_bad_indent IMPLEMENTATION.
  METHOD test_001.
  DATA lv_a TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
