CLASS zcl_test_require_fully_typed DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_test_require_fully_typed IMPLEMENTATION.
  METHOD test_001.
    CONSTANTS lc_val VALUE 'X'.
  ENDMETHOD.

  METHOD test_002.
    CONSTANTS lc_val TYPE string VALUE 'X'.
  ENDMETHOD.

  METHOD test_003.
    CONSTANTS lc_other VALUE 123.
  ENDMETHOD.

  METHOD test_004.
    CONSTANTS lc_ok TYPE i VALUE 123.
  ENDMETHOD.

  METHOD test_005.
    DATA type TYPE i.
    CONSTANTS gc_c VALUE type.
  ENDMETHOD.
ENDCLASS.

