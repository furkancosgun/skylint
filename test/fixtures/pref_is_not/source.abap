CLASS zcl_test_prefer_is_not DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_prefer_is_not IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF NOT lv_x IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_prefer_is_not.
    CHECK NOT lo_obj IS BOUND.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_prefer_is_not.
    IF lo_obj IS BOUND.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
