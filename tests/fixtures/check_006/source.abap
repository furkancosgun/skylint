CLASS zcl_skylint_test_006 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS run IMPORTING iv_in TYPE i OPTIONAL.
ENDCLASS.

CLASS zcl_skylint_test_006 IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_skylint_test_006.
    DATA lv_x TYPE i.
    lo_obj->run( EXPORTING iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_006.
    DATA lv_x TYPE i.
    lo_obj->run( iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_skylint_test_006.
    lo_obj->run( EXPORTING iv_in = 1 ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_skylint_test_006.
    DATA lv_x TYPE i.
    lo_obj->run( lv_x ).
  ENDMETHOD.
ENDCLASS.
