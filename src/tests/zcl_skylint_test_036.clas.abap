CLASS zcl_skylint_test_036 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run IMPORTING iv_param TYPE i.
ENDCLASS.

CLASS zcl_skylint_test_036 IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_skylint_test_036.
    DATA lv_val TYPE i.
    lo_obj->run( iv_param = lv_val ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_036.
    DATA lv_val TYPE i.
    lo_obj->run( lv_val ).
  ENDMETHOD.
ENDCLASS.
