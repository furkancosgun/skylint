CLASS zcl_skylint_test_014 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_014 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x = 1.
    lv_x = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

