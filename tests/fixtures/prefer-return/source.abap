CLASS zcl_test_prefer_return DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_prefer_return IMPLEMENTATION.
  METHOD test_001.
    EXIT.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
    EXIT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      EXIT.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DO 5 TIMES.
      EXIT.
    ENDDO.
  ENDMETHOD.
ENDCLASS.

