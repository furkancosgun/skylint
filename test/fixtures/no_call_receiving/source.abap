CLASS zcl_test_no_receiving DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS run RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS zcl_test_no_receiving IMPLEMENTATION.
  METHOD run.
    rv_val = 1.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    lo_obj->run( RECEIVING rv_val = lv_x ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    lv_x = lo_obj->run( ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_no_receiving.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run( RECEIVING rv_val = lv_x ).
  ENDMETHOD.
ENDCLASS.
