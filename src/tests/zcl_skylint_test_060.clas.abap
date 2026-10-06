CLASS zcl_skylint_test_060 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_060 IMPLEMENTATION.
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
ENDCLASS.
