CLASS zcl_skylint_test_018 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_018 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    RETURN.
    lv_x = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 1.
    RETURN.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      EXIT.
      ls_row = 'x'.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      RETURN.
    ENDIF.
    lv_x = 2.
  ENDMETHOD.
ENDCLASS.

