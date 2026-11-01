CLASS zcl_skylint_test_strict_sql DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
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
ENDCLASS.
