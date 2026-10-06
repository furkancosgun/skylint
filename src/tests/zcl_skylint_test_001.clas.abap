CLASS zcl_skylint_test_001 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_001 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_cnt TYPE i.
    DATA lt_tab TYPE string_table.
    DESCRIBE TABLE lt_tab LINES lv_cnt.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_cnt TYPE i.
    DATA lt_tab TYPE string_table.
    lv_cnt = lines( lt_tab ).
  ENDMETHOD.

  METHOD test_003.
    DATA lv_lines TYPE i.
    DATA lt_items TYPE string_table.
    DESCRIBE TABLE lt_items LINES lv_lines.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    DATA lv_cnt TYPE i.
    IF lines( lt_tab ) > 0.
      lv_cnt = lines( lt_tab ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

