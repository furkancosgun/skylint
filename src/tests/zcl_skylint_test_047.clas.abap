CLASS zcl_skylint_test_047 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_047 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    DATA lv_e TYPE i.
    IF lv_a = 1.
    ENDIF.
    IF lv_b = 2.
    ENDIF.
    IF lv_c = 3.
    ENDIF.
    IF lv_d = 4.
    ENDIF.
    IF lv_e = 5.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    IF lv_a = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

