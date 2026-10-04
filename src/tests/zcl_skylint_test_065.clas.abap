CLASS zcl_skylint_test_065 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_065 IMPLEMENTATION.
  METHOD with_finding.
    PERFORM my_form.
  ENDMETHOD.

  METHOD clean_code.
    lo_obj->run( ).
  ENDMETHOD.
ENDCLASS.
