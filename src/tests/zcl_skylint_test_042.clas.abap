CLASS zcl_skylint_test_042 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_042 IMPLEMENTATION.
  METHOD with_finding.
    METHODS get_value EXPORTING ev_val TYPE i.
  ENDMETHOD.

  METHOD clean_code.
    METHODS get_value RETURNING VALUE(rv_val) TYPE i.
  ENDMETHOD.
ENDCLASS.
