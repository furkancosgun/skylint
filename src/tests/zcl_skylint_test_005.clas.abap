CLASS zcl_skylint_test_005 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_005 IMPLEMENTATION.
  METHOD with_finding.
    me->run( ).
  ENDMETHOD.

  METHOD clean_code.
    lo_obj->run( ).
  ENDMETHOD.
ENDCLASS.
