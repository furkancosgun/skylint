CLASS zcl_test_no_single_param_name DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS run IMPORTING iv_param TYPE i.
ENDCLASS.

CLASS zcl_test_no_single_param_name IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_no_single_param_name.
    DATA lv_val TYPE i.
    lo_obj->run( iv_param = lv_val ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_no_single_param_name.
    DATA lv_val TYPE i.
    lo_obj->run( lv_val ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_no_single_param_name.
    lo_obj->run( iv_param = 5 ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_no_single_param_name.
    lo_obj->run( 5 ).
  ENDMETHOD.

  METHOD test_005.
    DATA lo_obj TYPE REF TO zcl_test_no_single_param_name.
    CALL METHOD lo_obj->run( iv_param = 5 ).
  ENDMETHOD.

  METHOD test_006.
    DATA lo_obj TYPE REF TO zcl_test_no_single_param_name.
    lo_obj->run( EXPORTING iv_param = 5 ).
  ENDMETHOD.
ENDCLASS.
