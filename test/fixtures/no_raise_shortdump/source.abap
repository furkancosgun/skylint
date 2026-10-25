CLASS zcl_test_no_raise_shortdump DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_test_no_raise_shortdump IMPLEMENTATION.
  METHOD test_001.
    RAISE SHORTDUMP TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_002.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.
ENDCLASS.
