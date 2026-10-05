CLASS zcl_skylint_test_038 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_038 IMPLEMENTATION.
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
ENDCLASS.
