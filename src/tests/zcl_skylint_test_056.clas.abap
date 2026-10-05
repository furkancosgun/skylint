CLASS zcl_skylint_test_056 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_056 IMPLEMENTATION.
  METHOD with_finding.
    METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.
  ENDMETHOD.

  METHOD clean_code.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
  ENDMETHOD.
ENDCLASS.
