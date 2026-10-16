CLASS zcl_test_no_raise_shortdump DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_raise_shortdump IMPLEMENTATION.
  METHOD test_001.
    RAISE shortdump TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_002.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_003.
    RAISE shortdump TYPE cx_sy_no_handler.
  ENDMETHOD.

  METHOD test_004.
    RAISE EXCEPTION TYPE cx_sy_no_handler.
  ENDMETHOD.
ENDCLASS.
