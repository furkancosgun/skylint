CLASS zcl_skylint_test_065 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_065 IMPLEMENTATION.
  METHOD test_001.
    PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_065.
    lo_obj->test_002( ).
  ENDMETHOD.
ENDCLASS.
