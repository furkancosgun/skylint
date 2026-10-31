CLASS lcl_test DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             field1 TYPE string,
             field2 TYPE i,
           END OF ty_row,
           ty_table TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
ENDCLASS.

CLASS lcl_test IMPLEMENTATION.
  METHOD test_001.
    DATA lt_table TYPE ty_table.
    SORT lt_table BY field1 field2.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_table TYPE ty_table.
    SORT lt_table BY field1 ASCENDING field2 DESCENDING.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_table TYPE ty_table.
    SORT lt_table ASCENDING BY field1 field2.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_table TYPE ty_table.
    SORT lt_table DESCENDING BY field1 field2.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_table TYPE ty_table.
    SORT lt_table BY field1.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_table TYPE ty_table.
    SORT lt_table BY field1 AS TEXT ASCENDING field2 DESCENDING.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_table TYPE ty_table.
    SORT lt_table BY field1 AS TEXT field2 DESCENDING.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_table TYPE ty_table.
    DATA lv_field TYPE string VALUE 'FIELD1'.
    SORT lt_table BY (lv_field).
  ENDMETHOD.

  METHOD test_009.
    DATA lt_table TYPE ty_table.
    SORT lt_table BY field1 field2. "#EC PREF_SORT_ORDER
  ENDMETHOD.

  METHOD test_010.
    DATA lt_table TYPE ty_table.
    SORT lt_table.
  ENDMETHOD.
ENDCLASS.
