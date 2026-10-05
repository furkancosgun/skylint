CLASS zcl_skylint_test_024 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_024 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF lv_a = lv_b.
    lv_flag = abap_true.
    ELSE.
    lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    IF lv_a = lv_b.
    lv_x = abap_true.
    ELSE.
    lv_y = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

