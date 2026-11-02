CLASS zcl_test_pref_sort_key DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             field1 TYPE string,
             field2 TYPE i,
           END OF ty_row.
    DATA lt_data TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_pref_sort_key IMPLEMENTATION.

  METHOD test_001.
    SORT lt_data.
  ENDMETHOD.

  METHOD test_002.
    SORT lt_data BY field1.
  ENDMETHOD.

  METHOD test_003.
    SORT lt_data DESCENDING.
  ENDMETHOD.

  METHOD test_004.
    SORT lt_data BY field2 ASCENDING.
  ENDMETHOD.

  METHOD test_005.
    SORT lt_data. "#EC PREF_SORT_KEY
  ENDMETHOD.

ENDCLASS.
