CLASS zcl_skylint_test_nested_loop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_nested_loop IMPLEMENTATION.
  METHOD test_001.
    DATA lt_a TYPE string_table.
    DATA lt_b TYPE string_table.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    LOOP AT lt_a INTO lv_a.
      LOOP AT lt_b INTO lv_b.
        CLEAR lv_b.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_a TYPE string_table.
    DATA lt_b TYPE string_table.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_from TYPE i VALUE 1.
    LOOP AT lt_a INTO lv_a.
      LOOP AT lt_b INTO lv_b FROM lv_from.
        CLEAR lv_b.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_a TYPE string_table.
    DATA lv_a TYPE string.
    DATA lv_mem TYPE string.
    LOOP AT lt_a INTO lv_a GROUP BY ( key = lv_a ).
      LOOP AT GROUP lv_a INTO lv_mem.
        CLEAR lv_mem.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_a TYPE string_table.
    DATA lt_b TYPE string_table.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    LOOP AT lt_a INTO lv_a.
      CLEAR lv_a.
    ENDLOOP.
    LOOP AT lt_b INTO lv_b.
      CLEAR lv_b.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_a TYPE string_table.
    DATA lv_a TYPE string.
    LOOP AT lt_a INTO lv_a.
      DO 5 TIMES.
        CLEAR lv_a.
      ENDDO.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
