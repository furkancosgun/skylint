CLASS zcl_test_no_late_sys_idx DEFINITION
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

CLASS zcl_test_no_late_sys_idx IMPLEMENTATION.
  METHOD test_001.
    " Compliant: sy-tabix read outside loop is ignored
    DATA lt_data TYPE string_table.
    DATA lv_idx  TYPE i.
    LOOP AT lt_data INTO DATA(ls_row).
    ENDLOOP.
    lv_idx = sy-tabix.
  ENDMETHOD.

  METHOD test_002.
    " Compliant: sy-tabix read immediately inside LOOP
    DATA lt_data TYPE string_table.
    DATA lv_idx  TYPE i.
    LOOP AT lt_data INTO DATA(ls_row).
      lv_idx = sy-tabix.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    " Compliant: sy-index read outside DO is ignored
    DATA lv_idx TYPE i.
    DO 5 TIMES.
    ENDDO.
    lv_idx = sy-index.
  ENDMETHOD.

  METHOD test_004.
    " Compliant: sy-index read immediately inside DO
    DATA lv_idx TYPE i.
    DO 5 TIMES.
      lv_idx = sy-index.
    ENDDO.
  ENDMETHOD.

  METHOD test_005.
    " Violation: sy-tabix read inside LOOP after another statement
    DATA lt_data TYPE string_table.
    DATA lv_idx  TYPE i.
    DATA lv_val  TYPE i.
    LOOP AT lt_data INTO DATA(ls_row).
      lv_val = 1.
      lv_idx = sy-tabix.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    " Violation: sy-index read inside DO after another statement
    DATA lv_idx TYPE i.
    DATA lv_val TYPE i.
    DO 5 TIMES.
      lv_val = 1.
      lv_idx = sy-index.
    ENDDO.
  ENDMETHOD.

  METHOD test_007.
    " Violation: sy-tabix read in outer loop after inner ENDLOOP
    DATA lt_outer TYPE string_table.
    DATA lt_inner TYPE string_table.
    DATA lv_idx   TYPE i.
    LOOP AT lt_outer INTO DATA(ls_out).
      LOOP AT lt_inner INTO DATA(ls_in).
      ENDLOOP.
      lv_idx = sy-tabix.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_008.
    " Compliant: pseudo-comment suppression
    DATA lt_data TYPE string_table.
    DATA lv_idx  TYPE i.
    DATA lv_val  TYPE i.
    LOOP AT lt_data INTO DATA(ls_row).
      lv_val = 1.
      lv_idx = sy-tabix. "#EC NO_LATE_SYS_IDX
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
