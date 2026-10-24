CLASS zcl_test_dangerous_statement DEFINITION
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
ENDCLASS.


CLASS zcl_test_dangerous_statement IMPLEMENTATION.
  METHOD test_001.
    DATA lv_msg TYPE string.
    DATA lv_lin TYPE i.
    DATA lv_wrd TYPE string.
    DATA lt_prog TYPE string_table.
    SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    CHECK lv_flag = abap_true.
  ENDMETHOD.

  METHOD test_003.
    DELETE REPORT 'ZFOO'.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA: lv_tab TYPE string, lt_cust TYPE STANDARD TABLE OF t100.
    SELECT * FROM (lv_tab) INTO TABLE @lt_cust.
  ENDMETHOD.

  METHOD test_006.
    SELECT * FROM t100 INTO TABLE @DATA(lt_cust).
  ENDMETHOD.

  METHOD test_007.
    RAISE SHORTDUMP TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_x TYPE i.
    ASSERT lv_x > 0.
  ENDMETHOD.
ENDCLASS.
