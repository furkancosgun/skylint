CLASS zcl_skylint_test_037 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_037 IMPLEMENTATION.
  METHOD test_001.
    TRY.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_y TYPE i.
    TRY.
      lv_y = 1.
    ENDTRY.
  ENDMETHOD.

  METHOD test_004.
    TRY.
    CATCH cx_sy_zerodivide.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

