CLASS zcl_test_prefer_corresponding DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_prefer_corresponding IMPLEMENTATION.
  METHOD test_001.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    MOVE-CORRESPONDING ls_src TO ls_dst.
  ENDMETHOD.

  METHOD test_002.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    ls_dst = CORRESPONDING #( ls_src ).
  ENDMETHOD.

  METHOD test_003.
    DATA: BEGIN OF ls_a, b TYPE i, END OF ls_a.
    DATA: BEGIN OF ls_b, b TYPE i, END OF ls_b.
    MOVE-CORRESPONDING ls_a TO ls_b.
  ENDMETHOD.

  METHOD test_004.
    DATA: BEGIN OF ls_a, b TYPE i, END OF ls_a.
    DATA: BEGIN OF ls_b, b TYPE i, END OF ls_b.
    ls_b = CORRESPONDING #( ls_a ).
  ENDMETHOD.

  METHOD test_005.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    MOVE-CORRESPONDING ls_src TO ls_dst EXPANDING NESTED TABLES.
  ENDMETHOD.
ENDCLASS.
