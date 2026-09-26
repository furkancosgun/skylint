CLASS zcl_skylint_test_010 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_010 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_c TYPE string.

    lv_a = 'HELLO'.
    lv_b = 'WORLD'.
    CONCATENATE lv_a lv_b INTO lv_c SEPARATED BY space.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_c TYPE string.

    lv_a = 'HELLO'.
    lv_b = 'WORLD'.
    CONCATENATE lv_a lv_b INTO lv_c. "#EC PREFER_STR_TMPL
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_c TYPE string.

    lv_a = 'HELLO'.
    lv_b = 'WORLD'.
    lv_c = |{ lv_a } { lv_b }|.
  ENDMETHOD.
ENDCLASS.
