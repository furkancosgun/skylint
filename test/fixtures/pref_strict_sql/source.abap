CLASS zcl_skylint_test_strict_sql DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_skylint_test_strict_sql IMPLEMENTATION.
  METHOD test_001.
    DATA lt_data TYPE STANDARD TABLE OF tadir.
    SELECT * FROM tadir INTO TABLE lt_data.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_data TYPE STANDARD TABLE OF tadir.
    SELECT * FROM tadir INTO TABLE @lt_data.
  ENDMETHOD.

  METHOD test_003.
    DATA ls_row TYPE tadir.
    SELECT SINGLE * FROM tadir INTO ls_row.
  ENDMETHOD.

  METHOD test_004.
    DATA ls_row TYPE tadir.
    SELECT SINGLE * FROM tadir INTO @ls_row.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_data TYPE STANDARD TABLE OF tadir.
    SELECT * FROM tadir APPENDING TABLE lt_data.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_data TYPE STANDARD TABLE OF tadir.
    SELECT * FROM tadir APPENDING TABLE @lt_data.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE c LENGTH 4.
    DATA lv_b TYPE c LENGTH 4.
    SELECT SINGLE pgmid object FROM tadir INTO ( lv_a, lv_b ).
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE c LENGTH 4.
    DATA lv_b TYPE c LENGTH 4.
    SELECT SINGLE pgmid, object FROM tadir INTO ( @lv_a, @lv_b ).
  ENDMETHOD.
ENDCLASS.
