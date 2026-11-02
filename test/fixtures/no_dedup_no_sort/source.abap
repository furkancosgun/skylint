CLASS zcl_skylint_test_dedup_sort DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_dedup_sort IMPLEMENTATION.
  METHOD test_001.
    DATA lt_data TYPE string_table.
    DELETE ADJACENT DUPLICATES FROM lt_data.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_data TYPE string_table.
    SORT lt_data.
    DELETE ADJACENT DUPLICATES FROM lt_data.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_data TYPE string_table.
    DATA lt_other TYPE string_table.
    SORT lt_other.
    DELETE ADJACENT DUPLICATES FROM lt_data.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_data TYPE string_table.
    DELETE ADJACENT DUPLICATES FROM lt_data. "#EC NO_DEDUP_NO_SORT
  ENDMETHOD.
ENDCLASS.
