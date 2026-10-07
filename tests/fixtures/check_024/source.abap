CLASS zcl_skylint_test_024 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
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

  METHOD test_003.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    DATA lv_flag2 TYPE abap_bool.
    IF lv_c = lv_d.
    lv_flag2 = abap_false.
    ELSE.
    lv_flag2 = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_x TYPE i.
    IF lv_a = lv_b.
    lv_x = 1.
    ELSE.
    lv_x = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    DATA space TYPE string.
    IF lv_a = lv_b.
    lv_flag = space.
    ELSE.
    lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

