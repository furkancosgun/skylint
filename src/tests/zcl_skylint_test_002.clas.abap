CLASS zcl_skylint_test_002 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS run.
ENDCLASS.

CLASS zcl_skylint_test_002 IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_skylint_test_002.
    CALL METHOD lo_obj->run.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_002.
    lo_obj->run( ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_runner TYPE REF TO zcl_skylint_test_002.
    CALL METHOD lo_runner->run( ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_runner TYPE REF TO zcl_skylint_test_002.
    lo_runner->run( ).
  ENDMETHOD.
ENDCLASS.
