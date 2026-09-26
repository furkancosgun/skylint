CLASS zcl_skylint_test_008 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_008 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.

    lv_c = 0.
    lv_b = lv_c.
    lv_a = lv_b.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.

    lv_b = 1. "#EC ASSIGN_CHAIN
    lv_a = lv_b.
  ENDMETHOD.

  METHOD valid_code.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_a TYPE i.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_b TYPE i.

    lv_a = 1.
    lv_b = 2.
  ENDMETHOD.
ENDCLASS.
