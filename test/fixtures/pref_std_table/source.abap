CLASS zcl_test_prefer_standard_table DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_prefer_standard_table IMPLEMENTATION.
  METHOD test_001.
    DATA lt_rows TYPE TABLE OF mara.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_rows TYPE STANDARD TABLE OF mara.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_rows TYPE SORTED TABLE OF mara WITH UNIQUE KEY matnr.
  ENDMETHOD.

  METHOD test_004.
    TYPES ty_rows TYPE TABLE OF mara.
  ENDMETHOD.
ENDCLASS.
