CLASS zcl_skylint_test_004 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_004 IMPLEMENTATION.
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
    DATA lo_obj TYPE REF TO zcl_skylint_test_004.
    CHECK NOT lo_obj IS BOUND.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_skylint_test_004.
    IF lo_obj IS BOUND.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
