CLASS zcl_test_no_exporting DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS run IMPORTING iv_in TYPE i OPTIONAL RETURNING VALUE(rv_val) TYPE i.
    METHODS calc
      IMPORTING iv_in TYPE i
      EXPORTING ev_out TYPE i.
    METHODS modify
      IMPORTING iv_in TYPE i
      CHANGING cv_val TYPE i.
ENDCLASS.

CLASS zcl_test_no_exporting IMPLEMENTATION.
  METHOD run.
    rv_val = iv_in.
  ENDMETHOD.

  METHOD calc.
    RETURN.
  ENDMETHOD.

  METHOD modify.
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
    lo_obj->run( EXPORTING iv_in = 1 ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lo_obj->run( lv_x ).
  ENDMETHOD.

  METHOD test_005.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_res TYPE i.
    lo_obj->calc( EXPORTING iv_in = 1 IMPORTING ev_out = lv_res ).
  ENDMETHOD.

  METHOD test_006.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_res TYPE i.
    lo_obj->modify( EXPORTING iv_in = 1 CHANGING cv_val = lv_res ).
  ENDMETHOD.

  METHOD test_007.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_m TYPE string VALUE 'RUN'.
    CALL METHOD lo_obj->(lv_m) EXPORTING iv_in = 1.
  ENDMETHOD.

  METHOD test_008.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lo_obj->run( RECEIVING rv_val = lv_x ).
  ENDMETHOD.

  METHOD test_009.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lo_obj->run( iv_in = lv_x RECEIVING rv_val = lv_x ).
  ENDMETHOD.

  METHOD test_010.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lv_x = lo_obj->run( iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_011.
    DATA lo_obj TYPE REF TO zcl_test_no_exporting.
    DATA lv_x TYPE i.
    lv_x = lo_obj->run( lv_x ).
  ENDMETHOD.
ENDCLASS.
