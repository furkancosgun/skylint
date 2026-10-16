CLASS zcl_test_no_empty_block DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_no_empty_block IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x = 1.
    lv_x = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    DATA lv_n TYPE i.
    LOOP AT lt_tab INTO ls_row.
      lv_n = lv_n + 1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

