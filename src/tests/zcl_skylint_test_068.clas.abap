CLASS zcl_skylint_test_068 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_row,
        field1 TYPE i,
      END OF ty_row.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_068 IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab FROM ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab FROM ls_row TRANSPORTING field1.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab INDEX 1 FROM ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    MODIFY lt_tab FROM ls_row.
  ENDMETHOD.
ENDCLASS.
