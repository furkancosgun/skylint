CLASS zcl_test_no_ignored_ret DEFINITION
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

    METHODS calc_tax
      IMPORTING iv_amount TYPE i OPTIONAL
      RETURNING VALUE(rv_tax) TYPE i.

    METHODS set_status
      IMPORTING iv_status TYPE string.

    METHODS log
      IMPORTING iv_msg TYPE any.
ENDCLASS.

CLASS zcl_test_no_ignored_ret IMPLEMENTATION.
  METHOD calc_tax.
    rv_tax = iv_amount.
  ENDMETHOD.

  METHOD set_status.
    RETURN.
  ENDMETHOD.

  METHOD log.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    lo_obj->calc_tax( 100 ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    DATA lv_res TYPE i.
    lv_res = lo_obj->calc_tax( 100 ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    lo_obj->set_status( 'DONE' ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    DATA lv_res TYPE i.
    CALL METHOD lo_obj->calc_tax RECEIVING rv_tax = lv_res.
  ENDMETHOD.

  METHOD test_005.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    CALL METHOD lo_obj->calc_tax( 100 ).
  ENDMETHOD.

  METHOD test_006.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    IF lo_obj->calc_tax( 100 ) > 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lo_obj TYPE REF TO zcl_test_no_ignored_ret.
    lo_obj->log( lo_obj->calc_tax( 100 ) ).
  ENDMETHOD.

  METHOD test_008.
    DATA lv_xml TYPE string.
    CALL TRANSFORMATION id SOURCE text = 'hello' RESULT XML lv_xml.
  ENDMETHOD.
ENDCLASS.
