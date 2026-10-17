CLASS zcl_test_no_chained_decl DEFINITION
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
ENDCLASS.

CLASS zcl_test_no_chained_decl IMPLEMENTATION.
  METHOD test_001.
    DATA: lv_a TYPE i,
          lv_b TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
  ENDMETHOD.

  METHOD test_003.
    CONSTANTS: c_one TYPE i VALUE 1,
               c_two TYPE i VALUE 2.
  ENDMETHOD.

  METHOD test_004.
    CONSTANTS c_one TYPE i VALUE 1.
    CONSTANTS c_two TYPE i VALUE 2.
  ENDMETHOD.

  METHOD test_005.
    DATA: begin TYPE string,
          lv_x TYPE i.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    lv_a = lv_b = lv_c.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = lv_b.
  ENDMETHOD.
ENDCLASS.
