CLASS zcl_skylint_test_012 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_012 IMPLEMENTATION.
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
ENDCLASS.

