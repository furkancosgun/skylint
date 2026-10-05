CLASS zcl_skylint_test_010 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_010 IMPLEMENTATION.
  METHOD with_finding.
    IF lo_validator->is_valid( ) = abap_true.
  ENDMETHOD.

  METHOD clean_code.
    IF lo_validator->is_valid( ).
    IF lv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.
