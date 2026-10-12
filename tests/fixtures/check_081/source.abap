CLASS zcl_skylint_test_081 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_081 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i.
    IF lv_val = 1.
      lv_val = 10.
    ELSEIF lv_val = 2.
      lv_val = 20.
    ELSEIF lv_val = 3.
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      lv_a = 10.
    ELSEIF lv_b = 2.
      lv_b = 20.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
