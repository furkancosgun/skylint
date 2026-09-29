CLASS zcl_skylint_test_087 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_tab TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_087 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_src TYPE ty_tab.
    DATA lt_dst TYPE ty_tab.
    DATA lv_val TYPE i.

    LOOP AT lt_src INTO lv_val WHERE table_line > 0.
      INSERT lv_val INTO TABLE lt_dst.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_src TYPE ty_tab.
    DATA lt_dst TYPE ty_tab.
    DATA lv_val TYPE i.

    LOOP AT lt_src INTO lv_val WHERE table_line > 0. "#EC PREFER_FILTER
      INSERT lv_val INTO TABLE lt_dst.
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_src TYPE ty_tab.
    DATA lt_dst TYPE ty_tab.
    DATA lv_val TYPE i.

    LOOP AT lt_src INTO lv_val WHERE table_line > 0.
      lv_val = lv_val + 1.
      INSERT lv_val INTO TABLE lt_dst.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
