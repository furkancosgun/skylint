CLASS zcl_test_no_obs_arith DEFINITION
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

CLASS zcl_test_no_obs_arith IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    ADD lv_x TO lv_y.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    lv_y = lv_y + lv_x.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_val TYPE i.
    COMPUTE lv_val = 1 + 2.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_src TYPE i.
    DATA lr_ref TYPE REF TO i.
    GET REFERENCE OF lv_src INTO lr_ref.
  ENDMETHOD.

  METHOD test_007.
    DATA: BEGIN OF ls_a, f1 TYPE i, END OF ls_a.
    DATA: BEGIN OF ls_b, f1 TYPE i, END OF ls_b.
    ADD-CORRESPONDING ls_a TO ls_b.
  ENDMETHOD.
ENDCLASS.
