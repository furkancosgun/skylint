CLASS zcl_skylint_test_018 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_018 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    RETURN.
    lv_x = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 1.
    RETURN.
  ENDMETHOD.
ENDCLASS.

