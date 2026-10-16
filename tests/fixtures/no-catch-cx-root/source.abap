CLASS zcl_test_no_catch_cx_root DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_catch_cx_root IMPLEMENTATION.
  METHOD test_001.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_002.
    TRY.
    CATCH cx_static_check.
    ENDTRY.
  ENDMETHOD.

  METHOD test_003.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
    CATCH cx_root INTO lx_err.
    ENDTRY.
  ENDMETHOD.

  METHOD test_004.
    TRY.
    CATCH cx_sy_zerodivide.
    ENDTRY.
  ENDMETHOD.

  METHOD test_005.
    DATA cx_root TYPE REF TO cx_static_check.
    TRY.
    CATCH cx_sy_no_handler INTO cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
