CLASS zcl_test_no_exporting DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS run IMPORTING iv_in TYPE i OPTIONAL.
    METHODS calc
      IMPORTING iv_in TYPE i
      EXPORTING ev_out TYPE i.
ENDCLASS.

CLASS zcl_test_no_exporting IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD calc.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lo_obj->run( EXPORTING iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lo_obj->run( iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_res TYPE i.
    lo_obj->calc( EXPORTING iv_in = 1 IMPORTING ev_out = lv_res ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_m TYPE string VALUE 'RUN'.
    CALL METHOD lo_obj->(lv_m) EXPORTING iv_in = 1.
  ENDMETHOD.
ENDCLASS.
