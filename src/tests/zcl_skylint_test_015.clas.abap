CLASS zcl_skylint_test_015 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_015 IMPLEMENTATION.
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
ENDCLASS.

