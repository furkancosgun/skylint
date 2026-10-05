CLASS zcl_skylint_test_073 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_073 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    lv_x = lv_x + 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 10.
  ENDMETHOD.
ENDCLASS.

