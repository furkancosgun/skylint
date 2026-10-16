CLASS zcl_test_no_self_assignment DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.


CLASS zcl_test_no_self_assignment IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    lv_a = lv_a.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = lv_b.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_b TYPE i.
    lv_b = lv_b.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_m TYPE i.
    DATA lv_n TYPE i.
    lv_m = lv_n.
  ENDMETHOD.

  METHOD test_005.
    TYPES: BEGIN OF ty_struct,
             comp1 TYPE i,
             comp2 TYPE i,
           END OF ty_struct.
    DATA ls_data TYPE ty_struct.
    ls_data-comp1 = ls_data-comp1.
  ENDMETHOD.

  METHOD test_006.
    TYPES: BEGIN OF ty_struct,
             comp1 TYPE i,
             comp2 TYPE i,
           END OF ty_struct.
    DATA ls_data TYPE ty_struct.
    ls_data-comp1 = ls_data-comp2.
  ENDMETHOD.
ENDCLASS.

