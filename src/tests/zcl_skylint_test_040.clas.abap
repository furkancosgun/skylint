CLASS zcl_skylint_test_040 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_040 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a = 1.
    IF lv_b = 2.
    IF lv_c = 3.
    IF lv_d = 4.
    ENDIF.
    ENDIF.
    ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
    IF lv_b = 2.
    ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

