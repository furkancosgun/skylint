CLASS zcl_skylint_test_062 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_062 IMPLEMENTATION.
  METHOD test_001.
    TRY.
      TRY.
      CATCH cx_root.
      ENDTRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    TRY.
      DATA lv_val TYPE i.
      TRY.
      CATCH cx_sy_zerodivide.
      ENDTRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_004.
    TRY.
    CATCH cx_root.
    ENDTRY.
    TRY.
    CATCH cx_sy_zerodivide.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
