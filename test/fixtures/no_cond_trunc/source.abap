CLASS zcl_skylint_test_trunc DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_skylint_test_trunc IMPLEMENTATION.
  METHOD test_001.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA(lv_val) = COND #( WHEN lv_ok = abap_true THEN 'OK' ELSE 'PROCESSING' ).
  ENDMETHOD.

  METHOD test_002.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA(lv_val) = COND string( WHEN lv_ok = abap_true THEN 'OK' ELSE 'PROCESSING' ).
  ENDMETHOD.

  METHOD test_003.
    DATA lv_code TYPE i VALUE 1.
    DATA(lv_val) = SWITCH #( lv_code WHEN 1 THEN 'A' ELSE 'LONGER_TEXT' ).
  ENDMETHOD.

  METHOD test_004.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA(lv_val) = COND #( WHEN lv_ok = abap_true THEN 'LONGER_STRING' ELSE 'OK' ).
  ENDMETHOD.

  METHOD test_005.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA(lv_val) = COND #( WHEN lv_ok = abap_true THEN 10 ELSE 20 ).
  ENDMETHOD.

  METHOD test_006.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA(lv_val) = COND #( WHEN lv_ok = abap_true THEN 'OK' ELSE 'PROCESSING' ). "#EC NO_COND_TRUNC
  ENDMETHOD.

  METHOD test_007.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA lv_string TYPE string VALUE 'ANTIGRAVITY'.
    DATA(lv_val) = COND #( WHEN lv_ok = abap_true THEN 'A' ELSE lv_string ).
  ENDMETHOD.

  METHOD test_008.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    DATA(lv_val) = COND #( WHEN lv_ok = abap_true THEN 'A' ELSE space ).
  ENDMETHOD.
ENDCLASS.
