CLASS zcl_test_no_unused_variables DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mt_diff TYPE string_table.
    DATA mt_patch TYPE string_table.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_test_no_unused_variables IMPLEMENTATION.
  METHOD test_001.
    DATA lv_unused TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_used TYPE i.
    lv_used = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_other TYPE string.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_val TYPE string.
    lv_val = 'a'.
  ENDMETHOD.

  METHOD test_005.
    DATA: BEGIN OF ls_outer,
            comp_a TYPE i,
            BEGIN OF ls_inner,
              comp_x TYPE i,
            END OF ls_inner,
          END OF ls_outer.
    ls_outer-comp_a = 1.
  ENDMETHOD.
ENDCLASS.

