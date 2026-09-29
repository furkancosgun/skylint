CLASS zcl_skylint_test_090 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_090 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_text TYPE string.
    DATA lv_sub TYPE string.

    lv_sub = lv_text+0(2).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_text TYPE string.
    DATA lv_sub TYPE string.

    lv_sub = lv_text+0(2). "#EC MAGIC_OFFSET
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_text TYPE string.
    DATA lv_sub TYPE string.
    DATA lv_offset TYPE i.
    DATA lv_len TYPE i.

    lv_sub = substring( val = lv_text off = lv_offset len = lv_len ).
  ENDMETHOD.
ENDCLASS.
