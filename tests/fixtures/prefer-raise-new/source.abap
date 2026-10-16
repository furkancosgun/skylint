CLASS zcl_skylint_test_023 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_023 IMPLEMENTATION.
  METHOD test_001.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_002.
    RAISE EXCEPTION NEW cx_sy_zerodivide( ).
  ENDMETHOD.

  METHOD test_003.
    RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
  ENDMETHOD.

  METHOD test_004.
    RAISE EXCEPTION NEW cx_sy_itab_line_not_found( ).
  ENDMETHOD.
ENDCLASS.
