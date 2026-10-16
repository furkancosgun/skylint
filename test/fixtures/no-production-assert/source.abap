CLASS zcl_test_no_production_assert DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_no_production_assert IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    ASSERT lv_x > 0.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_flag TYPE abap_bool.
    ASSERT lv_flag = abap_true.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_num TYPE i.
    lv_num = 1.
  ENDMETHOD.
ENDCLASS.

