CLASS zcl_test_no_form_routines DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_form_routines IMPLEMENTATION.
  METHOD test_001.
    PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_no_form_routines.
    lo_obj->test_002( ).
  ENDMETHOD.

  METHOD test_003.
    PERFORM my_other_form.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.

FORM my_other_form.
ENDFORM.
