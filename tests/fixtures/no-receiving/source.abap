CLASS zcl_test_no_receiving DEFINITION
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
    METHODS run
      IMPORTING iv_in TYPE i OPTIONAL
      RETURNING VALUE(rv_val) TYPE i
      EXCEPTIONS error.
ENDCLASS.

CLASS zcl_test_no_receiving IMPLEMENTATION.
  METHOD run.
    rv_val = iv_in.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run RECEIVING rv_val = lv_x.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x.
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x RECEIVING rv_val = lv_x.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    lv_x = lo_obj->run( iv_in = lv_x ).
  ENDMETHOD.

  METHOD test_005.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    lo_obj->run( RECEIVING rv_val = lv_x ).
  ENDMETHOD.

  METHOD test_006.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    lo_obj->run( iv_in = lv_x RECEIVING rv_val = lv_x ).
  ENDMETHOD.

  METHOD test_007.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run
      RECEIVING
        rv_val = lv_x
      EXCEPTIONS
        error = 1.
  ENDMETHOD.
ENDCLASS.
