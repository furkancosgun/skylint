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
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
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

  METHOD test_006.
    DATA lv_read TYPE i.
    DATA lv_sum TYPE i.
    lv_read = 1.
    lv_sum = lv_read + 2.
    WRITE lv_sum.
  ENDMETHOD.

  METHOD test_007.
    DATA(lv_inline_unused) = 10.
  ENDMETHOD.

  METHOD test_008.
    DATA(lv_inline_used) = 20.
    WRITE lv_inline_used.
  ENDMETHOD.

  METHOD test_009.
    DATA: BEGIN OF ls_person,
            name TYPE string,
          END OF ls_person.
    ls_person-name = 'Alice'.
    WRITE ls_person-name.
  ENDMETHOD.
ENDCLASS.

