CLASS zcl_skylint_test_062 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
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
ENDCLASS.
