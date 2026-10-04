CLASS zcl_skylint_test_079 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_079 IMPLEMENTATION.
  METHOD with_finding.
    METHODS meth IMPORTING !iv_param TYPE i.
  ENDMETHOD.

  METHOD clean_code.
    METHODS meth IMPORTING iv_param TYPE i.
  ENDMETHOD.
ENDCLASS.
