CLASS zcl_skylint_test_005 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
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

  METHOD test_003.
    ME->RUN( ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_runner TYPE REF TO zcl_skylint_test_005.
    lo_runner->run( ).
  ENDMETHOD.

  METHOD test_005.
    DATA me TYPE REF TO zcl_skylint_test_005.
    me->run( ).
  ENDMETHOD.
ENDCLASS.
