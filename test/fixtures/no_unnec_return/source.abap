CLASS zcl_test_no_unnec_return DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_no_unnec_return IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    lv_x = 10.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 10.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    IF lv_x = 1.
      RETURN.
    ENDIF.
    lv_x = 2.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_y TYPE i.
    RETURN.
  ENDMETHOD.
ENDCLASS.
