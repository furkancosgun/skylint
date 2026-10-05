CLASS zcl_skylint_test_016 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_016 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 1.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 2.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

