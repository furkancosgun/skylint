CLASS zcl_test_no_sy_modify DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.


CLASS zcl_test_no_sy_modify IMPLEMENTATION.
  METHOD test_001.
    sy-subrc = 0.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 0.
  ENDMETHOD.

  METHOD test_003.
    CLEAR sy-subrc.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_rc TYPE i.
    lv_rc = sy-subrc.
  ENDMETHOD.

  METHOD test_005.
    syst-subrc = 0.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_rc TYPE i.
    lv_rc = syst-subrc.
  ENDMETHOD.
ENDCLASS.

