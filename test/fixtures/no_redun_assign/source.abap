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
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
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

  METHOD test_007.
    DATA lv_a TYPE i.
    MOVE lv_a TO lv_a.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD test_009.
    TYPES: BEGIN OF ty_struct,
             comp1 TYPE i,
             comp2 TYPE i,
           END OF ty_struct.
    DATA ls_data TYPE ty_struct.
    MOVE ls_data-comp1 TO ls_data-comp1.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_a TYPE i.
    MOVE EXACT lv_a TO lv_a.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_skylint_test_redun_clear DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_011.
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
ENDCLASS.

CLASS zcl_skylint_test_redun_clear IMPLEMENTATION.
  METHOD test_011.
    DATA lv_a TYPE i.
    CLEAR lv_a.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_a TYPE i.
    DATA lv_b TYPE string.
    CLEAR lv_a.
    CLEAR lv_b.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_a TYPE i VALUE 5.
    CLEAR lv_a.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_a TYPE i.
    lv_a = 5.
    CLEAR lv_a.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_015.
    DATA lt_data TYPE string_table.
    FREE lt_data.
  ENDMETHOD.

  METHOD test_016.
    DATA lv_a TYPE i.
    lv_a = 5.
    CLEAR lv_a.
  ENDMETHOD.

  METHOD test_017.
    DATA lt_tab TYPE string_table.
    lt_tab = VALUE #( ( `TEST` ) ).
    FREE lt_tab.
  ENDMETHOD.
ENDCLASS.
