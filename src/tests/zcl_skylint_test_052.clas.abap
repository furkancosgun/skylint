CLASS zcl_skylint_test_052 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_052 IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      AT NEW table_line.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      CONTINUE.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      AT END table_line.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DO 1 TIMES.
    ENDDO.
  ENDMETHOD.
ENDCLASS.