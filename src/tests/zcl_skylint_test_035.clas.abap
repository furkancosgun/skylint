CLASS zcl_skylint_test_035 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_035 IMPLEMENTATION.
  METHOD with_finding.
    CONSTANTS lc_val VALUE 'X'.
  ENDMETHOD.

  METHOD clean_code.
    CONSTANTS lc_val TYPE string VALUE 'X'.
  ENDMETHOD.
ENDCLASS.
