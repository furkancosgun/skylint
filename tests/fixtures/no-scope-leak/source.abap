CLASS zcl_skylint_test_033 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_skylint_test_033 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
    DATA lv_inner TYPE i.
    ENDIF.
    lv_inner = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    DATA lv_x TYPE i.
    LOOP AT lt_tab INTO lv_x.
      DATA lv_inner2 TYPE i.
    ENDLOOP.
    lv_inner2 = 1.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
      DATA lv_tmp TYPE i.
      lv_tmp = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
      DATA(lv_inline) = 1.
    ENDIF.
    lv_inline = 2.
  ENDMETHOD.
ENDCLASS.

