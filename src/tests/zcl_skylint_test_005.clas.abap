CLASS zcl_skylint_test_005 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run.
ENDCLASS.

CLASS zcl_skylint_test_005 IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    me->run( ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_005.
    lo_obj->run( ).
  ENDMETHOD.
ENDCLASS.
