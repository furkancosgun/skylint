CLASS zcl_test_no_empty_catch DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_no_empty_catch IMPLEMENTATION.
  METHOD test_001.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    TRY.
    CATCH cx_root.
    lv_x = 1.
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    TRY.
    CATCH cx_static_check.
    CATCH cx_root.
      MESSAGE 'err' TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD test_004.
    TRY.
    CATCH cx_root.
      RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

