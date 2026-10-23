CLASS zcl_test_prefer_early_return DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_row,
        flag TYPE abap_bool,
      END OF ty_row.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_test_prefer_early_return IMPLEMENTATION.
  METHOD test_001.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_flag = abap_true.
    ls_val = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_flag = abap_true.
    ls_val = 1.
    ELSE.
    ls_val = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_other TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_other = abap_false.
      ls_val = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    ls_val = 0.
    IF lv_flag = abap_true.
      ls_val = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    DATA ls_val TYPE i.
    LOOP AT lt_tab INTO ls_row.
      IF ls_row-flag = abap_true.
        ls_val = 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    DATA ls_val TYPE i.
    LOOP AT lt_tab INTO ls_row.
      ls_val = 1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
