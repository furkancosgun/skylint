CLASS zcl_skylint_test_002 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_002 IMPLEMENTATION.
  METHOD with_finding.
    CALL METHOD lo_obj->run.
  ENDMETHOD.

  METHOD clean_code.
    lo_obj->run( ).
  ENDMETHOD.
ENDCLASS.
