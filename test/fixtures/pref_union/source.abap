CLASS zcl_skylint_test_union DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_union IMPLEMENTATION.
  METHOD test_001.
    DATA lt_data TYPE string_table.
    SELECT a FROM ztab1
      UNION ALL
      SELECT a FROM ztab2
      INTO TABLE @lt_data.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_data TYPE string_table.
    SELECT a FROM ztab1
      UNION
      SELECT a FROM ztab2
      INTO TABLE @lt_data.
  ENDMETHOD.
ENDCLASS.
